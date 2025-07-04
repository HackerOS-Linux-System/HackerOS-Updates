#!/bin/bash

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Informacje o użytkowniku i ścieżki
USER_NAME=$(whoami)
PREFERENCES="/home/$USER_NAME/.hackeros/Preferences.txt"
LOG="/tmp/hacker.log"

# Repozytoria pakietów
declare -A repos=(
    ["penetration-mode"]="https://github.com/HackerOS-Linux-System/Penetration-Mode.git"
    ["hacker-mode"]="https://github.com/HackerOS-Linux-System/Hacker-Mode.git"
    ["developer-mode"]="https://github.com/HackerOS-Linux-System/Developer-Mode.git"
    ["hackeros-tv"]="https://github.com/HackerOS-Linux-System/HackerOS-TV.git"
    ["hacker-unpack"]="https://github.com/HackerOS-Linux-System/Hacker-Unpack.git"
    ["hacker-menu"]="https://github.com/HackerOS-Linux-System/Hacker-Menu.git"
    ["gamescope-session-steam"]="https://github.com/HackerOS-Linux-System/gamescope-session-steam.git"
)

# Ścieżki docelowe pakietów
declare -A paths=(
    ["penetration-mode"]="/usr/share/HackerOS/Scripts/HackerOS-Apps/Penetration-Mode/"
    ["hacker-mode"]="/usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Mode/"
    ["developer-mode"]="/usr/share/HackerOS/Scripts/HackerOS-Apps/Developer-Mode/"
    ["hackeros-tv"]="/usr/share/HackerOS/Scripts/HackerOS-Apps/HackerOS-TV/"
    ["hacker-unpack"]="/usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Unpack/"
    ["hacker-menu"]="/usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Menu/"
    ["gamescope-session-steam"]="/tmp/gamescope-session-steam/"
)

# Funkcja wyświetlania banera
print_banner() {
    echo -e "${CYAN}╭──────────────────────────────────────────────────────────────╮${RESET}"
    echo -e "${WHITE}│ HackerOS Package Manager v1.6 - $(date '+%Y-%m-%d %H:%M:%S') │${RESET}"
    echo -e "${CYAN}╰──────────────────────────────────────────────────────────────╯${RESET}"
    echo
}

# Funkcja wyświetlania separatora
print_separator() {
    echo -e "${CYAN}┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈${RESET}"
}

# Funkcja logowania
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

# Funkcja animacji postępu
progress_bar() {
    local operation="$1"
    local width=50
    local progress=0
    local step=$((100 / width))
    local filled empty
    local spinner=('⠁' '⠉' '⠙' '⠚' '⠒' '⠂' '⠄' '⠤' '⠦' '⠧')
    local spin_idx=0
    local fill_char
    local operation_name
    case "$operation" in
        install|install_app|nvidia-dkms|emulator|cybersecurity|gaming|gaming-no-roblox|add-ons|dev-tools|freedownloadmanager|cisco-packet-tracer)
            fill_char="╸"
            operation_name="${operation^} Installation"
            ;;
        fast-update)
            fill_char="━"
            operation_name="System Update"
            ;;
        check-updates)
            fill_char="━"
            operation_name="Update Check"
            ;;
        menu|cockpit)
            fill_char="╺"
            operation_name="${operation^} Launch"
            ;;
        *)
            fill_char="╺"
            operation_name="Operation"
            ;;
    esac
    while [ $progress -le 100 ]; do
        filled=$((progress / step))
        empty=$((width - filled))
        printf "${CYAN}%s %s [%${filled}s%${empty}s] %3d%%${RESET}\r" "${spinner[spin_idx]}" "$operation_name" "$(printf '%*s' $filled | tr ' ' "$fill_char")" ""
        spin_idx=$(( (spin_idx + 1) % 10 ))
        progress=$((progress + 1))
        sleep 0.007
    done
    echo -e "${CYAN}✔ %s [%${width}s] 100% [Completed]${RESET}" "$operation_name" "$(printf '%*s' $width | tr ' ' "$fill_char")"
    echo
}

# Funkcja wyświetlania komunikatów statusu
print_status() {
    echo -e "${GREEN}[OK] $1 [$(date '+%H:%M:%S')]${RESET}"
}

# Funkcja wyświetlania błędów
print_error() {
    echo -e "${RED}[ERROR] $1 [$(date '+%H:%M:%S')]${RESET}"
}

