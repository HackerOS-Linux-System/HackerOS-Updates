#!/usr/bin/env bash
set -euo pipefail

# Pliki do sprawdzenia
files=(
  "/usr/share/HackerOS/Scripts/HackerOS-Games/bit-jump.love"
  "/usr/share/HackerOS/Scripts/HackerOS-Games/starblaster"
  "/usr/share/HackerOS/Scripts/HackerOS-Games/the-racer"
  "/usr/share/HackerOS/Scripts/HackerOS-Games/HackerOS-Games.AppImage"
)

app="/usr/share/HackerOS/Scripts/HackerOS-Games/HackerOS-Games.AppImage"

# Jeśli nie jesteśmy rootem — zapytaj o sudo raz (żeby nie pytał wielokrotnie)
if [ "$(id -u)" -ne 0 ]; then
  if ! sudo -v; then
    echo "Nie udało się uwierzytelnić przez sudo. Przerwanie."
    exit 1
  fi
fi

for f in "${files[@]}"; do
  if [ ! -e "$f" ]; then
    echo "UWAGA: plik nie istnieje: $f"
    continue
  fi

  if [ -x "$f" ]; then
    echo "OK: $f już jest wykonywalny."
  else
    echo "Dodaję uprawnienie wykonania do: $f"
    sudo chmod a+x "$f" || { echo "Błąd: nie udało się nadać uprawnień: $f"; exit 1; }
    echo "Nadano uprawnienie: $f"
  fi
done

# Uruchomienie AppImage bez sudo
if [ ! -x "$app" ]; then
  echo "Błąd: $app nadal nie ma bitu wykonywalnego. Sprawdź uprawnienia."
  exit 1
fi

echo "Uruchamiam aplikację: $app (bez sudo)..."
# Uruchamiamy w tle, żeby skrypt się zakończył i nie blokował terminala.
"$app" >/dev/null 2>&1 & disown

echo "Gotowe — aplikacja uruchomiona w tle."
