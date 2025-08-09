#!/usr/bin/env bash

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

USER_NAME=$(whoami)
PREF_FILE="/home/$USER_NAME/.hackeros/Preferences.txt"
APPS_DIR="/usr/share/HackerOS/Scripts/HackerOS-Apps"

# Sudo Mode
sudo su

# Daj uprawnienia do wykonywania dla samego siebie
chmod a+x "$0"

# Sprawdź, czy katalog źródłowy istnieje
if [ ! -d "/tmp/HackerOS-Updates/HackerOS/" ]; then
    echo -e "${RED}Brak katalogu /tmp/HackerOS-Updates/HackerOS/. Przerywam.${RESET}"
    exit 1
fi

# Usuń istniejący katalog /usr/share/HackerOS/
rm -rf /usr/share/HackerOS/

#Update files in /bin
mv /tmp/HackerOS-Updates/Config-Files/hacker /bin/
chmod a+x /bin/hacker
mv /tmp/HackerOS-Updates/Config-Files/hacker-update /bin
chmod a+x /bin/hacker-update
#Update bash.bashrc
mv /tmp/HackerOS-Updates/Config-Files/bash.bashrc /etc/

mv /tmp/HackerOS-Updates/HackerOS/ /usr/share

# Permission Update
chmod a+x /usr/share/HackerOS/Scripts/Bin/* \
/usr/share/HackerOS/Scripts/Steam/*


#Update HackerOS apps
cd /usr/share/HackerOS/Scripts/HackerOS-Apps/HackerOS-TV/ && npm install

cd /usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Mode/ && npm install

cd /usr/share/HackerOS/Scripts/HackerOS-Apps/Penetration-Mode/ && npm install

if [ -f "$PREF_FILE" ] && [ -s "$PREF_FILE" ]; then
    echo -e "${CYAN}[UNPACK] Usuwanie aplikacji wg Preferences.txt...${RESET}"
    while IFS= read -r app; do
        case $app in
            penetration-mode)
                echo -e "${YELLOW}[REMOVE] penetration-mode...${RESET}"
                rm -rf "$APPS_DIR/Penetration-Mode"
                ;;
            hacker-mode)
                echo -e "${YELLOW}[REMOVE] hacker-mode...${RESET}"
                rm -rf "$APPS_DIR/Hacker-Mode"
                ;;
            hackeros-tv)
                echo -e "${YELLOW}[REMOVE] hackeros-tv...${RESET}"
                rm -rf "$APPS_DIR/HackerOS-TV"
                ;;
            *)
                echo -e "${RED}[ERROR] Nieznana aplikacja: $app${RESET}"
                ;;
        esac
    done < "$PREF_FILE"
else
    echo -e "${CYAN}[UNPACK] Preferences.txt jest pusty lub nie istnieje. Nic do usunięcia.${RESET}"
fi

#exit from sudo mode
exit
