#!/bin/bash

# Automatyczne usuwanie jąder Debiana (poza aktywnym)
# Michał – wersja stabilna i bezpieczna

export DEBIAN_FRONTEND=noninteractive

# Aktualnie uruchomione jądro
CURRENT_KERNEL=$(uname -r)

echo "Aktywne jądro to: $CURRENT_KERNEL"
echo "Szukam zainstalowanych jąder..."

# Pobierz wszystkie zainstalowane jądra Debiana
INSTALLED_KERNELS=$(dpkg -l | grep "linux-image-" | awk '{print $2}')

if [[ -z "$INSTALLED_KERNELS" ]]; then
    echo "Nie znaleziono żadnych jąder do usunięcia."
    exit 0
fi

for KERNEL in $INSTALLED_KERNELS; do
    # Sprawdź czy pasuje do aktualnego
    if echo "$KERNEL" | grep -q "$CURRENT_KERNEL"; then
        echo "Pomijam aktualnie uruchomione jądro: $KERNEL"
        continue
    fi

    echo "Usuwam jądro: $KERNEL"
    sudo apt remove --purge -y "$KERNEL"
done

echo "Czyszczenie nieużywanych zależności..."
sudo apt autoremove --purge -y

echo "Gotowe."