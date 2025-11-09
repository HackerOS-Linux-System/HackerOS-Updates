#!/bin/bash
echo "[INFO] starting update"
sudo rm -rf /usr/share/HackerOS/
sudo mv /tmp/HackerOS-Updates/HackerOS/ /usr/share/HackerOS/
cd /usr/share/HackerOS/Scripts/Bin/
sudo chmod a+x /usr/share/HackerOS/Scripts/Bin/Bit-Jump.sh /usr/share/HackerOS/Scripts/Bin/check_updates_notify.sh /usr/share/HackerOS/Scripts/Bin/hacker_mode.sh /usr/share/HackerOS/Scripts/Bin/HackerOS-Games.sh /usr/share/HackerOS/Scripts/Bin/HackerOS-Information.sh /usr/share/HackerOS/Scripts/Bin/Proton-Updater.sh /usr/share/HackerOS/Scripts/Bin/revert_to_plasma.sh /usr/share/HackerOS/Scripts/Bin/Switch_To_Other_Session.sh /usr/share/HackerOS/Scripts/Bin/update_system.sh  /usr/share/HackerOS/Scripts/Bin/hackeros-update.sh 
cd ..
cd Steam
sudo chmod a+x /usr/share/HackerOS/Scripts/Steam/HackerOS-Steam.sh /usr/share/HackerOS/Scripts/Steam/HackerOS-Steam-Animation.sh
cd ..
sudo mkdir HackerOS-Games
sudo mkdir HackerOS-Apps
cd HackerOS-Apps
curl -L -o HackerOS-Game-Mode.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Game-Mode/releases/download/v0.2/HackerOS-Game-Mode.AppImage"
curl -L -o Hacker_Launcher "https://github.com/HackerOS-Linux-System/Hacker-Launcher/releases/download/v0.5/Hacker-Launcher"
curl -L -o Hacker-Mode "https://github.com/HackerOS-Linux-System/Hacker-Mode/releases/download/v0.9/Hacker-Mode"
curl -L -o HackerOS-Welcome "https://github.com/HackerOS-Linux-System/HackerOS-Welcome/releases/download/v0.3/HackerOS-Welcome"
curl -L -o HackerOS-Connect.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Connect/releases/download/v0.3/HackerOS-Connect.AppImage"
sudo chmod a+x Hacker_Launcher
sudo chmod a+x Hacker-Mode
sudo chmod a+x HackerOS-Welcome
sudo chmod a+x HackerOS-Game-Mode.AppImage
sudo chmod a+x HackerOS-Connect.AppImage
cd ..
cd HackerOS-Games
curl -L -o HackerOS-Games.AppImage "https://github.com/HackerOS-Linux-System/HackerOS-Games/releases/download/v0.3/HackerOS-Games.AppImage"
curl -L -o the-racer ""
curl -L -o starblaster ""
curl -L -o bit-jump.love ""
curl -L -o  ""
sudo chmod a+x HackerOS-Games.AppImage
sudo chmod a+x the-racer
sudo chmod a+x bit-jump.love
sudo chmod a+x starblaster
cd /usr/bin/
sudo rm -rf hacker
curl -L -o hacker "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.1/hacker"
sudo chmod a+x hacker
cd ~/.hackeros/
sudo rm -rf hacker-shell
sudo rm -rf hacker-help
curl -L -o hacker-shell "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.1/hacker-shell"
curl -L -o hacker-help "https://github.com/HackerOS-Linux-System/Hacker-CLI-Tool/releases/download/v1.1/hacker-help"
sudo chmod a+x hacker-help
sudo chmod a+x hacker-shell
cd hacker-lang
cd bin
sudo rm -rf hacker-compiler
sudo rm -rf hacker-parser
sudo rm -rf hacker-editor
curl -L -o hacker-compiler "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v0.0.8/hacker-compiler"
curl -L -o hacker-library "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v0.0.8/hacker-parser"
sudo chmod a+x hacker-library
sudo chmod a+x hacker-compiler
cd /usr/bin/
sudo rm -rf hackerc
curl -L -o hackerc "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v0.0.8/hackerc"
curl -L -o hacker-editor "https://github.com/HackerOS-Linux-System/Hacker-Lang/releases/download/v0.0.8/hacker-editor"
sudo chmod a+x hackerc 
cd ~
echo "[INFO] updated complete"
