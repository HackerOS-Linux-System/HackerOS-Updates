#!/bin/bash

ICON_PATH="/usr/share/HackerOS/ICONS/HackerOS.png"
AUTOSTART_FILE="/etc/xdg/autostart/updates_notify.desktop"
CONFIG_FILE="$HOME/.HackerOS/updates_notify.json"
STAMP_FILE="$HOME/.cache/last_update_check"
UPDATE_SCRIPT="/usr/share/HackerOS/Scripts/Bin/update_system.sh"

# Sprawdź czy feh i wmctrl są zainstalowane
command -v feh >/dev/null 2>&1 || { echo "Brak programu feh!"; exit 1; }
command -v wmctrl >/dev/null 2>&1 || { echo "Brak programu wmctrl!"; exit 1; }

# Limit: tylko raz dziennie
if [ -f "$STAMP_FILE" ] && [ $(( $(date +%s) - $(cat "$STAMP_FILE") )) -lt 86400 ]; then
    exit 0
fi
date +%s > "$STAMP_FILE"

# Preferencja użytkownika
if [ -f "$CONFIG_FILE" ]; then
    PREF=$(cat "$CONFIG_FILE")
else
    PREF="zenity"
fi

# Sprawdź aktualizacje
APT_UPDATES=$(apt list --upgradable 2>/dev/null | grep -c "upgradable")
FLATPAK_UPDATES=$(flatpak remote-ls --updates | grep -c "^")
SNAP_UPDATES=$(snap refresh --list | grep -c "^")
TOTAL_UPDATES=$((APT_UPDATES + FLATPAK_UPDATES + SNAP_UPDATES))

[ "$TOTAL_UPDATES" -eq 0 ] && exit 0

# Jeśli wybrano powiadomienie systemowe
if [ "$PREF" = "notify" ]; then
    notify-send "Aktualizacje systemowe" "Dostępne:\nAPT: $APT_UPDATES\nFlatpak: $FLATPAK_UPDATES\nSnap: $SNAP_UPDATES"
    exit 0
fi

# GUI Zenity + obrazek w tle (feh)
WIDTH=400
HEIGHT=250

SCREEN_WIDTH=$(xrandr | grep '*' | awk '{print $1}' | cut -d'x' -f1)
SCREEN_HEIGHT=$(xrandr | grep '*' | awk '{print $1}' | cut -d'x' -f2)

POS_X=$((SCREEN_WIDTH - WIDTH - 20))
POS_Y=$((SCREEN_HEIGHT - HEIGHT - 60))

# Tło z HackerOS logo (półprzezroczyste)
feh --title "HackerOS_Logo_Background" --geometry "${WIDTH}x${HEIGHT}+$POS_X+$POS_Y" --zoom fill --image-bg white --scale-down "$ICON_PATH" &
FEH_PID=$!

# Poczekaj chwilę
sleep 0.3

# Przesuń tło w tył
wmctrl -r "HackerOS_Logo_Background" -b add,below
wmctrl -r "HackerOS_Logo_Background" -b add,sticky
wmctrl -r "HackerOS_Logo_Background" -b add,skip_taskbar
wmctrl -r "HackerOS_Logo_Background" -b add,skip_pager

# Wyświetl Zenity
(
zenity --question \
    --title="Dostępne aktualizacje systemowe" \
    --window-icon="$ICON_PATH" \
    --width=$WIDTH \
    --height=$HEIGHT \
    --text="Wykryto aktualizacje:\n• APT: $APT_UPDATES\n• Flatpak: $FLATPAK_UPDATES\n• Snap: $SNAP_UPDATES\n\nCzy chcesz zaktualizować system?\n\nMożesz też zmienić formę powiadomień lub zobaczyć szczegóły." \
    --ok-label="Zaktualizuj" \
    --extra-button="Ustawienia powiadomień" \
    --extra-button="Szczegóły" \
    --cancel-label="Anuluj"
echo $? > /tmp/zenity_response
) &

# Poczekaj aż okno się pojawi
sleep 0.5
wmctrl -r "Dostępne aktualizacje systemowe" -e 0,$POS_X,$POS_Y,$WIDTH,$HEIGHT
wait

RESPONSE=$(cat /tmp/zenity_response)
rm /tmp/zenity_response

# Zamknij logo w tle
kill "$FEH_PID" 2>/dev/null

# Obsługa przycisków
case "$RESPONSE" in
    0) # OK: aktualizuj
        bash "$UPDATE_SCRIPT"
        ;;
    1) # Ustawienia
        CHOICE=$(zenity --list \
            --title="Preferencje powiadomień" \
            --text="Wybierz sposób powiadamiania o aktualizacjach:" \
            --radiolist \
            --column="Wybór" --column="Opcja" \
            TRUE "Używaj okien (Zenity)" \
            FALSE "Używaj powiadomień systemowych (notify-send)" \
            FALSE "Wyłącz powiadomienia całkowicie" \
            --width=400 --height=250)

        case "$CHOICE" in
            "Używaj powiadomień systemowych (notify-send)")
                echo "notify" > "$CONFIG_FILE"
                notify-send "Powiadomienia" "Od teraz powiadomienia będą systemowe."
                ;;
            "Wyłącz powiadomienia całkowicie")
                sudo rm -f "$AUTOSTART_FILE"
                rm -f "$CONFIG_FILE"
                notify-send "Powiadomienia wyłączone" "Autostart usunięty."
                ;;
            *)
                echo "zenity" > "$CONFIG_FILE"
                ;;
        esac
        ;;
    2) # Szczegóły
        DETAILS=$(printf "APT:\n%s\n\nFlatpak:\n%s\n\nSnap:\n%s\n" \
            "$(apt list --upgradable 2>/dev/null)" \
            "$(flatpak remote-ls --updates)" \
            "$(snap refresh --list)")
        echo "$DETAILS" | zenity --text-info --title="Szczegóły aktualizacji" --width=600 --height=400
        ;;
    *)
        exit 0
        ;;
esac