# Funkcja wyświetlania informacji
print_info() {
    echo -e "${BLUE}[INFO] $1${RESET}"
}

# Funkcja aktualizacji Preferences.txt
update_preferences() {
    local app="$1"
    local action="$2" # install or remove

    mkdir -p "$(dirname "$PREFERENCES")"
    touch "$PREFERENCES"

    if [ "$action" = "install" ]; then
        # Usuwanie wpisu z Preferences.txt, jeśli istnieje
        if grep -Fx "$app" "$PREFERENCES" > /dev/null; then
            sed -i "/^$app$/d" "$PREFERENCES"
            print_info "Usunięto $app z $PREFERENCES"
            log "Removed $app from $PREFERENCES"
        fi
    elif [ "$action" = "remove" ]; then
        # Dodawanie wpisu do Preferences.txt, jeśli nie istnieje
        if ! grep -Fx "$app" "$PREFERENCES" > /dev/null; then
            echo "$app" >> "$PREFERENCES"
            print_info "Dodano $app do $PREFERENCES"
            log "Added $app to $PREFERENCES"
        fi
    fi
}

# Funkcja pomocy
print_help() {
    print_banner
    echo -e "${WHITE}╭── Komendy systemowe ──╮${RESET}"
    printf "${YELLOW}  %-30s %-60s %-30s\n${RESET}" "Komenda" "Opis" "Przyklad"
    printf "${CYAN}  %-30s %-60s %-30s\n${RESET}" "──────────────────────────────" "────────────────────────────────────────────────────────────" "──────────────────────────────"
    printf "  %-30s %-60s %-30s\n" "hacker install {app}" "Instaluje pakiet lub zestaw narzedzi" "hacker install nvidia-dkms"
    printf "  %-30s %-60s %-30s\n" "hacker remove {app}" "Usuwa pakiet" "hacker remove hacker-mode"
    printf "  %-30s %-60s %-30s\n" "hacker sys-logs" "Wyswietla logi systemowe" "hacker sys-logs"
    printf "  %-30s %-60s %-30s\n" "hacker fast-update" "Uruchamia aktualizacje systemu" "hacker fast-update"
    printf "  %-30s %-60s %-30s\n" "hacker check-updates" "Sprawdza dostepne aktualizacje" "hacker check-updates"
    print_separator

    echo -e "${WHITE}╭── Komendy narzedziowe ──╮${RESET}"
    printf "${YELLOW}  %-30s %-60s %-30s\n${RESET}" "Komenda" "Opis" "Przyklad"
    printf "${CYAN}  %-30s %-60s %-30s\n${RESET}" "──────────────────────────────" "────────────────────────────────────────────────────────────" "──────────────────────────────"
    printf "  %-30s %-60s %-30s\n" "hacker menu" "Uruchamia interfejs menu HackerOS (Ruby)" "hacker menu"
    printf "  %-30s %-60s %-30s\n" "hacker cockpit" "Uruchamia HackerOS Cockpit (Python, otwiera 0.0.0.0:4545)" "hacker cockpit"
    printf "  %-30s %-60s %-30s\n" "hacker help" "Wyswietla te pomoc" "hacker help"
    print_separator

    echo -e "${WHITE}╭── Pakiety: Tryby systemowe ──╮${RESET}"
    printf "${YELLOW}  %-20s %-60s\n${RESET}" "Pakiet" "Opis"
    printf "${CYAN}  %-20s %-60s\n${RESET}" "────────────────────" "────────────────────────────────────────────────────────────"
    printf "  %-20s %-60s\n" "penetration-mode" "Tryb do testow penetracyjnych (konfiguracja Wayland)"
    printf "  %-20s %-60s\n" "hacker-mode" "Zaawansowany tryb IT (Steam, Lutris, Heroic Games)"
    printf "  %-20s %-60s\n" "developer-mode" "Srodowisko dla programistow (skrypty i narzedzia)"
    printf "  %-20s %-60s\n" "hackeros-tv" "Tryb multimedialny (optymalizacja Wayland/Sway)"
    print_separator

    echo -e "${WHITE}╭── Pakiety: Narzedzia ──╮${RESET}"
    printf "${YELLOW}  %-20s %-60s\n${RESET}" "Pakiet" "Opis"
    printf "${CYAN}  %-20s %-60s\n${RESET}" "────────────────────" "────────────────────────────────────────────────────────────"
    printf "  %-20s %-60s\n" "hacker-unpack" "Narzedzia do rozpakowywania i analizy plikow"
    printf "  %-20s %-60s\n" "hacker-menu" "Interfejs menu dla HackerOS (Ruby)"
    printf "  %-20s %-60s\n" "gamescope-session-steam" "Sesja Steam z Gamescope (optymalizacja grafiki)"
    printf "  %-20s %-60s\n" "cybersecurity" "Narzedzia bezpieczenstwa (nmap, wireshark, metasploit)"
    printf "  %-20s %-60s\n" "gaming" "Narzedzia dla graczy (Steam, Lutris, Discord)"
    printf "  %-20s %-60s\n" "gaming-no-roblox" "Narzedzia dla graczy bez wsparcia Roblox"
    printf "  %-20s %-60s\n" "add-ons" "Dodatki systemowe (Wine, Bottles, WineZGUI)"
    printf "  %-20s %-60s\n" "dev-tools" "Narzedzia programistyczne (Atom, VS Code)"
    printf "  %-20s %-60s\n" "emulator" "Emulatory konsol (shadPS4, Ryujinx, DOSBox-X)"
    printf "  %-20s %-60s\n" "nvidia-dkms" "Sterowniki NVIDIA DKMS v560 (utils, settings, prime)"
    printf "  %-20s %-60s\n" "freedownloadmanager" "Free Download Manager (pobieranie i instalacja .deb)"
    printf "  %-20s %-60s\n" "cisco-packet-tracer" "Cisco Packet Tracer (pobieranie i instalacja .deb)"
    print_separator

    echo -e "${WHITE}╭── Informacje ──╮${RESET}"
    printf "${BLUE}  %-20s %s\n${RESET}" "Uzytkownik:" "$USER_NAME"
    printf "${BLUE}  %-20s %s\n${RESET}" "Plik logow:" "$LOG"
    printf "${BLUE}  %-20s %s\n${RESET}" "Plik preferencji:" "$PREFERENCES"
    printf "${BLUE}  %-20s %s\n${RESET}" "Wersja:" "1.6"
    printf "${BLUE}  %-20s %s\n${RESET}" "Data:" "$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${YELLOW}Wpisz 'hacker install <pakiet>' lub 'hacker menu' aby rozpoczac${RESET}"
    echo
}

