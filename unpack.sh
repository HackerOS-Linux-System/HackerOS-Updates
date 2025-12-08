echo "[INFO] starting update"
sudo rm -rf /usr/share/HackerOS/
sudo mv /tmp/HackerOS-Updates/HackerOS/ /usr/share/HackerOS/
cd /usr/share/HackerOS/Scripts/Bin/
sudo chmod a+x /usr/share/HackerOS/Scripts/Bin/Bit-Jump.sh /usr/share/HackerOS/Scripts/Bin/check_updates_notify.sh /usr/share/HackerOS/Scripts/Bin/HackerOS-Games.sh /usr/share/HackerOS/Scripts/Bin/HackerOS-Information.sh /usr/share/HackerOS/Scripts/Bin/Proton-Updater.sh /usr/share/HackerOS/Scripts/Bin/update_system.sh /usr/share/HackerOS/Scripts/Bin/update-hackeros.sh /usr/share/HackerOS/Scripts/Bin/unpack-xanmod.sh /usr/share/HackerOS/Scripts/Bin/update-liquorix.sh
cd ..
cd Steam
sudo chmod a+x /usr/share/HackerOS/Scripts/Steam/HackerOS-Steam.sh /usr/share/HackerOS/Scripts/Steam/HackerOS-Steam-Animation.sh
cd ..
sudo mkdir HackerOS-Games
sudo mkdir HackerOS-Apps
cd HackerOS-Apps
sudo rm -rf HackerOS-Game-Mode.AppImage
sudo rm -rf Hacker_Launcher
sudo rm -rf HackerOS-Welcome
curl -L -o HackerOS-Game-Mode.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Game-Mode/releases/download/v0.2/HackerOS-Game-Mode.AppImage"
curl -L -o Hacker_Launcher "https://github.com/HackerOS-Linux-System/Hacker-Launcher/releases/download/v0.5/Hacker-Launcher"
curl -L -o HackerOS-Welcome "https://github.com/HackerOS-Linux-System/HackerOS-Welcome/releases/download/v0.5HackerOS-Welcome"
sudo chmod a+x Hacker_Launcher
sudo chmod a+x HackerOS-Welcome
sudo chmod a+x HackerOS-Game-Mode.AppImage
cd ..
cd HackerOS-Games
sudo rm -rf HackerOS-Games
sudo rm -rf the-racer
sudo rm -rf starblaster
sudo rm -rf bit-jump.love
curl -L -o HackerOS-Games.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.5/HackerOS-Games"
curl -L -o the-racer "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.5/the-racer"
curl -L -o starblaster "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.5/starblaster"
curl -L -o bit-jump.love "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.5/bit-jump.love"
sudo chmod a+x HackerOS-Games
sudo chmod a+x the-racer
sudo chmod a+x bit-jump.love
sudo chmod a+x starblaster
cd /usr/bin/
sudo rm -rf hpm
sudo rm -rf hacker
curl -L -o hacker "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.9/hacker"
curl -L -o hpm "https://github.com/HackerOS-Linux-System/Hacker-Package-Manager/releases/download/v0.3/hpm"
sudo chmod a+x hacker
sudo chmod a+x hpm
cd ~/.hackeros/hacker/
sudo rm -rf hacker-shell
sudo rm -rf hacker-help
sudo rm -rf hacker-select
sudo rm -rf hacker-docs
sudo rm -rf HackerOS-Updater
sudo rm -rf HackerOS-Update-Better
curl -L -o hacker-shell "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.9/hacker-shell"
curl -L -o hacker-help "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.9/hacker-help"
curl -L -o hacker-select "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.9/hacker-select"
curl -L -o hacker-docs "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.9/hacker-docs"
curl -L -o HackerOS-Updater "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.9/HackerOS-Updater"
curl -L -o HackerOS-Update-Better "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v2.0/HackerOS-Update-Better"
sudo chmod a+x HackerOS-Updater
sudo chmod a+x HackerOS-Update-Better
sudo chmod a+x hacker-docs
sudo chmod a+x hacker-help
sudo chmod a+x hacker-shell
sudo chmod a+x hacker-select
cd ..
cd hacker-lang
cd bin
sudo rm -rf hacker-compiler
sudo rm -rf hacker-parser
sudo rm -rf hacker-runtime
curl -L -o hacker-compiler "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.2/hacker-compiler"
curl -L -o hacker-parser "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.2/hacker-parser"
curl -L -o hacker-editor "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.2/hacker-runtime"
sudo chmod a+x hacker-runtime
sudo chmod a+x hacker-parser
sudo chmod a+x hacker-compiler
sudo rm -rf repl
curl -L -o hacker-repl "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v0.1.0/repl"
sudo chmod a+x repl
cd /usr/bin/
sudo rm -rf bytes
sudo rm -rf hackerc
sudo rm -rf hli
sudo rm -rf hlh
curl -L -o hackerc "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.2/hackerc"
curl -L -o hli "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.2/hli"
curl -L -o hlh "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v1.2/hlh"
curl -L -o bytes "https://github.com/Bytes-Repository/Bytes-CLI-Tool/releases/download/v0.5/bytes"
sudo chmod a+x hackerc
sudo chmod a+x hli
sudo chmod a+x hlh
sudo chmod a+x bytes
cd ~/.hackeros/hpm/
sudo rm -rf tui
sudo rm -rf apt-fronted
curl -L -o tui "https://github.com/HackerOS-Linux-System/Hacker-Package-Manager/releases/download/v0.3/tui"
curl -L -o apt-fronted "https://github.com/HackerOS-Linux-System/Hacker-Package-Manager/releases/download/v0.3/apt-fronted"
sudo chmod a+x tui
sudo chmod a+x apt-fronted
cd ~
echo "[INFO] updated complete"
