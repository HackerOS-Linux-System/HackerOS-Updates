#!/bin/bash

#  _   _            _              ___  ____
# | | | | __ _  ___| | _____ _ __ / _ \/ ___|
# | |_| |/ _` |/ __| |/ / _ \ '__| | | \___ \
# |  _  | (_| | (__|   <  __/ |  | |_| |___) |
# |_| |_|\__,_|\___|_|\_\___|_|   \___/|____/              _
# | | | |_ __   __| | __ _| |_ ___   / ___| |__   ___  ___| | __
# | | | | '_ \ / _` |/ _` | __/ _ \ | |   | '_ \ / _ \/ __| |/ /
# | |_| | |_) | (_| | (_| | ||  __/ | |___| | | |  __/ (__|   <
#  \___/| .__/ \__,_|\__,_|\__\___|  \____|_| |_|\___|\___|_|\_\
#       |_|

LOGFILE="/tmp/hackeros-update-check.log"
UPDATE_SCRIPT="/usr/share/HackerOS/Scripts/Bin/update_system.sh"
AUTOSTART_FILE="/etc/xdg/autostart/hackeros-update-check.desktop"

# Proste logowanie (bez błędów jeśli brak praw)
log() {
    echo "$(date --iso-8601=seconds) - $1" >> "$LOGFILE" 2>/dev/null || true
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

log "=== START check_updates_gui.sh ==="

# ---------------------------
# BACKEND: tylko sprawdzenia (BEZ GUI)
# ---------------------------

# APT
if command_exists apt; then
    APT_UPDATES=$(apt list --upgradable 2>/dev/null | sed '/^Listing.../d;/^$/d' | wc -l)
    : $((APT_UPDATES=APT_UPDATES+0))
else
    APT_UPDATES=0
fi

# Flatpak
if command_exists flatpak; then
    # remote-ls --updates może nie istnieć wszędzie; próbujemy i liczymy linie
    FLATPAK_UPDATES=$(flatpak remote-ls --updates 2>/dev/null | sed '/^$/d' | wc -l)
    : $((FLATPAK_UPDATES=FLATPAK_UPDATES+0))
else
    FLATPAK_UPDATES=0
fi

# Snap
if command_exists snap; then
    SNAP_UPDATES=$(snap refresh --list 2>/dev/null | tail -n +2 | sed '/^$/d' | wc -l)
    : $((SNAP_UPDATES=SNAP_UPDATES+0))
else
    SNAP_UPDATES=0
fi

# Firmware (fwupd)
if command_exists fwupdmgr; then
    FWUPD_UPDATES=$(fwupdmgr get-updates 2>/dev/null | sed '/^$/d' | grep -c -E "Update|Device" || true)
    : $((FWUPD_UPDATES=FWUPD_UPDATES+0))
else
    FWUPD_UPDATES=0
fi

TOTAL_UPDATES=$((APT_UPDATES + FLATPAK_UPDATES + SNAP_UPDATES + FWUPD_UPDATES))
log "Sprawdzenie zakończone: APT=$APT_UPDATES, Flatpak=$FLATPAK_UPDATES, Snap=$SNAP_UPDATES, FWUPD=$FWUPD_UPDATES, SUMA=$TOTAL_UPDATES"

# Jeśli brak aktualizacji -> kompletnie ciche wyjście (nic nie uruchamiamy)
if [ "$TOTAL_UPDATES" -le 0 ]; then
    log "Brak aktualizacji. Nic nie pokazuję. KONIEC."
    exit 0
fi

# ---------------------------
# Przygotowanie tekstu do GUI
# ---------------------------
UPDATE_DETAILS="<b>Dostępne aktualizacje:</b>\n\n"
UPDATE_DETAILS+="• <b>APT</b>: $APT_UPDATES aktualizacji\n"
UPDATE_DETAILS+="• <b>Flatpak</b>: $FLATPAK_UPDATES aktualizacji\n"
UPDATE_DETAILS+="• <b>Snap</b>: $SNAP_UPDATES aktualizacji\n"
UPDATE_DETAILS+="• <b>Firmware</b>: $FWUPD_UPDATES aktualizacji\n\n"
UPDATE_DETAILS+="<b>Łącznie</b>: $TOTAL_UPDATES aktualizacji\n\n"
UPDATE_DETAILS+="Wybierz akcję:"

# ---------------------------
# Funkcje akcji
# ---------------------------
action_close() {
    log "Akcja: Zamknij"
    exit 0
}

action_run_update_script_as_user() {
    local target_user="$1"
    local uid="$2"

    log "Akcja: Zaktualizuj teraz (uruchamiam update script w kontekście $target_user UID=$uid)"

    if [ ! -f "$UPDATE_SCRIPT" ]; then
        log "BŁĄD: Skrypt aktualizacji nie znaleziony: $UPDATE_SCRIPT"
        return 1
    fi

    # Uruchom skrypt jako ten użytkownik z sudo (jeżeli wymagane) w tle, aby nie blokować GUI.
    # Najpierw spróbuj uruchomić z prawami użytkownika (jeśli update_script nie wymaga sudo)
    # Jeśli potrzebujesz sudo, skrypt będzie uruchamiany z sudo przez użytkownika.
    # Używamy runuser aby zachować środowisko użytkownika (bez tworzenia okien przed checkiem).
    if command_exists runuser; then
        # Uruchom z przekazanymi zmiennymi środowiskowymi (DISPLAY i DBUS)
        local envfile="/tmp/hackeros_update_env_${uid}.sh"
        # Utwórz envfile z potrzebnymi zmiennymi (jeżeli istnieją)
        echo "export DISPLAY='${DISPLAY_OVERRIDE:-:0}'" > "$envfile"
        if [ -n "$DBUS_OVERRIDE" ]; then
            echo "export DBUS_SESSION_BUS_ADDRESS='$DBUS_OVERRIDE'" >> "$envfile"
        fi
        chmod 600 "$envfile" 2>/dev/null || true

        # Uruchom skrypt przez runuser w tle
        runuser -u "$target_user" -- bash -lc "source '$envfile' >/dev/null 2>&1; nohup sudo '$UPDATE_SCRIPT' >/dev/null 2>&1 & disown" >/dev/null 2>&1 || true
        rm -f "$envfile" 2>/dev/null || true
        log "Skrypt update uruchomiony (nohup) przez $target_user."
    else
        # Fallback: spróbuj zwykłego sudo w tle
        nohup sudo "$UPDATE_SCRIPT" >/dev/null 2>&1 & disown
        log "Skrypt update uruchomiony (nohup sudo fallback)."
    fi
    return 0
}

action_disable_notifications() {
    log "Akcja: Nie pokazuj więcej -> usuwam: $AUTOSTART_FILE"
    if [ -f "$AUTOSTART_FILE" ]; then
        if sudo rm -f "$AUTOSTART_FILE" >/dev/null 2>&1; then
            log "Usunięto plik autostartu: $AUTOSTART_FILE"
        else
            log "Nie udało się usunąć autostartu (brak uprawnień?): $AUTOSTART_FILE"
        fi
    else
        log "Plik autostartu nie istniał: $AUTOSTART_FILE"
    fi
    exit 0
}

# ---------------------------
# Uruchomienie Zenity w kontekście sesji graficznej użytkownika
# ---------------------------
# Cel: wywołać Zenity tylko teraz (po wykryciu aktualizacji) w sesji graficznej zalogowanego użytkownika,
#       by okno należało do tej sesji i nie tworzyło "niewidzialnego" wpisu innego procesu na pasku zadań.

# Znajdź aktywną sesję użytkownika (preferuj aktywną sesję local)
find_graphical_session() {
    # Preferuj loginctl (systemd) — zwraca USER:UID i SESSION
    if command_exists loginctl; then
        while IFS= read -r line; do
            # line: SESSION  UID USER SEAT TTY
            session_id=$(echo "$line" | awk '{print $1}')
            # sprawdź czy sesja aktywna i ma Display
            active=$(loginctl show-session "$session_id" -p Active --value 2>/dev/null || echo "no")
            state=$(loginctl show-session "$session_id" -p State --value 2>/dev/null || echo "")
            user=$(loginctl show-session "$session_id" -p Name --value 2>/dev/null || echo "")
            uid=$(loginctl show-session "$session_id" -p Remote --value 2>/dev/null || true)
            # choose active local session
            if [ "$active" = "yes" ] || [ "$state" = "active" ]; then
                # Resolve user and uid
                USERNAME="$user"
                USERID=$(id -u "$USERNAME" 2>/dev/null || true)
                echo "$USERNAME:$USERID:$session_id"
                return 0
            fi
        done < <(loginctl list-sessions --no-legend 2>/dev/null | awk '{print $1}')
    fi

    # Fallback: wybierz pierwszy użytkownika z procesem typu gnome-session/plasma-session/Xorg/Xwayland
    for p in gnome-session plasma-session startplasma-x11 Xorg Xwayland; do
        pid=$(pgrep -u "$(logname 2>/dev/null || echo $USER)" -x "$p" | head -n1)
        if [ -n "$pid" ]; then
            USERNAME=$(ps -o user= -p "$pid" | awk '{print $1}')
            USERID=$(id -u "$USERNAME" 2>/dev/null || true)
            echo "$USERNAME:$USERID:na"
            return 0
        fi
    done

    # Ostatecznie zwróć bieżącego użytkownika procesu wykonującego (jeśli to nie root)
    if [ -n "$SUDO_USER" ]; then
        USERNAME="$SUDO_USER"
    else
        USERNAME="$(logname 2>/dev/null || echo $USER)"
    fi
    USERID=$(id -u "$USERNAME" 2>/dev/null || true)
    echo "$USERNAME:$USERID:na"
    return 0
}

session_info=$(find_graphical_session)
USERNAME="$(echo "$session_info" | cut -d: -f1)"
USERID="$(echo "$session_info" | cut -d: -f2)"

log "Wybrana sesja użytkownika: USER=$USERNAME UID=$USERID"

# Przygotuj zmienne środowiskowe dla sesji użytkownika (DISPLAY i DBUS)
# Najczęściej DISPLAY=:0 i DBUS pod /run/user/$UID/bus
DISPLAY_OVERRIDE=""
DBUS_OVERRIDE=""

# Jeśli XDISPLAY jest ustawiony w środowisku aktualnego użytkownika (próba odczytu), użyj go
# Spróbuj odczytać DISPLAY i DBUS z plików w /proc dla procesu sesji (jeśli możliwe)
if [ -n "$USERID" ] && [ "$USERID" != "0" ]; then
    # Najpierw ustaw domyślnie DISPLAY=:0
    DISPLAY_OVERRIDE=":0"
    # DBUS session bus
    if [ -e "/run/user/${USERID}/bus" ]; then
        DBUS_OVERRIDE="unix:path=/run/user/${USERID}/bus"
    fi
fi

# Jeśli mamy DBUS_OVERRIDE i DISPLAY_OVERRIDE to spróbuj uruchomić zenity jako ten user
if command_exists zenity && [ -n "$DISPLAY_OVERRIDE" ]; then
    # Zbuduj polecenie zenity (radiolist)
    ZEN_CMD="zenity --list --radiolist --title='Aktualizacje systemu' --text='$UPDATE_DETAILS' --column='' --column='Akcja' TRUE 'Zamknij' FALSE 'Zaktualizuj teraz' FALSE 'Nie pokazuj więcej' --width=520 --height=300"

    # Uruchom w kontekście użytkownika, przekazując potrzebne env
    # Najpierw sprawdź czy runuser istnieje i możemy go użyć
    if command_exists runuser; then
        # Eksportujemy DISPLAY i DBUS w linii poleceń, aby zenity należał do sesji tego użytkownika
        if [ -n "$DBUS_OVERRIDE" ]; then
            # Zapisz je w zmiennej i uruchom
            log "Uruchamiam Zenity jako $USERNAME z DISPLAY=$DISPLAY_OVERRIDE i DBUS=$DBUS_OVERRIDE"
            runuser -u "$USERNAME" -- bash -lc "export DISPLAY='$DISPLAY_OVERRIDE'; export DBUS_SESSION_BUS_ADDRESS='$DBUS_OVERRIDE'; $ZEN_CMD" >/tmp/hackeros_zenity_out.$$ 2>/tmp/hackeros_zenity_err.$$ || true
            CHOICE=$(cat /tmp/hackeros_zenity_out.$$ 2>/dev/null || true)
            rm -f /tmp/hackeros_zenity_out.$$ /tmp/hackeros_zenity_err.$$ 2>/dev/null || true
        else
            # Brak DBUS, uruchom jedynie z DISPLAY
            log "Uruchamiam Zenity jako $USERNAME z DISPLAY=$DISPLAY_OVERRIDE (brak DBUS)"
            runuser -u "$USERNAME" -- bash -lc "export DISPLAY='$DISPLAY_OVERRIDE'; $ZEN_CMD" >/tmp/hackeros_zenity_out.$$ 2>/tmp/hackeros_zenity_err.$$ || true
            CHOICE=$(cat /tmp/hackeros_zenity_out.$$ 2>/dev/null || true)
            rm -f /tmp/hackeros_zenity_out.$$ /tmp/hackeros_zenity_err.$$ 2>/dev/null || true
        fi
    else
        # fallback: uruchom bez runuser ale z env (może pojawić się w kontekście tego procesu)
        log "Brak runuser — uruchamiam Zenity w bieżącym kontekście (fallback)"
        export DISPLAY="$DISPLAY_OVERRIDE"
        [ -n "$DBUS_OVERRIDE" ] && export DBUS_SESSION_BUS_ADDRESS="$DBUS_OVERRIDE"
        CHOICE=$(bash -c "$ZEN_CMD" 2>/dev/null) || true
    fi
else
    # Brak zenity lub brak DISPLAY info -> fallback tekstowy w terminalu (jeśli ktoś uruchamia ręcznie)
    log "Zenity niedostępny lub brak informacji o DISPLAY/DBUS -> fallback terminal"
    echo -e "$UPDATE_DETAILS"
    echo "1) Zamknij"
    echo "2) Zaktualizuj teraz"
    echo "3) Nie pokazuj więcej"
    read -rp "Wybór: " choice
    case $choice in
        1) action_close ;;
        2) action_run_update_script_as_user "$USERNAME" "$USERID"; exit 0 ;;
        3) action_disable_notifications ;;
        *) action_close ;;
    esac
