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
    # Wyswietl GUI z Zenity
    zenity --info \
        --title="Dostępne aktualizacje systemowe" \
        --width=350 \
        --height=150 \
        --ok-label="Zaktualizuj system" \
        --text="Wykryto aktualizacje:\n• APT: $APT_UPDATES\n• Flatpak: $FLATPAK_UPDATES\n• Snap: $SNAP_UPDATES\n\nKliknij przycisk, aby rozpocząć aktualizację."

    # Po kliknięciu przycisku uruchom skrypt aktualizacji
    bash /usr/share/HackerOS/Scripts/Bin/update_system.sh
fi