# Funkcja wyświetlania logów systemowych
sys_logs() {
    print_separator
    echo -e "${YELLOW}Logi systemowe${RESET}"
    print_separator
    if [ -f "$LOG" ]; then
        cat "$LOG"
        print_status "Wyswietlono logi systemowe"
    else
        print_error "Plik logow $LOG nie istnieje"
        log "Failed to display logs - file not found"
    fi
}

# Funkcja uruchamiania menu
hacker_menu() {
    local menu_script="/usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Menu/Hacker-Menu.rb"
    print_separator
    echo -e "${YELLOW}Uruchamianie HackerOS Menu${RESET}"
    print_separator
    progress_bar "menu"

    if [ -f "$menu_script" ]; then
        print_info "Uruchamianie $menu_script"
        ruby "$menu_script" &>> "$LOG"
        print_status "Menu HackerOS uruchomione"
        log "Launched HackerOS Menu"
    else
        print_error "Skrypt $menu_script nie istnieje"
        log "Failed to launch HackerOS Menu - script not found"
    fi
}

# Funkcja uruchamiania cockpit
hacker_cockpit() {
    local cockpit_script="/usr/share/HackerOS/Scripts/HackerOS-Apps/HackerOS-Cockpit/HackerOS_Cockpit.py"
    print_separator
    echo -e "${YELLOW}Uruchamianie HackerOS Cockpit${RESET}"
    print_separator
    progress_bar "cockpit"

    if [ -f "$cockpit_script" ]; then
        print_info "Uruchamianie $cockpit_script w tle"
        python3 "$cockpit_script" &>> "$LOG" &
        sleep 2
        print_info "Otwieranie http://0.0.0.0:4545 w Vivaldi"
        if command -v vivaldi >/dev/null 2>&1; then
            vivaldi "http://0.0.0.0:4545" &>> "$LOG" &
            print_status "HackerOS Cockpit uruchomiony i otwarty w Vivaldi"
            log "Launched HackerOS Cockpit and opened in Vivaldi"
        else
            print_error "Przegladarka Vivaldi nie jest zainstalowana"
            log "Failed to open HackerOS Cockpit - Vivaldi not found"
        fi
    else
        print_error "Skrypt $cockpit_script nie istnieje"
        log "Failed to launch HackerOS Cockpit - script not found"
    fi
}

