#!/bin/bash

# Kolory (rozszerzone dla lepszego wyglądu CLI)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
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
    echo -e "${CYAN}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    echo -e "${WHITE}${BOLD}┃ HackerOS Package Manager v1.7 - $(date '+%Y-%m-%d %H:%M:%S') ┃${RESET}"
    echo -e "${CYAN}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
    echo
}

# Funkcja wyświetlania separatora
print_separator() {
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

# Funkcja logowania
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

# Ulepszona funkcja animacji postępu
progress_bar() {
    local operation="$1"
    local width=50
    local progress=0
    local step=$((100 / width))
    local filled empty
    local spinner=('⣾' '⣷' '⣯' '⣟' '⡿' '⢿' '⣻' '⣽')
    local spin_idx=0
    local fill_char="█"
    local empty_char=" "
    local operation_name
    local color

    case "$operation" in
        install|install_app|nvidia-dkms|emulator|cybersecurity|gaming|gaming-no-roblox|add-ons|dev-tools|freedownloadmanager|cisco-packet-tracer)
            color="${GREEN}"
            operation_name="${operation^} Installation"
            ;;
        update|fast-update)
            color="${BLUE}"
            operation_name="System Update"
            ;;
        check-updates)
            color="${BLUE}"
            operation_name="Update Check"
            ;;
        menu|cockpit)
            color="${MAGENTA}"
            operation_name="${operation^} Launch"
            ;;
        remove)
            color="${RED}"
            operation_name="Package Removal"
            ;;
        *)
            color="${CYAN}"
            operation_name="Operation"
            ;;
    esac

    echo -e "${color}${BOLD}Starting $operation_name...${RESET}"
    while [ $progress -le 100 ]; do
        filled=$((progress / step))
        empty=$((width - filled))
        printf "${color}${BOLD}%s %s [%${filled}s%${empty}s] %3d%%\r${RESET}" "${spinner[spin_idx]}" "$operation_name" "$(printf '%*s' $filled | tr ' ' "$fill_char")" "$(printf '%*s' $empty | tr ' ' "$empty_char")"
        spin_idx=$(( (spin_idx + 1) % 8 ))
        progress=$((progress + 2))
        sleep 0.05
    done
    echo -e "${color}${BOLD}✔ $operation_name [$(printf '%*s' $width | tr ' ' "$fill_char")] 100% [Completed]${RESET}"
    echo
}

# Funkcja wyświetlania komunikatów statusu
print_status() {
    echo -e "${GREEN}${BOLD}✔ $1 [$(date '+%H:%M:%S')]${RESET}"
}

# Funkcja wyświetlania błędów
print_error() {
    echo -e "${RED}${BOLD}✘ $1 [$(date '+%H:%M:%S')]${RESET}"
}

# Funkcja wyświetlania informacji
print_info() {
    echo -e "${BLUE}${BOLD}ℹ $1${RESET}"
}

