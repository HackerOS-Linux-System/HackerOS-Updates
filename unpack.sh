#!/bin/bash
echo "[INFO] starting update"

# 1. Aktualizacja głównej struktury plików
sudo rm -rf /usr/share/HackerOS/
sudo mv /tmp/HackerOS-Updates/HackerOS/ /usr/share/HackerOS/

# 2. Uprawnienia dla skryptów systemowych
# Upewniamy się, że katalog istnieje zanim do niego wejdziemy
if [ -d "/usr/share/HackerOS/Scripts/Bin/" ]; then
    cd /usr/share/HackerOS/Scripts/Bin/ || exit
    sudo chmod a+x Bit-Jump.sh check_updates_notify.sh HackerOS-Games.sh Proton-Updater.sh update_system.sh update-hackeros.sh update-wallpapers.sh
fi

if [ -d "/usr/share/HackerOS/Scripts/Steam/" ]; then
    cd /usr/share/HackerOS/Scripts/Steam/ || exit
    sudo chmod a+x HackerOS-Steam.sh HackerOS-Steam-Animation.sh
 
    sudo mkdir -p bin
    sudo curl -L -o bin/gui "https://github.com/HackerOS-Linux-System/HackerOS-Steam/releases/download/v0.4/gui"
    sudo curl -L -o bin/tui "https://github.com/HackerOS-Linux-System/HackerOS-Steam/releases/download/v0.4/tui"
    sudo chmod a+x bin/gui bin/tui
fi

# 3. Aplikacje HackerOS (Przeniesione do /usr/share/HackerOS/Scripts/HackerOS-Apps)
sudo mkdir -p /usr/share/HackerOS/Scripts/HackerOS-Apps
cd /usr/share/HackerOS/Scripts/HackerOS-Apps || exit

sudo rm -f HackerOS-Game-Mode.AppImage Hacker_Launcher HackerOS-Welcome HackerOS-Store Hacker-Term.AppImage

sudo curl -L -o HackerOS-Game-Mode.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Game-Mode/releases/download/v0.2/HackerOS-Game-Mode.AppImage"
sudo curl -L -o Hacker_Launcher "https://github.com/HackerOS-Linux-System/Hacker-Launcher/releases/download/v0.8/Hacker_Launcher"
sudo curl -L -o HackerOS-Welcome "https://github.com/HackerOS-Linux-System/HackerOS-Welcome/releases/download/v0.5/HackerOS-Welcome"
sudo curl -L -o Hacker-Term "https://github.com/HackerOS-Linux-System/Hacker-Term/releases/download/v0.6/Hacker-Term"
sudo curl -L -o HackerOS-Store "https://github.com/HackerOS-Linux-System/HackerOS-Store/releases/download/v0.5/HackerOS-Store"

sudo chmod a+x Hacker_Launcher Hacker-Term.AppImage HackerOS-Welcome HackerOS-Game-Mode.AppImage HackerOS-Store

# 4. Gry HackerOS (Przeniesione do /usr/share/HackerOS/Scripts/HackerOS-Games)
sudo mkdir -p /usr/share/HackerOS/Scripts/HackerOS-Games
cd /usr/share/HackerOS/Scripts/HackerOS-Games || exit

sudo rm -f HackerOS-Games.AppImage the-racer starblaster bit-jump.love bark-squadron.AppImage

sudo curl -L -o HackerOS-Games.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.6/HackerOS-Games"
sudo curl -L -o the-racer "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.5/the-racer"
sudo curl -L -o starblaster "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.6/starblaster"
sudo curl -L -o bit-jump.love "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.6/bit-jump.love"
sudo curl -L -o bark-squadron.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.6/bark-squadron.AppImage"

sudo chmod a+x HackerOS-Games.AppImage the-racer bit-jump.love starblaster bark-squadron.AppImage

# 5. Narzędzia CLI w /usr/bin/
cd /usr/bin/ || exit
sudo rm -f hpm hacker ngt hedit a hackeros-steam hbuild getit chker hsh

sudo curl -L -o hedit "https://github.com/HackerOS-Linux-System/hedit/releases/download/v0.4/hedit"
sudo curl -L -o ngt "https://github.com/HackerOS-Linux-System/ngt/releases/download/v0.4/ngt"
sudo curl -L -o hacker "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/hacker"
sudo curl -L -o hpm "https://github.com/HackerOS-Linux-System/HackerOS-Package-Manager/releases/download/v0.7/hpm"
sudo curl -L -o hackeros-steam "https://github.com/HackerOS-Linux-System/HackerOS-Steam/releases/download/v0.3/hackeros-steam"
sudo curl -L -o hbuild "https://github.com/HackerOS-Linux-System/hbuild/releases/download/v0.3/hbuild"
sudo curl -L -o a "https://github.com/HackerOS-Linux-System/a/releases/download/v0.2/a"
sudo curl -L -o getit "https://github.com/HackerOS-Linux-System/ghdir/releases/download/v0.4/getit"
sudo curl -L -o chcker "https://github.com/HackerOS-Linux-System/chker/releases/download/v0.1/chker"
sudo curl -L -o hsh "https://github.com/HackerOS-Linux-System/hsh/releases/download/v0.4/hsh"

sudo chmod a+x hacker hpm hedit ngt a hackeros-steam hbuild getit chker hsh

# 6. Konfiguracja użytkownika ~/.hackeros (bez sudo, to pliki lokalne)
mkdir -p ~/.hackeros/hacker/
cd ~/.hackeros/hacker/ || exit
rm -f hacker-shell hacker-help hacker-select hacker-docs HackerOS-Updater update-system apt-fronted hacker-repair

curl -L -o hacker-shell "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/hacker-shell"
curl -L -o hacker-repair "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/hacker-repair"
curl -L -o hacker-help "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/hacker-help"
curl -L -o hacker-select "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/hacker-select"
curl -L -o hacker-docs "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/hacker-docs"
curl -L -o HackerOS-Updater "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/HackerOS-Updater"
curl -L -o update-system "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/update-system"
curl -L -o apt-fronted "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.4/apt-fronted"

chmod a+x HackerOS-Updater update-system hacker-docs hacker-help hacker-shell hacker-select apt-fronted hacker-repair

# 8. Hacker Lang
cd /usr/bin/ || exit
sudo rm -f hl
sudo curl -L -o hl "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v0.3/hl"
sudo chmod a+x hl 

cd ~
echo "[INFO] updated complete"
