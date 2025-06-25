#!/bin/bash

# Skrypt do kopiowania plików konfiguracyjnych i ikon w HackerOS

echo "Kopiowanie plików .desktop..."
sudo cp -r /usr/share/HackerOS/Config-Files/HackerOS-Steam.desktop /usr/share/applications/
sudo cp -r /usr/share/HackerOS/Config-Files/org.gnome.Software.desktop /usr/share/applications/

echo "Kopiowanie ikon Plymouth..."
sudo cp -r /usr/share/HackerOS/ICONS/Plymouth-Icons/bgrt-fallback.png /usr/share/plymouth/themes/spinner/
sudo cp -r /usr/share/HackerOS/ICONS/Plymouth-Icons/ubuntu-logo.png /usr/share/plymouth/
sudo cp -r /usr/share/HackerOS/ICONS/Plymouth-Icons/watermark.png /usr/share/plymouth/themes/spinner/

echo "Kopiowanie zakończone!"
