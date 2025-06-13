#!/bin/bash

# Daj uprawnienia do wykonywania dla samego siebie
chmod a+x "$0"

# Sprawdź, czy katalog źródłowy istnieje
if [ ! -d "/tmp/HackerOS-Updates/HackerOS/" ]; then
    echo "Błąd: Katalog /tmp/HackerOS-Updates/HackerOS/ nie istnieje."
    exit 1
fi

# Usuń istniejący katalog /usr/share/HackerOS/
echo "Usuwam /usr/share/HackerOS/..."
sudo rm -rf /usr/share/HackerOS/

# Przenieś katalog do /usr/share/
echo "Przenoszę nowy katalog HackerOS do /usr/share/..."
sudo mv /tmp/HackerOS-Updates/HackerOS/ /usr/share/

echo "Operacja zakończona sukcesem."
