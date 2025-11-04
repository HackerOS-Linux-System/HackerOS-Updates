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
curl -L -o Hacker_Launcher "https://github.com/HackerOS-Linux-System/Hacker-Launcher/releases/download/v0.4/Hacker-Launcher"
curl -L -o Hacker-Mode "https://github.com/HackerOS-Linux-System/Hacker-Mode/releases/download/v0.8/Hacker-Mode"
curl -L -o HackerOS-Welcome "https://github.com/HackerOS-Linux-System/HackerOS-Welcome/releases/download/v0.1/HackerOS-Welcome"
sudo chmod a+x Hacker_Launcher
sudo chmod a+x Hacker-Mode
sudo chmod a+x HackerOS-Welcome
sudo chmod a+x HackerOS-Game-Mode.AppImage
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
cd ~
echo "[INFO] updated complete"