# Funkcja instalacji sterowników NVIDIA
install_nvidia_dkms() {
    print_separator
    echo -e "${YELLOW}Instalowanie sterownikow NVIDIA${RESET}"
    print_separator
    progress_bar "nvidia-dkms"

    print_info "Aktualizacja repozytoriow APT"
    sudo apt update
    print_info "Instalowanie nvidia-dkms-560, nvidia-utils-560, nvidia-settings, nvidia-prime"
    sudo apt install -y nvidia-dkms-560 nvidia-utils-560 nvidia-settings nvidia-prime &>> "$LOG"

    print_status "Sterowniki NVIDIA zainstalowane"
    log "Installed NVIDIA drivers"
}

# Funkcja instalacji emulatorów
install_emulator() {
    print_separator
    echo -e "${YELLOW}Instalowanie emulatorow${RESET}"
    print_separator
    progress_bar "emulator"

    print_info "Aktualizacja repozytoriow APT"
    sudo apt update
    print_info "Instalowanie emulatorow z Flatpak i Snap"
    flatpak install flathub io.github.shadps4_emu.shadPS4 -y &>> "$LOG"
    flatpak install flathub org.ryujinx.Ryujinx -y &>> "$LOG"
    flatpak install flathub com.dosbox_x.DOSBox-X -y &>> "$LOG"
    sudo snap install rpcs3-emu &>> "$LOG"

    print_status "Emulatory zainstalowane"
    log "Installed Emulators"
}

# Funkcja instalacji Free Download Manager
install_freedownloadmanager() {
    print_separator
    echo -e "${YELLOW}Instalowanie Free Download Manager${RESET}"
    print_separator
    progress_bar "freedownloadmanager"

    print_info "Pobieranie najnowszego pakietu .deb Free Download Manager"
    wget -O /tmp/fdm.deb "https://www.freedownloadmanager.org/download.htm?file=fdm.deb" &>> "$LOG"
    if [ -f "/tmp/fdm.deb" ]; then
        print_info "Instalowanie pakietu Free Download Manager"
        sudo dpkg -i /tmp/fdm.deb &>> "$LOG"
        sudo apt install -f -y &>> "$LOG"
        rm /tmp/fdm.deb
        print_status "Free Download Manager zainstalowany"
        log "Installed Free Download Manager"
    else
        print_error "Nie udało się pobrać pakietu Free Download Manager"
        log "Failed to download Free Download Manager package"
        exit 1
    fi
}

# Funkcja instalacji Cisco Packet Tracer
install_cisco_packet_tracer() {
    print_separator
    echo -e "${YELLOW}Instalowanie Cisco Packet Tracer${RESET}"
    print_separator
    progress_bar "cisco-packet-tracer"

    print_info "Pobieranie najnowszego pakietu .deb Cisco Packet Tracer"
    wget -O /tmp/cisco-packet-tracer.deb "https://www.netacad.com/portal/resources/packet-tracer" &>> "$LOG"
    if [ -f "/tmp/cisco-packet-tracer.deb" ]; then
        print_info "Instalowanie pakietu Cisco Packet Tracer"
        sudo dpkg -i /tmp/cisco-packet-tracer.deb &>> "$LOG"
        sudo apt install -f -y &>> "$LOG"
        rm /tmp/cisco-packet-tracer.deb
        print_status "Cisco Packet Tracer zainstalowany"
        log "Installed Cisco Packet Tracer"
    else
        print_error "Nie udało się pobrać pakietu Cisco Packet Tracer"
        log "Failed to download Cisco Packet Tracer package"
        exit 1
    fi
}

# Funkcja szybkiej aktualizacji
fast_update() {
    local update_script="/usr/share/HackerOS/Scripts/Bin/updates.sh"
    print_separator
    echo -e "${YELLOW}Szybka aktualizacja systemu${RESET}"
    print_separator
    progress_bar "fast-update"

    if [ -f "$update_script" ]; then
        print_info "Uruchamianie $update_script"
        sudo chmod +x "$update_script" &>> "$LOG"
        sudo "$update_script" &>> "$LOG"
        print_status "Aktualizacja systemu zakonczona"
        log "Fast update completed"
    else
        print_error "Skrypt $update_script nie istnieje"
        log "Fast update failed - script not found"
    fi
}

