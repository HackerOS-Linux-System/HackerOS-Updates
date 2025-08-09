#!/bin/bash

ICON_PATH="/usr/share/HackerOS/ICONS/HackerOS.png"
AUTOSTART_FILE="/etc/xdg/autostart/hackeros-update-check.desktop"
CONFIG_FILE="$HOME/.HackerOS/updates_notify.json"
STAMP_FILE="$HOME/.cache/last_update_check"
UPDATE_SCRIPT="/usr/share/HackerOS/Scripts/Bin/update_system.sh"

# Sprawdź czy wymagane programy są zainstalowane
command -v zenity >/dev/null 2>&1 || { echo "Brak programu zenity!"; exit 1; }

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
DNF_UPDATES=$(/usr/lib/HackerOS/dnf list --upgradable 2>/dev/null | grep -c "upgradable")
FLATPAK_UPDATES=$(flatpak remote-ls --updates | grep -c "^")
SNAP_UPDATES=$(snap refresh --list | grep -c "^")
TOTAL_UPDATES=$((DNF_UPDATES + FLATPAK_UPDATES + SNAP_UPDATES))

[ "$TOTAL_UPDATES" -eq 0 ] && exit 0

# Jeśli wybrano powiadomienie systemowe
if [ "$PREF" = "notify" ]; then
    notify-send "Aktualizacje systemowe" "Dostępne:\nDNF: $DNF_UPDATES\nFlatpak: $FLATPAK_UPDATES\nSnap: $SNAP_UPDATES"
    exit 0
fi

# Wyświetl Zenity
RESPONSE=$(zenity --question \
    --title="Dostępne aktualizacje systemowe" \
    --window-icon="$ICON_PATH" \
    --width=400 \
    --height=250 \
    --text="Wykryto aktualizacje:\n• DNF: $DNF_UPDATES\n• Flatpak: $FLATPAK_UPDATES\n• Snap: $SNAP_UPDATES\n\nCzy chcesz zaktualizować system?\n\nMożesz też zmienić formę powiadomień lub zobaczyć szczegóły." \
    --ok-label="Zaktualizuj" \
    --extra-button="Ustawienia powiadomień" \
    --extra-button="Szczegóły" \
    --cancel-label="Anuluj")

# Obsługa przycisków
case "$RESPONSE" in
    0) # OK: aktualizuj
        bash "$UPDATE_SCRIPT"
        ;;
    "Ustawienia powiadomień")
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
    "Szczegóły")
        DETAILS=$(printf "DNF:\n%s\n\nFlatpak:\n%s\n\nSnap:\n%s\n" \
            "$(/usr/lib/HackerOS/dnf list --upgradable 2>/dev/null)" \
            "$(flatpak remote-ls --updates)" \
            "$(snap refresh --list)")
        echo "$DETAILS" | zenity --text-info --title="Szczegóły aktualizacji" --width=600 --height=400
        ;;
    *)
        exit 0
        ;;
esac