fi

# Jeżeli CHOICE jest puste oznacza że użytkownik zamknął okno -> nic do zrobienia
if [ -z "${CHOICE:-}" ]; then
    log "Brak wyboru (okno zamknięte lub anulowane). Kończę."
    exit 0
fi

# Znormalizuj możliwe wyniki (Zenity może zwracać etykietę)
case "$CHOICE" in
    "Zamknij"|"Zamknij\n"|"Zamknij\r")
        action_close
        ;;
    "Zaktualizuj teraz"|"Zaktualizuj teraz\n")
        # Uruchom update script w kontekście użytkownika, by okno postępu (jeśli będą) pojawiło się w sesji
        # Przekaż username i uid
        action_run_update_script_as_user "$USERNAME" "$USERID"
        ;;
    "Nie pokazuj więcej"|"Nie pokazuj więcej\n")
        action_disable_notifications
        ;;
    *)
        # W niektórych środowiskach zenity może zwracać wynik w innym formacie - porównaj fragmenty
        if echo "$CHOICE" | grep -qi "Zaktualizuj"; then
            action_run_update_script_as_user "$USERNAME" "$USERID"
        elif echo "$CHOICE" | grep -qi "Nie pokazuj"; then
            action_disable_notifications
        else
            action_close
        fi
        ;;
esac

# Koniec
log "Koniec działania skryptu."
exit 0
