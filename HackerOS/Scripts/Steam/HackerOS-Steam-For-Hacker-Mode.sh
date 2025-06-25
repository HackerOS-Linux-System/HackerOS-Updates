#!/bin/bash

# Lokalizacja skryptu do podmiany animacji
ANIMATION_SCRIPT="/usr/share/HackerOS/Scripts/Steam/HackerOS-Steam-Animation.sh"

# Instalacja Steam jeśli potrzeba
if ! command -v steam &> /dev/null; then
    echo "Steam nie jest zainstalowany. Instaluję..."
    sudo apt update && sudo apt install -y steam
fi

# Wywołanie zewnętrznego skryptu do podmiany animacji
if [ -x "$ANIMATION_SCRIPT" ]; then
    "$ANIMATION_SCRIPT"
else
    echo "Nie znaleziono lub brak uprawnień do wykonania: $ANIMATION_SCRIPT"
    exit 1
fi

# Uruchamianie Steam w trybie Big Picture
steam -gamepadui
