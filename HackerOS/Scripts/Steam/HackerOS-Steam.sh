#!/usr/bin/env bash

# Ścieżka do skryptu podmieniającego animacje
ANIMATION_SCRIPT="/usr/share/HackerOS/Scripts/Steam/HackerOS-Steam-Animation.sh"

# Sprawdzenie czy Steam (flatpak) jest zainstalowany
if ! flatpak list --app | grep -q com.valvesoftware.Steam; then
    echo "Steam (flatpak) nie jest zainstalowany. Instaluję..."
    flatpak install -y flathub com.valvesoftware.Steam
fi

# Wybór trybu Steam przez użytkownika
CHOICE=$(zenity --list --title="Wybierz tryb Steama" \
  --column="Tryb" --height=250 --width=300 \
  "Zwykły Steam" \
  "Steam GamepadUI" \
  "Nie uruchamiaj")

case "$CHOICE" in
  "Zwykły Steam"|"Steam GamepadUI")
    # Uruchamiamy skrypt podmiany animacji
    if [ -x "$ANIMATION_SCRIPT" ]; then
      "$ANIMATION_SCRIPT"
    else
      echo "Nie znaleziono lub brak uprawnień do $ANIMATION_SCRIPT"
      exit 2
    fi
    ;;
  "Nie uruchamiaj")
    echo "Wybrano brak uruchamiania."
    exit 0
    ;;
  *)
    echo "Anulowano lub zamknięto okno."
    exit 1
    ;;
esac

# Uruchomienie wybranego trybu Steama
if [[ "$CHOICE" == "Zwykły Steam" ]]; then
  flatpak run com.valvesoftware.Steam
elif [[ "$CHOICE" == "Steam GamepadUI" ]]; then
  flatpak run com.valvesoftware.Steam -gamepadui
fi