# Funkcja sprawdzania aktualizacji
check_updates() {
    local check_script="/usr/share/HackerOS/Scripts/Bin/check_updates_notify.sh"
    print_separator
    echo -e "${YELLOW}Sprawdzanie aktualizacji${RESET}"
    print_separator
    progress_bar "check-updates"

    if [ -f "$check_script" ]; then
        print_info "Uruchamianie $check_script"
        sudo chmod +x "$check_script" &>> "$LOG"
        sudo "$check_script" &>> "$LOG"
        print_status "Sprawdzanie aktualizacji zakonczone"
        log "Check updates completed"
    else
        print_error "Skrypt $check_script nie istnieje"
        log "Check updates failed - script not found"
    fi
}

# Funkcja sprawdzania i instalowania brakujących pakietów dla hacker-mode
check_and_install_hacker_mode_deps() {
    print_separator
    echo -e "${YELLOW}Sprawdzanie zaleznosci hacker-mode${RESET}"
    print_separator
    progress_bar "hacker-mode-deps"

    local missing_deps=()
    print_info "Weryfikacja pakietow APT"
    dpkg -l | grep -q steam || missing_deps+=("steam")
    dpkg -l | grep -q lutris || missing_deps+=("lutris")
    dpkg -l | grep -q gamehub || missing_deps+=("gamehub")

    print_info "Weryfikacja pakietow Flatpak"
    flatpak list | grep -q com.heroicgameslauncher.hgl || missing_deps+=("com.heroicgameslauncher.hgl")
    flatpak list | grep -q com.hyperplay.hyperplay || missing_deps+=("com.hyperplay.hyperplay")

    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_status "Wszystkie zaleznosci hacker-mode sa zainstalowane"
        log "All hacker-mode dependencies already installed"
    else
        print_info "Instalowanie brakujacych pakietow: ${missing_deps[*]}"
        progress_bar "install-deps"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                steam|lutris|gamehub)
                    print_info "Instalowanie $dep z APT"
                    sudo apt update
                    sudo apt install -y "$dep" &>> "$LOG"
                    print_status "Zainstalowano $dep"
                    ;;
                com.heroicgameslauncher.hgl)
                    flatpak install flathub com.heroicgameslauncher.hgl -y &>> "$LOG"
                    print_status "Zainstalowano Heroic Games Launcher"
                    ;;
                com.hyperplay.hyperplay)
                    flatpak install flathub com.hyperplay.hyperplay -y &>> "$LOG"
                    print_status "Zainstalowano HyperPlay"
                    ;;
            esac
        done
        print_status "Zainstalowano wszystkie zaleznosci hacker-mode"
        log "Installed missing hacker-mode dependencies"
    fi
}