# Funkcja aktualizacji Preferences.txt
update_preferences() {
    local app="$1"
    local action="$2" # install or remove

    mkdir -p "$(dirname "$PREFERENCES")"
    touch "$PREFERENCES"

    if [ "$action" = "install" ]; then
        if grep -Fx "$app" "$PREFERENCES" > /dev/null; then
            sed -i "/^$app$/d" "$PREFERENCES"
            print_info "Usunięto $app z $PREFERENCES"
            log "Removed $app from $PREFERENCES"
        fi
    elif [ "$action" = "remove" ]; then
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
    echo -e "${WHITE}${BOLD}┃ System Commands ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "${YELLOW}${BOLD}  %-30s %-60s %-30s\n${RESET}" "Command" "Description" "Example"
    printf "${CYAN}${BOLD}  %-30s %-60s %-30s\n${RESET}" "──────────────────────────────" "────────────────────────────────────────────────────────────" "──────────────────────────────"
    printf "  %-30s %-60s %-30s\n" "hacker install {app}" "Installs a package or toolset" "hacker install nvidia-dkms"
    printf "  %-30s %-60s %-30s\n" "hacker remove {app}" "Removes a package" "hacker remove hacker-mode"
    printf "  %-30s %-60s %-30s\n" "hacker sys-logs" "Displays system logs" "hacker sys-logs"
    printf "  %-30s %-60s %-30s\n" "hacker update" "Performs full system update" "hacker update"
    printf "  %-30s %-60s %-30s\n" "hacker fast-update" "Performs quick system update" "hacker fast-update"
    printf "  %-30s %-60s %-30s\n" "hacker check-updates" "Checks for available updates" "hacker check-updates"
    print_separator

    echo -e "${WHITE}${BOLD}┃ Tool Commands ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "${YELLOW}${BOLD}  %-30s %-60s %-30s\n${RESET}" "Command" "Description" "Example"
    printf "${CYAN}${BOLD}  %-30s %-60s %-30s\n${RESET}" "──────────────────────────────" "────────────────────────────────────────────────────────────" "──────────────────────────────"
    printf "  %-30s %-60s %-30s\n" "hacker menu" "Launches HackerOS Menu (Ruby)" "hacker menu"
    printf "  %-30s %-60s %-30s\n" "hacker cockpit" "Launches HackerOS Cockpit (Python, opens 0.0.0.0:4545)" "hacker cockpit"
    printf "  %-30s %-60s %-30s\n" "hacker help" "Displays this help" "hacker help"
    print_separator

    echo -e "${WHITE}${BOLD}┃ Packages: System Modes ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "${YELLOW}${BOLD}  %-20s %-60s\n${RESET}" "Package" "Description"
    printf "${CYAN}${BOLD}  %-20s %-60s\n${RESET}" "────────────────────" "────────────────────────────────────────────────────────────"
    printf "  %-20s %-60s\n" "penetration-mode" "Penetration testing mode (Wayland configuration)"
    printf "  %-20s %-60s\n" "hacker-mode" "Advanced IT mode (Steam, Lutris, Heroic Games)"
    printf "  %-20s %-60s\n" "developer-mode" "Development environment (scripts and tools)"
    printf "  %-20s %-60s\n" "hackeros-tv" "Multimedia mode (Wayland/Sway optimization)"
    print_separator

    echo -e "${WHITE}${BOLD}┃ Packages: Tools ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "${YELLOW}${BOLD}  %-20s %-60s\n${RESET}" "Package" "Description"
    printf "${CYAN}${BOLD}  %-20s %-60s\n${RESET}" "────────────────────" "────────────────────────────────────────────────────────────"
    printf "  %-20s %-60s\n" "hacker-unpack" "Tools for unpacking and file analysis"
    printf "  %-20s %-60s\n" "hacker-menu" "HackerOS Menu interface (Ruby)"
    printf "  %-20s %-60s\n" "gamescope-session-steam" "Steam session with Gamescope (graphics optimization)"
    printf "  %-20s %-60s\n" "cybersecurity" "Security tools (nmap, wireshark, metasploit)"
    printf "  %-20s %-60s\n" "gaming" "Gaming tools (Steam, Lutris, Discord)"
    printf "  %-20s %-60s\n" "gaming-no-roblox" "Gaming tools without Roblox support"
    printf "  %-20s %-60s\n" "add-ons" "System add-ons (Wine, Bottles, WineZGUI)"
    printf "  %-20s %-60s\n" "dev-tools" "Development tools (Atom, VS Code)"
    printf "  %-20s %-60s\n" "emulator" "Console emulators (shadPS4, Ryujinx, DOSBox-X)"
    printf "  %-20s %-60s\n" "nvidia-dkms" "NVIDIA DKMS drivers v560 (utils, settings, prime)"
    printf "  %-20s %-60s\n" "freedownloadmanager" "Free Download Manager (download and install .deb)"
    printf "  %-20s %-60s\n" "cisco-packet-tracer" "Cisco Packet Tracer (download and install .deb)"
    print_separator

    echo -e "${WHITE}${BOLD}┃ Information ┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    printf "${BLUE}${BOLD}  %-20s %s\n${RESET}" "User:" "$USER_NAME"
    printf "${BLUE}${BOLD}  %-20s %s\n${RESET}" "Log File:" "$LOG"
    printf "${BLUE}${BOLD}  %-20s %s\n${RESET}" "Preferences File:" "$PREFERENCES"
    printf "${BLUE}${BOLD}  %-20s %s\n${RESET}" "Version:" "1.7"
    printf "${BLUE}${BOLD}  %-20s %s\n${RESET}" "Date:" "$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${YELLOW}${BOLD}Run 'hacker install <package>' or 'hacker menu' to start${RESET}"
    echo
}

