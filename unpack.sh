#!/bin/bash

#Sudo Mode
sudo su

# Daj uprawnienia do wykonywania dla samego siebie
chmod a+x "$0"

# Sprawdź, czy katalog źródłowy istnieje
if [ ! -d "/tmp/HackerOS-Updates/HackerOS/" ]; then
    echo "Error: Directory /tmp/HackerOS-Updates/HackerOS/ does not exist."
    exit 1
fi

# Usuń istniejący katalog /usr/share/HackerOS/
echo "Deleting /usr/share/HackerOS/..."
rm -rf /usr/share/HackerOS/

# Przenieś katalog do /usr/share/
echo "Moving new HackerOS directory to /usr/share/..."

#HackerOS File Update
mv /tmp/HackerOS-Updates/HackerOS/ /usr/share/

#Permission Update
chmod a+x /usr/share/HackerOS/Scripts/Bin/hacker_mode.sh /usr/share/HackerOS/Scripts/Bin/Hacker-Mode-Update.sh /usr/share/HackerOS/Scripts/Bin/Hacker-Unpack.sh /usr/share/HackerOS/Scripts/Bin/Hacker-Update.sh /usr/share/HackerOS/Scripts/Bin/HackerOS-Documentation.sh /usr/share/HackerOS/Scripts/Bin/HackerOS-TV.sh /usr/share/HackerOS/Scripts/Bin/install-penetration-tools.sh /usr/share/HackerOS/Scripts/Bin/install-tools.sh /usr/share/HackerOS/Scripts/Bin/revert_to_plasma.sh /usr/share/HackerOS/Scripts/Bin/Switch_To_Other_Session.sh /usr/share/HackerOS/Scripts/Bin/update_system.sh  /usr/share/HackerOS/Scripts/Bin/Proton-Updater.sh /usr/share/HackerOS/Scripts/Bin/Hacker-Update-Files.sh /usr/share/HackerOS/Scripts/Steam/HackerOS-Steam.sh /usr/share/HackerOS/Scripts/Steam/HackerOS-Steam-Animation.sh /usr/share/HackerOS/Scripts/Steam/HackerOS-Steam-For-Hacker-Mode.sh /usr/share/HackerOS/Scripts/Bin/update.sh /usr/share/HackerOS/Scripts/Bin/hacker-install-gamescope-steam.sh /usr/share/HackerOS/Scripts/Bin/Penetration-Mode.sh

echo "Updating bash"
mv /usr/share/HackerOS/Config-Files/bash.bashrc /etc/

echo "Updating Hacker Mode and HackerOS TV"

#Updating HackerOS TV
cd /usr/share/HackerOS/Scripts/HackerOS-Apps/HackerOS-TV/
npm insttall

# Updating Hacker Mode
cd /usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Mode/
npm install

#Updating Penetration Mode
cd /usr/share/HackerOS/Scripts/HackerOS-Apps/Penetration-Mode/
npm install

#exiting from sudo mode
exit

echo "The operation was completed successfully."
