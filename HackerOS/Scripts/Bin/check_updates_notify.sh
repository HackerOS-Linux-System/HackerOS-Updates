#!/bin/bash

# Sprawdź aktualizacje APT
APT_UPDATES=$(apt list --upgradable 2>/dev/null | grep -c "upgradable")

# Sprawdź aktualizacje Flatpak
FLATPAK_UPDATES=$(flatpak remote-ls --updates | grep -c "^")

# Sprawdź aktualizacje Snap
SNAP_UPDATES=$(snap refresh --list | grep -c "^")

# Suma wszystkich dostępnych aktualizacji
TOTAL_UPDATES=$((APT_UPDATES + FLATPAK_UPDATES + SNAP_UPDATES))

if [ "$TOTAL_UPDATES" -gt 0 ]; then
    # Parametry okna
    WIDTH=350
    HEIGHT=200

    # Pobierz rozmiar ekranu
    SCREEN_WIDTH=$(xrandr | grep '*' | awk '{print $1}' | cut -d'x' -f1)
    SCREEN_HEIGHT=$(xrandr | grep '*' | awk '{print $1}' | cut -d'x' -f2)

    # Pozycja prawy dolny róg (20 px od krawędzi)
    POS_X=$((SCREEN_WIDTH - WIDTH - 20))
    POS_Y=$((SCREEN_HEIGHT - HEIGHT - 60))

    # Uruchom zenity w tle
    (
        zenity --question \
            --title="Dostępne aktualizacje systemowe" \
            --width=$WIDTH \
            --height=$HEIGHT \
            --text="Wykryto aktualizacje:\n• APT: $APT_UPDATES\n• Flatpak: $FLATPAK_UPDATES\n• Snap: $SNAP_UPDATES\n\nCzy chcesz zaktualizować system?"
        echo $? > /tmp/zenity_response
    ) &

    # Poczekaj aż okno się pojawi
    sleep 0.5

    # Przesuń okno na prawy dolny róg
    wmctrl -r "Dostępne aktualizacje systemowe" -e 0,$POS_X,$POS_Y,$WIDTH,$HEIGHT

    # Poczekaj na zakończenie zenity
    wait

    RESPONSE=$(cat /tmp/zenity_response)
    rm /tmp/zenity_response

    if [ "$RESPONSE" -eq 0 ]; then
        bash /usr/share/HackerOS/Scripts/Bin/update_system.sh
    fi
fi