# Funkcja wyświetlania logów systemowych
sys_logs() {
    print_separator
    echo -e "${YELLOW}${BOLD}System Logs${RESET}"
    print_separator
    if [ -f "$LOG" ]; then
        cat "$LOG"
        print_status "Displayed system logs"
    else
        print_error "Log file $LOG does not exist"
        log "Failed to display logs - file not found"
    fi
}

# Funkcja uruchamiania menu
hacker_menu() {
    local menu_script="/usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Menu/Hacker-Menu.rb"
    print_separator
    echo -e "${YELLOW}${BOLD}Launching HackerOS Menu${RESET}"
    print_separator
    progress_bar "menu"

    if [ -f "$menu_script" ]; then
        print_info "Running $menu_script"
        ruby "$menu_script" &>> "$LOG"
        print_status "HackerOS Menu launched"
        log "Launched HackerOS Menu"
    else
        print_error "Script $menu_script does not exist"
        log "Failed to launch HackerOS Menu - script not found"
    fi
}

# Funkcja uruchamiania cockpit
hacker_cockpit() {
    local cockpit_script="/usr/share/HackerOS/Scripts/HackerOS-Apps/HackerOS-Cockpit/HackerOS_Cockpit.py"
    print_separator
    echo -e "${YELLOW}${BOLD}Launching HackerOS Cockpit${RESET}"
    print_separator
    progress_bar "cockpit"

    if [ -f "$cockpit_script" ]; then
        print_info "Running $cockpit_script in background"
        python3 "$cockpit_script" &>> "$LOG" &
        sleep 2
        print_info "Opening http://0.0.0.0:4545 in Vivaldi"
        if command -v vivaldi >/dev/null 2>&1; then
            vivaldi "http://0.0.0.0:4545" &>> "$LOG" &
            print_status "HackerOS Cockpit launched and opened in Vivaldi"
            log "Launched HackerOS Cockpit and opened in Vivaldi"
        else
            print_error "Vivaldi browser is not installed"
            log "Failed to open HackerOS Cockpit - Vivaldi not found"
        fi
    else
        print_error "Script $cockpit_script does not exist"
        log "Failed to launch HackerOS Cockpit - script not found"
    fi
}

# Funkcja instalacji sterowników NVIDIA
install_nvidia_dkms() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing NVIDIA Drivers${RESET}"
    print_separator
    progress_bar "nvidia-dkms"

    print_info "Updating APT repositories"
    sudo apt update
    print_info "Installing nvidia-dkms-560, nvidia-utils-560, nvidia-settings, nvidia-prime"
    sudo apt install -y nvidia-dkms-560 nvidia-utils-560 nvidia-settings nvidia-prime &>> "$LOG"

    print_status "NVIDIA Drivers installed"
    log "Installed NVIDIA drivers"
}

# Funkcja instalacji emulatorów
install_emulator() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing Emulators${RESET}"
    print_separator
    progress_bar "emulator"

    print_info "Updating APT repositories"
    sudo apt update
    print_info "Installing emulators from Flatpak and Snap"
    flatpak install flathub io.github.shadps4_emu.shadPS4 -y &>> "$LOG"
    flatpak install flathub org.ryujinx.Ryujinx -y &>> "$LOG"
    flatpak install flathub com.dosbox_x.DOSBox-X -y &>> "$LOG"
    sudo snap install rpcs3-emu &>> "$LOG"

    print_status "Emulators installed"
    log "Installed Emulators"
}

# Funkcja instalacji Free Download Manager
install_freedownloadmanager() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing Free Download Manager${RESET}"
    print_separator
    progress_bar "freedownloadmanager"

    print_info "Downloading latest Free Download Manager .deb package"
    wget -O /tmp/fdm.deb "https://www.freedownloadmanager.org/download.htm?file=fdm.deb" &>> "$LOG"
    if [ -f "/tmp/fdm.deb" ]; then
        print_info "Installing Free Download Manager package"
        sudo dpkg -i /tmp/fdm.deb &>> "$LOG"
        sudo apt install -f -y &>> "$LOG"
        rm /tmp/fdm.deb
        print_status "Free Download Manager installed"
        log "Installed Free Download Manager"
    else
        print_error "Failed to download Free Download Manager package"
        log "Failed to download Free Download Manager package"
        exit 1
    fi
}