# Funkcja instalacji pakietów GitHub
install_app() {
    app="$1"
    repo="${repos[$app]}"
    path="${paths[$app]}"

    if [ -z "$repo" ] || [ -z "$path" ]; then
        print_error "Nieznany pakiet: $app"
        log "Install failed - unknown app $app"
        exit 1
    fi

    print_separator
    echo -e "${YELLOW}Instalowanie pakietu: $app${RESET}"
    print_separator
    progress_bar "install-app"

    if [ "$app" == "gamescope-session-steam" ]; then
        print_info "Pobieranie $app z $repo"
        rm -rf /tmp/gamescope-session-steam
        git clone "$repo" /tmp/gamescope-session-steam &>> "$LOG"
        cd /tmp/gamescope-session-steam
        if [ -f "install.sh" ]; then
            print_info "Uruchamianie install.sh"
            sudo chmod +x install.sh &>> "$LOG"
            sudo ./install.sh &>> "$LOG"
            print_status "Pakiet $app zainstalowany"
            log "Installed $app"
            update_preferences "$app" "install"
        else
            print_error "Brak pliku install.sh w $app"
            log "Install failed - missing install.sh for $app"
            exit 1
        fi
    else
        print_info "Pobieranie $app z $repo"
        rm -rf /tmp/$app
        git clone "$repo" /tmp/$app &>> "$LOG"
        sudo rm -rf "$path"
        sudo mkdir -p "$path"
        sudo mv /tmp/$app/* "$path" &>> "$LOG"

        if [ -f "$path/package.json" ]; then
            print_info "Instalowanie zaleznosci npm w $path"
            cd "$path"
            sudo npm install &>> "$LOG"
        fi

        if [ "$app" == "hacker-mode" ]; then
            check_and_install_hacker_mode_deps
        fi

        if [[ "$app" == "penetration-mode" || "$app" == "hacker-mode" || "$app" == "hackeros-tv" ]]; then
            if [ ! -d "/tmp/HackerOS-Updates" ]; then
                print_info "Pobieranie HackerOS-Updates"
                git clone https://github.com/HackerOS-Linux-System/HackerOS-Updates.git /tmp/HackerOS-Updates &>> "$LOG"
            else
                print_status "HackerOS-Updates juz pobrane"
            fi

            if [ "$app" == "penetration-mode" ]; then
                sudo cp /tmp/HackerOS-Updates/Config-Files/Penetration-Mode.desktop /usr/share/wayland-sessions/
                sudo cp /tmp/HackerOS-Updates/Config-Files/config2 /etc/skel/
            elif [ "$app" == "hacker-mode" ]; then
                sudo cp /tmp/HackerOS-Updates/Config-Files/Hacker-Mode.desktop /usr/share/wayland-sessions/
                sudo cp /tmp/HackerOS-Updates/Config-Files/config /etc/sway/
            elif [ "$app" == "hackeros-tv" ]; then
                sudo cp /tmp/HackerOS-Updates/Config-Files/HackerOS-TV.desktop /usr/share/wayland-sessions/
                sudo cp /tmp/HackerOS-Updates/Config-Files/config1 /etc/sway/
            fi
            update_preferences "$app" "install"
        fi

        print_status "Pakiet $app zainstalowany"
        log "Installed $app"
    fi
}

# Funkcja usuwania pakietów
remove_app() {
    app="$1"
    path="${paths[$app]}"

    if [ -z "$path" ]; then
        print_error "Nieznany pakiet: $app"
        log "Remove failed - unknown app $app"
        exit 1
    fi

    print_separator
    echo -e "${YELLOW}Usuwanie pakietu: $app${RESET}"
    print_separator
    progress_bar "remove-app"

    if [ -d "$path" ]; then
        sudo rm -rf "$path" &>> "$LOG"
        print_status "Pakiet $app usunięty"
        log "Removed $app"
        if [[ "$app" == "penetration-mode" || "$app" == "hacker-mode" || "$app" == "hackeros-tv" ]]; then
            update_preferences "$app" "remove"
        fi
    else
        print_error "Pakiet $app nie jest zainstalowany"
        log "Remove failed - $app not installed"
    fi
}

# Funkcje instalacji trybów narzędziowych
install_cybersecurity() {
    print_separator
    echo -e "${YELLOW}Instalowanie Cybersecurity Tools${RESET}"
    print_separator
    progress_bar "cybersecurity"

    print_info "Aktualizacja repozytoriow APT"
    sudo apt update
    sudo apt install -y nmap wireshark nikto john hydra aircrack-ng sqlmap ettercap-text-only tcpdump zmap bettercap wfuzz hashcat fail2ban rkhunter chkrootkit lynis clamav tor proxychains4 httrack sublist3r macchanger inxi htop openvas openvpn metasploit-framework &>> "$LOG"

    print_info "Instalowanie metasploit-framework z Snap"
    sudo snap install metasploit-framework &>> "$LOG"
    print_info "Instalowanie Ghidra z Flatpak"
    flatpak install flathub org.ghindra.Ghindra -y &>> "$LOG"

    print_status "Cybersecurity Tools zainstalowane"
    log "Installed Cybersecurity Tools"
}

install_gaming() {
    print_separator
    echo -e "${YELLOW}Instalowanie Gaming Tools${RESET}"
    print_separator
    progress_bar "gaming"

    print_info "Aktualizacja repozytoriow APT"
    sudo apt update
    sudo apt install -y steam lutris obs-studio &>> "$LOG"

    print_info "Instalowanie pakietow z Flatpak"
    flatpak install flathub com.heroicgameslauncher.hgl -y &>> "$LOG"
    flatpak install flathub com.hyperplay.hyperplay -y &>> "$LOG"
    flatpak install flathub com.github.PikaTorrent.PikaTorrent -y &>> "$LOG"
    flatpak install flathub com.discordapp.Discord -y &>> "$LOG"
    flatpak install flathub com.github.Matoking.Protontricks -y &>> "$LOG"
    flatpak install flathub dev.coder5460.Sober -y &>> "$LOG"
    flatpak install flathub com.github.vinegarhq.Vinegar -y &>> "$LOG"

    print_status "Gaming Tools zainstalowane"
    log "Installed Gaming Tools"
}

install_gaming_no_roblox() {
    print_separator
    echo -e "${YELLOW}Instalowanie Gaming Tools (bez Roblox)${RESET}"
    print_separator
    progress_bar "gaming-no-roblox"

    print_info "Aktualizacja repozytoriow APT"
    sudo apt update
    sudo apt install -y steam lutris obs-studio &>> "$LOG"

    print_info "Instalowanie pakietow z Flatpak"
    flatpak install flathub com.heroicgameslauncher.hgl -y &>> "$LOG"
    flatpak install flathub com.hyperplay.hyperplay -y &>> "$LOG"
    flatpak install flathub com.github.PikaTorrent.PikaTorrent -y &>> "$LOG"
    flatpak install flathub com.discordapp.Discord -y &>> "$LOG"
    flatpak install flathub com.github.Matoking.Protontricks -y &>> "$LOG"

    print_status "Gaming Tools (bez Roblox) zainstalowane"
    log "Installed Gaming Tools no Roblox"
}

install_addons() {
    print_separator
    echo -e "${YELLOW}Instalowanie Add-ons${RESET}"
    print_separator
    progress_bar "add-ons"

    print_info "Aktualizacja repozytoriow APT"
    sudo apt update
    sudo apt install -y wine winetricks &>> "$LOG"

    print_info "Instalowanie pakietow z Flatpak"
    flatpak install flathub org.gnome.Boxes -y &>> "$LOG"
    flatpak install flathub com.usebottles.bottles -y &>> "$LOG"
    flatpak install flathub com.github.zocker_160.WineZGUI -y &>> "$LOG"

    print_status "Add-ons zainstalowane"
    log "Installed Add-ons"
}

install_dev_tools() {
    print_separator
    echo -e "${YELLOW}Instalowanie Dev Tools${RESET}"
    print_separator
    progress_bar "dev-tools"

    print_info "Instalowanie pakietow z Flatpak"
    flatpak install flathub io.atom.Atom -y &>> "$LOG"
    flatpak install flathub com.visualstudio.code -y &>> "$LOG"

    print_status "Dev Tools zainstalowane"
    log "Installed Dev Tools"
}

# Główna logika
print_banner

case "$1" in
    install)
        case "$2" in
            cybersecurity)
                install_cybersecurity
                ;;
            gaming)
                install_gaming
                ;;
            gaming-no-roblox)
                install_gaming_no_roblox
                ;;
            add-ons)
                install_addons
                ;;
            dev-tools)
                install_dev_tools
                ;;
            emulator)
                install_emulator
                ;;
            nvidia-dkms)
                install_nvidia_dkms
                ;;
            freedownloadmanager)
                install_freedownloadmanager
                ;;
            cisco-packet-tracer)
                install_cisco_packet_tracer
                ;;
            *)
                install_app "$2"
                ;;
        esac
        ;;
    remove)
        remove_app "$2"
        ;;
    sys-logs)
        sys_logs
        ;;
    fast-update)
        fast_update
        ;;
    check-updates)
        check_updates
        ;;
    menu)
        hacker_menu
        ;;
    cockpit)
        hacker_cockpit
        ;;
    help)
        print_help
        ;;
    *)
        echo -e "${CYAN}HackerOS Package Manager${RESET}"
        print_separator
        echo -e "${WHITE}Uzycie:${RESET}"
        printf "  %-30s %s\n" "hacker install {app}" "Instaluje pakiet lub zestaw narzedzi"
        printf "  %-30s %s\n" "hacker remove {app}" "Usuwa pakiet"
        printf "  %-30s %s\n" "hacker sys-logs" "Wyswietla logi systemowe"
        printf "  %-30s %s\n" "hacker fast-update" "Uruchamia aktualizacje systemu"
        printf "  %-30s %s\n" "hacker check-updates" "Sprawdza dostepne aktualizacje"
        printf "  %-30s %s\n" "hacker menu" "Uruchamia interfejs menu HackerOS"
        printf "  %-30s %s\n" "hacker cockpit" "Uruchamia HackerOS Cockpit"
        printf "  %-30s %s\n" "hacker help" "Wyswietla pomoc"
        echo -e "${YELLOW}Wpisz 'hacker help' dla listy pakietow i komend${RESET}"
        print_separator
        ;;
esac
