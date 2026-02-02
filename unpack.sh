#!/bin/bash
echo "[INFO] starting update"

# 1. Aktualizacja głównej struktury plików
sudo rm -rf /usr/share/HackerOS/
sudo mv /tmp/HackerOS-Updates/HackerOS/ /usr/share/HackerOS/

# 2. Uprawnienia dla skryptów systemowych
# Upewniamy się, że katalog istnieje zanim do niego wejdziemy
if [ -d "/usr/share/HackerOS/Scripts/Bin/" ]; then
    cd /usr/share/HackerOS/Scripts/Bin/ || exit
    sudo chmod a+x Bit-Jump.sh check_updates_notify.sh HackerOS-Games.sh HackerOS-Information.sh Proton-Updater.sh update_system.sh update-hackeros.sh unpack-xanmod.sh update-liquorix.sh
fi

if [ -d "/usr/share/HackerOS/Scripts/Steam/" ]; then
    cd /usr/share/HackerOS/Scripts/Steam/ || exit
    sudo chmod a+x HackerOS-Steam.sh HackerOS-Steam-Animation.sh
fi

# 3. Aplikacje HackerOS (Przeniesione do /usr/share/HackerOS/Scripts/HackerOS-Apps)
sudo mkdir -p /usr/share/HackerOS/Scripts/HackerOS-Apps
cd /usr/share/HackerOS/Scripts/HackerOS-Apps || exit

sudo rm -f HackerOS-Game-Mode.AppImage Hacker_Launcher HackerOS-Welcome HackerOS-App Hacker-Term.AppImage

sudo curl -L -o HackerOS-Game-Mode.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Game-Mode/releases/download/v0.2/HackerOS-Game-Mode.AppImage"
sudo curl -L -o Hacker_Launcher "https://github.com/HackerOS-Linux-System/Hacker-Launcher/releases/download/v0.5/Hacker_Launcher"
sudo curl -L -o HackerOS-Welcome "https://github.com/HackerOS-Linux-System/HackerOS-Welcome/releases/download/v0.5/HackerOS-Welcome"
sudo curl -L -o Hacker-Term.AppImage "https://github.com/HackerOS-Linux-System/Hacker-Term/releases/download/v0.4/Hacker-Term.AppImage"
sudo curl -L -o HackerOS-App "https://github.com/HackerOS-Linux-System/HackerOS-App/releases/download/v0.3/HackerOS-App"

sudo chmod a+x Hacker_Launcher Hacker-Term.AppImage HackerOS-Welcome HackerOS-Game-Mode.AppImage HackerOS-App

# 4. Gry HackerOS (Przeniesione do /usr/share/HackerOS/Scripts/HackerOS-Games)
sudo mkdir -p /usr/share/HackerOS/Scripts/HackerOS-Games
cd /usr/share/HackerOS/Scripts/HackerOS-Games || exit

sudo rm -f HackerOS-Games.AppImage the-racer starblaster bit-jump.love

sudo curl -L -o HackerOS-Games.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.6/HackerOS-Games"
sudo curl -L -o the-racer "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.5/the-racer"
sudo curl -L -o starblaster "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.6/starblaster"
sudo curl -L -o bit-jump.love "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.6/bit-jump.love"

sudo chmod a+x HackerOS-Games.AppImage the-racer bit-jump.love starblaster bark-squadron.AppImage

# 5. Narzędzia CLI w /usr/bin/
cd /usr/bin/ || exit
sudo rm -f hpm hacker ngt hedit a

sudo curl -L -o hedit "https://github.com/HackerOS-Linux-System/hedit/releases/download/v0.3/hedit"
sudo curl -L -o ngt "https://github.com/HackerOS-Linux-System/ngt/releases/download/v0.2/ngt"
sudo curl -L -o hacker "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.2/hacker"
sudo curl -L -o hpm "https://github.com/HackerOS-Linux-System/Hacker-Package-Manager/releases/download/v0.5/hpm"

sudo chmod a+x hacker hpm hedit ngt

# 6. Konfiguracja użytkownika ~/.hackeros (bez sudo, to pliki lokalne)
mkdir -p ~/.hackeros/hacker/
cd ~/.hackeros/hacker/ || exit
rm -f hacker-shell hacker-help hacker-select hacker-docs HackerOS-Updater HackerOS-Update-Better apt-fronted

curl -L -o hacker-shell "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.2/hacker-shell"
curl -L -o hacker-help "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.2/hacker-help"
curl -L -o hacker-select "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.2/hacker-select"
curl -L -o hacker-docs "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.2/hacker-docs"
curl -L -o HackerOS-Updater "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.2/HackerOS-Updater"
curl -L -o HackerOS-Update-Better "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.2/HackerOS-Update-Better"
curl -L -o apt-fronted "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.2/apt-fronted"

chmod a+x HackerOS-Updater HackerOS-Update-Better hacker-docs hacker-help hacker-shell hacker-select apt-fronted

# 7. Hacker-Lang
mkdir -p ~/.hackeros/hacker-lang/bin
cd ~/.hackeros/hacker-lang/bin || exit
rm -f hacker-compiler hacker-plsa hacker-runtime repl

curl -L -o hacker-compiler "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.5/hacker-compiler"
curl -L -o hacker-plsa "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.5/hacker-plsa"
curl -L -o hacker-runtime "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.5/hacker-runtime"
curl -L -o repl "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.5/hacker-repl"

chmod a+x hacker-runtime hacker-compiler hacker-plsa hacker-repl

# 8. Binarki systemowe Hacker-Lang
cd /usr/bin/ || exit
sudo rm -f hl hli hlh
sudo curl -L -o hl "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.5/hl"
sudo curl -L -o hli "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.5/hli"
sudo curl -L -o hlh "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.5/hlh"
sudo chmod a+x hl hli hlh

# 9. HPM Backend
mkdir -p ~/.hackeros/hpm/
cd ~/.hackeros/hpm/ || exit
rm -f backend
curl -L -o backend "https://github.com/HackerOS-Linux-System/Hacker-Package-Manager/releases/download/v0.5/backend"
chmod a+x backend

cd ~
echo "[INFO] updated complete"