# Funkcja instalacji Cisco Packet Tracer
install_cisco_packet_tracer() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing Cisco Packet Tracer${RESET}"
    print_separator
    progress_bar "cisco-packet-tracer"

    print_info "Downloading latest Cisco Packet Tracer .deb package"
    wget -O /tmp/cisco-packet-tracer.deb "https://www.netacad.com/portal/resources/packet-tracer" &>> "$LOG"
    if [ -f "/tmp/cisco-packet-tracer.deb" ]; then
        print_info "Installing Cisco Packet Tracer package"
        sudo dpkg -i /tmp/cisco-packet-tracer.deb &>> "$LOG"
        sudo apt install -f -y &>> "$LOG"
        rm /tmp/cisco-packet-tracer.deb
        print_status "Cisco Packet Tracer installed"
        log "Installed Cisco Packet Tracer"
    else
        print_error "Failed to download Cisco Packet Tracer package"
        log "Failed to download Cisco Packet Tracer package"
        exit 1
    fi
}

# Funkcja pełnej aktualizacji
update() {
    local update_script="/usr/share/HackerOS/Scripts/Bin/Hacker-Update.sh"
    print_separator
    echo -e "${YELLOW}${BOLD}Performing Full System Update${RESET}"
    print_separator
    progress_bar "update"

    if [ -f "$update_script" ]; then
        print_info "Running $update_script"
        sudo chmod +x "$update_script" &>> "$LOG"
        sudo "$update_script" &>> "$LOG"
        print_status "Full system update completed"
        log "Full system update completed"
    else
        print_error "Script $update_script does not exist"
        log "Full update failed - script not found"
    fi
}

# Funkcja szybkiej aktualizacji
fast_update() {
    local update_script="/usr/share/HackerOS/Scripts/Bin/updates.sh"
    print_separator
    echo -e "${YELLOW}${BOLD}Performing Quick System Update${RESET}"
    print_separator
    progress_bar "fast-update"

    if [ -f "$update_script" ]; then
        print_info "Running $update_script"
        sudo chmod +x "$update_script" &>> "$LOG"
        sudo "$update_script" &>> "$LOG"
        print_status "Quick system update completed"
        log "Fast update completed"
    else
        print_error "Script $update_script does not exist"
        log "Fast update failed - script not found"
    fi
}

# Funkcja sprawdzania aktualizacji
check_updates() {
    local check_script="/usr/share/HackerOS/Scripts/Bin/check_updates_notify.sh"
    print_separator
    echo -e "${YELLOW}${BOLD}Checking for Updates${RESET}"
    print_separator
    progress_bar "check-updates"

    if [ -f "$check_script" ]; then
        print_info "Running $check_script"
        sudo chmod +x "$check_script" &>> "$LOG"
        sudo "$check_script" &>> "$LOG"
        print_status "Update check completed"
        log "Check updates completed"
    else
        print_error "Script $check_script does not exist"
        log "Check updates failed - script not found"
    fi
}

# Funkcja sprawdzania i instalowania brakujących pakietów dla hacker-mode
check_and_install_hacker_mode_deps() {
    print_separator
    echo -e "${YELLOW}${BOLD}Checking hacker-mode dependencies${RESET}"
    print_separator
    progress_bar "hacker-mode-deps"

    local missing_deps=()
    print_info "Verifying APT packages"
    dpkg -l | grep -q steam || missing_deps+=("steam")
    dpkg -l | grep -q lutris || missing_deps+=("lutris")
    dpkg -l | grep -q gamehub || missing_deps+=("gamehub")

    print_info "Verifying Flatpak packages"
    flatpak list | grep -q com.heroicgameslauncher.hgl || missing_deps+=("com.heroicgameslauncher.hgl")
    flatpak list | grep -q com.hyperplay.hyperplay || missing_deps+=("com.hyperplay.hyperplay")

    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_status "All hacker-mode dependencies are installed"
        log "All hacker-mode dependencies already installed"
    else
        print_info "Installing missing packages: ${missing_deps[*]}"
        progress_bar "install-deps"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                steam|lutris|gamehub)
                    print_info "Installing $dep from APT"
                    sudo apt update
                    sudo apt install -y "$dep" &>> "$LOG"
                    print_status "Installed $dep"
                    ;;
                com.heroicgameslauncher.hgl)
                    flatpak install flathub com.heroicgameslauncher.hgl -y &>> "$LOG"
                    print_status "Installed Heroic Games Launcher"
                    ;;
                com.hyperplay.hyperplay)
                    flatpak install flathub com.hyperplay.hyperplay -y &>> "$LOG"
                    print_status "Installed HyperPlay"
                    ;;
            esac
        done
        print_status "All hacker-mode dependencies installed"
        log "Installed missing hacker-mode dependencies"
    fi
}

