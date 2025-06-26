#!/bin/bash

# Ścieżka do katalogu tymczasowego
TMP_DIR="/tmp/gamescope-session-steam"

# Klonowanie repozytorium do /tmp
git clone https://github.com/HackerOS-Linux-System/gamescope-session-steam.git "$TMP_DIR"

# Sprawdzenie czy klonowanie się powiodło
if [ $? -ne 0 ]; then
  echo "Błąd klonowania repozytorium."
  exit 1
fi

# Przejście do katalogu z repozytorium
cd "$TMP_DIR" || { echo "Nie można wejść do katalogu $TMP_DIR"; exit 1; }

# Uruchomienie skryptu install.sh z uprawnieniami sudo
sudo bash install.sh
