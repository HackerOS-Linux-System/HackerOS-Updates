#!/bin/bash

# Lokalizacja skryptu do podmiany animacji
ANIMATION_SCRIPT="/usr/share/HackerOS/Scripts/Steam/HackerOS-Steam-Animation.sh"

# Instalacja Steam jeśli potrzeba
if ! command -v steam &> /dev/null; then
    zenity --info --text="Steam nie jest zainstalowany. Instaluję..."
    distrobox create HackerOS-Steam --image archlinux:latest && distrobox enter HackerOS-Steam -- echo -e '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/pacman.conf >/dev/null && distrobox enter HackerOS-Steam -- sudo pacman -Syu --noconfirm && distrobox enter HackerOS-Steam -- sudo pacman -S --noconfirm steam lib32-mesa lib32-vulkan-icd-loader lib32-alsa-lib lib32-gcc-libs lib32-gtk3 lib32-libgcrypt lib32-libpulse lib32-libva lib32-libxml2 lib32-nss lib32-openal lib32-sdl2 lib32-vulkan-intel lib32-vulkan-radeon lib32-nvidia-utils lib32-libxss lib32-libgpg-error lib32-dbus gnu-free-fonts noto-fonts ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid ttf-ibm-plex ttf-input ttf-input-nerd ttf-liberation ttf-roboto lib32-vulkan-asahi lib32-vulkan-dzn lib32-vulkan-freedreno lib32-vulkan-gfxstream lib32-vulkan-nouveau lib32-vulkan-swrast lib32-vulkan-virtio
fi

# GUI wyboru trybu uruchomienia
CHOICE=$(zenity --list --title="Wybierz tryb Steama" \
  --column="Tryb" --height=250 --width=300 \
  "Zwykły Steam" \
  "Steam Big Picture" \
  "Nie uruchamiaj")

case "$CHOICE" in
  "Zwykły Steam"|"Steam Big Picture")
    # Wywołanie zewnętrznego skryptu do podmiany animacji
    if [ -x "$ANIMATION_SCRIPT" ]; then
        "$ANIMATION_SCRIPT"
    else
        zenity --error --text="Nie znaleziono lub brak uprawnień do wykonania:\n$ANIMATION_SCRIPT"
        exit 1
    fi
    ;;
  "Nie uruchamiaj")
    echo "Nie uruchamiam Steama."
    exit 0
    ;;
  *)
    echo "Anulowano lub zamknięto okno."
    exit 1
    ;;
esac

# Uruchamianie odpowiedniego trybu
if [[ "$CHOICE" == "Zwykły Steam" ]]; then
  HackerOS-Steam run
elif [[ "$CHOICE" == "Steam Big Picture" ]]; then
  HackerOS-Steam run -gamepadui
fi