# Funkcja instalacji pakietów GitHub
install_app() {
    app="$1"
    repo="${repos[$app]}"
    path="${paths[$app]}"

    if [ -z "$repo" ] || [ -z "$path" ]; then
        print_error "Unknown package: $app"
        log "Install failed - unknown app $app"
        exit 1
    fi

    print_separator
    echo -e "${YELLOW}${BOLD}Installing package: $app${RESET}"
    print_separator
    progress_bar "install-app"

    if [ "$app" == "gamescope-session-steam" ]; then
        print_info "Downloading $app from $repo"
        rm -rf /tmp/gamescope-session-steam
        git clone "$repo" /tmp/gamescope-session-steam &>> "$LOG"
        cd /tmp/gamescope-session-steam
        if [ -f "install.sh" ]; then
            print_info "Running install.sh"
            sudo chmod +x install.sh &>> "$LOG"
            sudo ./install.sh &>> "$LOG"
            print_status "Package $app installed"
            log "Installed $app"
            update_preferences "$app" "install"
        else
            print_error "Missing install.sh in $app"
            log "Install failed - missing install.sh for $app"
            exit 1
        fi
    else
        print_info "Downloading $app from $repo"
        rm -rf /tmp/$app
        git clone "$repo" /tmp/$app &>> "$LOG"
        sudo rm -rf "$path"
        sudo mkdir -p "$path"
        sudo mv /tmp/$app/* "$path" &>> "$LOG"

        if [ -f "$path/package.json" ]; then
            print_info "Installing npm dependencies in $path"
            cd "$path"
            sudo npm install &>> "$LOG"
        fi

        if [ "$app" == "hacker-mode" ]; then
            check_and_install_hacker_mode_deps
        fi

        if [[ "$app" == "penetration-mode" || "$app" == "hacker-mode" || "$app" == "hackeros-tv" ]]; then
            if [ ! -d "/tmp/HackerOS-Updates" ]; then
                print_info "Downloading HackerOS-Updates"
                git clone https://github.com/HackerOS-Linux-System/HackerOS-Updates.git /tmp/HackerOS-Updates &>> "$LOG"
            else
                print_status "HackerOS-Updates already downloaded"
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

        print_status "Package $app installed"
        log "Installed $app"
    fi
}

# Funkcja usuwania pakietów
remove_app() {
    app="$1"
    path="${paths[$app]}"

    if [ -z "$path" ]; then
        print_error "Unknown package: $app"
        log "Remove failed - unknown app $app"
        exit 1
    fi

    print_separator
    echo -e "${YELLOW}${BOLD}Removing package: $app${RESET}"
    print_separator
    progress_bar "remove"

    if [ -d "$path" ]; then
        sudo rm -rf "$path" &>> "$LOG"
        print_status "Package $app removed"
        log "Removed $app"
        if [[ "$app" == "penetration-mode" || "$app" == "hacker-mode" || "$app" == "hackeros-tv" ]]; then
            update_preferences "$app" "remove"
        fi
    else
        print_error "Package $app is not installed"
        log "Remove failed - $app not installed"
    fi
}

# Funkcje instalacji trybów narzędziowych
install_cybersecurity() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing Cybersecurity Tools${RESET}"
    print_separator
    progress_bar "cybersecurity"

    print_info "Updating APT repositories"
    sudo apt update
    sudo apt install -y nmap wireshark nikto john hydra aircrack-ng sqlmap ettercap-text-only tcpdump zmap bettercap wfuzz hashcat fail2ban rkhunter chkrootkit lynis clamav tor proxychains4 httrack sublist3r macchanger inxi htop openvas openvpn metasploit-framework &>> "$LOG"

    print_info "Installing metasploit-framework from Snap"
    sudo snap install metasploit-framework &>> "$LOG"
    print_info "Installing Ghidra from Flatpak"
    flatpak install flathub org.ghindra.Ghindra -y &>> "$LOG"

    print_status "Cybersecurity Tools installed"
    log "Installed Cybersecurity Tools"
}

install_gaming() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing Gaming Tools${RESET}"
    print_separator
    progress_bar "gaming"

    print_info "Updating APT repositories"
    sudo apt update
    sudo apt install -y steam lutris obs-studio &>> "$LOG"

    print_info "Installing packages from Flatpak"
    flatpak install flathub com.heroicgameslauncher.hgl -y &>> "$LOG"
    flatpak install flathub com.hyperplay.hyperplay -y &>> "$LOG"
    flatpak install flathub com.github.PikaTorrent.PikaTorrent -y &>> "$LOG"
    flatpak install flathub com.discordapp.Discord -y &>> "$LOG"
    flatpak install flathub com.github.Matoking.Protontricks -y &>> "$LOG"
    flatpak install flathub dev.coder5460.Sober -y &>> "$LOG"
    flatpak install flathub com.github.vinegarhq.Vinegar -y &>> "$LOG"

    print_status "Gaming Tools installed"
    log "Installed Gaming Tools"
}

install_gaming_no_roblox() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing Gaming Tools (no Roblox)${RESET}"
    print_separator
    progress_bar "gaming-no-roblox"

    print_info "Updating APT repositories"
    sudo apt update
    sudo apt install -y steam lutris obs-studio &>> "$LOG"

    print_info "Installing packages from Flatpak"
    flatpak install flathub com.heroicgameslauncher.hgl -y &>> "$LOG"
    flatpak install flathub com.hyperplay.hyperplay -y &>> "$LOG"
    flatpak install flathub com.github.PikaTorrent.PikaTorrent -y &>> "$LOG"
    flatpak install flathub com.discordapp.Discord -y &>> "$LOG"
    flatpak install flathub com.github.Matoking.Protontricks -y &>> "$LOG"

    print_status "Gaming Tools (no Roblox) installed"
    log "Installed Gaming Tools no Roblox"
}

install_addons() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing Add-ons${RESET}"
    print_separator
    progress_bar "add-ons"

    print_info "Updating APT repositories"
    sudo apt update
    sudo apt install -y wine winetricks &>> "$LOG"

    print_info "Installing packages from Flatpak"
    flatpak install flathub org.gnome.Boxes -y &>> "$LOG"
    flatpak install flathub com.usebottles.bottles -y &>> "$LOG"
    flatpak install flathub com.github.zocker_160.WineZGUI -y &>> "$LOG"

    print_status "Add-ons installed"
    log "Installed Add-ons"
}

install_dev_tools() {
    print_separator
    echo -e "${YELLOW}${BOLD}Installing Dev Tools${RESET}"
    print_separator
    progress_bar "dev-tools"

    print_info "Installing packages from Flatpak"
    flatpak install flathub io.atom.Atom -y &>> "$LOG"
    flatpak install flathub com.visualstudio.code -y &>> "$LOG"

    print_status "Dev Tools installed"
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
    update)
        update
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
        echo -e "${CYAN}${BOLD}HackerOS Package Manager${RESET}"
        print_separator
        echo -e "${WHITE}${BOLD}Usage:${RESET}"
        printf "  %-30s %s\n" "hacker install {app}" "Installs a package or toolset"
        printf "  %-30s %s\n" "hacker remove {app}" "Removes a package"
        printf "  %-30s %s\n" "hacker sys-logs" "Displays system logs"
        printf "  %-30s %s\n" "hacker update" "Performs full system update"
        printf "  %-30s %s\n" "hacker fast-update" "Performs quick system update"
        printf "  %-30s %s\n" "hacker check-updates" "Checks for available updates"
        printf "  %-30s %s\n" "hacker menu" "Launches HackerOS Menu"
        printf "  %-30s %s\n" "hacker cockpit" "Launches HackerOS Cockpit"
        printf "  %-30s %s\n" "hacker help" "Displays help"
        echo -e "${YELLOW}${BOLD}Run 'hacker help' for a list of packages and commands${RESET}"
        print_separator
        ;;
esac
