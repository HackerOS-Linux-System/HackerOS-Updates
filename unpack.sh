#!/bin/bash

# Daj uprawnienia do wykonywania dla samego siebie
chmod a+x "$0"

# Sprawdź, czy katalog źródłowy istnieje
if [ ! -d "/tmp/HackerOS-Updates/HackerOS/" ]; then
    echo "Error: Directory /tmp/HackerOS-Updates/HackerOS/ does not exist."
    exit 1
fi

# Usuń istniejący katalog /usr/share/HackerOS/
echo "Deleting /usr/share/HackerOS/..."
sudo rm -rf /usr/share/HackerOS/

# Przenieś katalog do /usr/share/
echo "Moving new HackerOS directory to /usr/share/..."
sudo mv /tmp/HackerOS-Updates/HackerOS/ /usr/share/
chmod a+x /usr/share/HackerOS/Scripts/Bin/hacker_mode.sh /usr/share/HackerOS/Scripts/Bin/Hacker-Mode-Update.sh /usr/share/HackerOS/Scripts/Bin/Hacker-Unpack.sh /usr/share/HackerOS/Scripts/Bin/Hacker-Update.sh /usr/share/HackerOS/Scripts/Bin/HackerOS-Documentation.sh /usr/share/HackerOS/Scripts/Bin/HackerOS-TV.sh /usr/share/HackerOS/Scripts/Bin/install-penetration-tools.sh /usr/share/HackerOS/Scripts/Bin/install-tools.sh /usr/share/HackerOS/Scripts/Bin/revert_to_plasma.sh /usr/share/HackerOS/Scripts/Bin/Switch_To_Other_Session.sh /usr/share/HackerOS/Scripts/Bin/update_system.sh  usr/share/HackerOS/Scripts/Bin/Proton-Updater.sh 

echo "Updating HackerOS TV and Hacker Mode"
cd /usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Mode/
npm install


echo "The operation was completed successfully."
