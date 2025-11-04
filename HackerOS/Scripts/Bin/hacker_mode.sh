#!/bin/bash

#  _   _            _              ___  ____    _____
# | | | | __ _  ___| | _____ _ __ / _ \/ ___|  |_   _|__  __ _ _ __ ___
# | |_| |/ _` |/ __| |/ / _ \ '__| | | \___ \    | |/ _ \/ _` | '_ ` _ \
# |  _  | (_| | (__|   <  __/ |  | |_| |___) |   | |  __/ (_| | | | | | |
# |_| |_|\__,_|\___|_|\_\___|_|   \___/|____/    |_|\___|\__,_|_| |_| |_|

set -euo pipefail

TARGET_CMD="/usr/bin/cage /usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Mode"
TTY="tty3"
SWITCH=false

# Sprawdź opcję --switch
if [[ "${1:-}" == "--switch" ]]; then
  SWITCH=true
fi

# sprawdź, czy skrypt uruchomiono jako root
if [[ $EUID -ne 0 ]]; then
  echo "Ten skrypt musi być uruchomiony jako root (sudo)." >&2
  exit 1
fi

# Wykrywanie aktualnego użytkownika
USERNAME=$(whoami)

# sprawdź, czy TTY istnieje
if [[ ! -e "/dev/${TTY}" ]]; then
  echo "/dev/${TTY} nie istnieje. Sprawdź poprawność numeru TTY." >&2
  exit 2
fi

# sprawdź, czy polecenie istnieje
if [[ ! -x "${TARGET_CMD%% *}" ]]; then
  echo "Nie znaleziono wykonywalnego: ${TARGET_CMD%% *}" >&2
  exit 3
fi

echo "Uruchamiam polecenie na /dev/${TTY} jako użytkownik ${USERNAME}..."
echo "Polecenie: $TARGET_CMD"

# Komenda do uruchomienia: przekierowujemy stdout/stderr do tty3, setsid -> nowa sesja
# używamy openvt aby przypisać proces do VT numer 3 (nie wymuszamy przełączenia)
# su -l uruchamia polecenie w kontekście użytkownika.
openvt -c 3 -- su -l "$USERNAME" -c "exec >/dev/${TTY} 2>&1; exec setsid ${TARGET_CMD}" &

pid=$!
echo "Proces uruchomiony (PID $pid)."

if $SWITCH; then
  echo "Przełączam aktywne VT na /dev/${TTY}..."
  # chvt może zwrócić błąd w kontenerach lub gdy brak uprawnień, trzymamy -e off
  if ! chvt 3; then
    echo "Uwaga: chvt nie powiodło się. Możliwe, że jesteś w środowisku, gdzie chvt nie jest dostępne."
  fi
fi

echo "Gotowe."
exit 0
