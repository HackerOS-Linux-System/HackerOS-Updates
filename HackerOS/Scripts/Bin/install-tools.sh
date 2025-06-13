#!/bin/bash

# Script: HackerOS Advanced Tools Installer
# Description: Interactive, user-friendly menu for installing gaming and penetration testing tools on Ubuntu
# Version: 3.0
# Author: Grok (enhanced version)
# Date: May 17, 2025

# Configuration
LOG_FILE="/var/log/hackeros_install.log"
BACKUP_DIR="$HOME/hackeros_backup_$(date +%Y%m%d_%H%M%S)"
CONFIG_DIR="$HOME/.hackeros"
CONFIG_FILE="$CONFIG_DIR/installer.conf"
MAX_LOG_SIZE=$((1024*1024)) # 1MB
TEMP_DIR="/tmp/hackeros_install"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Progress bar function
progress_bar() {
    local duration=$1
    local width=50
    local progress=0
    while [ $progress -le 100 ]; do
        local filled=$((progress * width / 100))
        local empty=$((width - filled))
        printf "\r${CYAN}["
        printf "%${filled}s" | tr ' ' '#'
        printf "%${empty}s" | tr ' ' '-'
        printf "] %d%%${NC}" $progress
        sleep $((duration / 100))
        progress=$((progress + 1))
    done
    echo ""
}

# Initialize logging
init_logging() {
    mkdir -p "$(dirname "$LOG_FILE")" "$CONFIG_DIR" "$TEMP_DIR"
    touch "$LOG_FILE" 2>/dev/null || {
        echo -e "${RED}Cannot create log file at $LOG_FILE${NC}"
        exit 1
    }
    # Rotate log if too large
    if [ -f "$LOG_FILE" ] && [ "$(stat -c %s "$LOG_FILE")" -gt "$MAX_LOG_SIZE" ]; then
        mv "$LOG_FILE" "${LOG_FILE}.$(date +%s).bak"
        touch "$LOG_FILE"
    fi
    echo "HackerOS Installation Log - $(date)" >> "$LOG_FILE"
}

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check for required dependencies
check_dependencies() {
    local deps=("git" "curl" "alacritty" "snapd" "flatpak" "dialog")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log "${YELLOW}Installing dependency: $dep${NC}"
            apt-get install -y "$dep" >> "$LOG_FILE" 2>&1 || {
                log "${RED}Failed to install $dep${NC}"
                echo -e "${RED}Failed to install $dep. Check $LOG_FILE.${NC}"
                exit 1
            }
        fi
    done
    # Ensure flatpak remote is configured
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >> "$LOG_FILE" 2>&1
}

# Backup existing configurations
backup_configs() {
    log "Creating backup of configurations..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.config" "$CONFIG_DIR" "$BACKUP_DIR" 2>/dev/null
    log "Backup created at $BACKUP_DIR"
    echo -e "${GREEN}Backup saved to $BACKUP_DIR${NC}"
}

# Check internet connectivity
check_internet() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${RED}No internet connection. Please check your network and try again.${NC}"
        log "No internet connection detected"
        exit 1
    fi
}

# Installation wrapper with progress feedback
run_install() {
    local cmd="$1"
    local desc="$2"
    local pkg_manager="$3"
    log "Starting $desc installation via $pkg_manager..."
    echo -e "${YELLOW}Installing $desc...${NC}"
    progress_bar 5 & # Simulate progress
    PROGRESS_PID=$!
    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        kill $PROGRESS_PID 2>/dev/null
        wait $PROGRESS_PID 2>/dev/null
        log "$desc installed successfully"
        echo -e "${GREEN}$desc installed successfully!${NC}"
    else
        kill $PROGRESS_PID 2>/dev/null
        wait $PROGRESS_PID 2>/dev/null
        log "${RED}Error installing $desc${NC}"
        echo -e "${RED}Failed to install $desc. Check $LOG_FILE for details.${NC}"
        return 1
    fi
}

# Save user preferences
save_preferences() {
    local option="$1"
    echo "last_option=$option" > "$CONFIG_FILE"
    log "Saved user preference: $option"
}

# Load user preferences
load_preferences() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "${CYAN}Loaded last selection: $last_option${NC}"
    fi
}

# Display welcome screen
welcome_screen() {
    clear
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}               Welcome in Tools Installer                  ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${CYAN}Script for HackerOS${NC}"
    echo -e "${YELLOW}This script automates the installation of gaming and penetration testing tools.${NC}"
    echo -e "${YELLOW}Ensure you have an active internet connection and sudo privileges.${NC}"
    echo -e "${BLUE}------------------------------------------------------------${NC}"
    echo "Press ENTER to continue..."
    read
}

# Main menu using dialog
show_menu() {
    local choice
    choice=$(dialog --clear --title "HackerOS Tools Installer" \
        --menu "Select an option:" 20 60 12 \
        1 "Install All Tools" \
        2 "Install Penetration Tools (APT)" \
        3 "Install Gaming Tools (APT)" \
        4 "Install Kali Tools (Git)" \
        5 "Install BackBox Tools (Git)" \
        6 "Install Emulators (APT)" \
        7 "Install Cloud Tools (APT)" \
        8 "Install Cool Retro Term (APT)" \
        9 "Install Gaming Tools (No Roblox, APT)" \
        10 "Install Snap Tools (Gaming)" \
        11 "Install Flatpak Tools (Gaming)" \
        12 "Install Advanced Penetration Tools (Mix)" \
        13 "Surprise Option" \
        14 "Restore Backup" \
        0 "Exit" \
        2>&1 >/dev/tty)
    echo "$choice"
}

# Main logic
main() {
    # Initialize
    init_logging
    check_internet
    check_dependencies
    backup_configs
    welcome_screen
    load_preferences

    # Ensure sudo privileges
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}This script requires sudo privileges. Please run with sudo.${NC}"
        log "Script requires sudo"
        exit 1
    fi

    # Launch Alacritty with menu
    alacritty -e bash -c '
        while true; do
            choice=$(show_menu)
            case $choice in
                1)
                    run_install "apt-get install -y nmap metasploit-framework steam lutris retroarch && snap install spotify && flatpak install -y flathub com.valvesoftware.Steam" "All Tools" "mixed"
                    save_preferences "All Tools"
                    ;;
                2)
                    run_install "apt-get install -y nmap metasploit-framework aircrack-ng wireshark burpsuite sqlmap hydra" "Penetration Tools" "apt"
                    save_preferences "Penetration Tools"
                    ;;
                3)
                    run_install "apt-get install -y steam lutris retroarch playonlinux" "Gaming Tools" "apt"
                    save_preferences "Gaming Tools"
                    ;;
                4)
                    run_install "
                        git clone https://github.com/Kali-Linux/kali-tools.git ~/kali-tools && \
                        cd ~/kali-tools || exit && \
                        bash install.sh && \
                        cd ~ && \
                        rm -rf ~/kali-tools
                    " "Kali Tools" "git"
                    save_preferences "Kali Tools"
                    ;;
                5)
                    run_install "
                        git clone https://github.com/BackBox/backbox-tools.git ~/backbox-tools && \
                        cd ~/backbox-tools || exit && \
                        bash install.sh && \
                        cd ~ && \
                        rm -rf ~/backbox-tools
                    " "BackBox Tools" "git"
                    save_preferences "BackBox Tools"
                    ;;
                6)
                    run_install "apt-get install -y retroarch dolphin-emu pcsx2" "Emulators" "apt"
                    save_preferences "Emulators"
                    ;;
                7)
                    run_install "apt-get install -y docker.io kubectl awscli" "Cloud Tools" "apt"
                    save_preferences "Cloud Tools"
                    ;;
                8)
                    run_install "apt-get install -y cool-retro-term" "Cool Retro Term" "apt"
                    save_preferences "Cool Retro Term"
                    ;;
                9)
                    run_install "apt-get install -y steam lutris retroarch" "Gaming Tools (No Roblox)" "apt"
                    save_preferences "Gaming Tools (No Roblox)"
                    ;;
                10)
                    run_install "snap install spotify discord" "Snap Gaming Tools" "snap"
                    save_preferences "Snap Gaming Tools"
                    ;;
                11)
                    run_install "flatpak install -y flathub com.valvesoftware.Steam org.libretro.RetroArch" "Flatpak Gaming Tools" "flatpak"
                    save_preferences "Flatpak Gaming Tools"
                    ;;
                12)
                    run_install "apt-get install -y john nikto kismet tor && snap install owasp-zap" "Advanced Penetration Tools" "mixed"
                    save_preferences "Advanced Penetration Tools"
                    ;;
                13)
                    log "Surprise Option triggered"
                    run_install "apt-get install -y cowsay && cowsay 'HackerOS Surprise!'" "Surprise Option" "apt"
                    save_preferences "Surprise Option"
                    ;;
                14)
                    if [ -d "$BACKUP_DIR" ]; then
                        log "Restoring backup from $BACKUP_DIR"
                        cp -r "$BACKUP_DIR"/* "$HOME/" 2>/dev/null
                        echo -e "${GREEN}Backup restored from $BACKUP_DIR${NC}"
                    else
                        echo -e "${RED}No backup found at $BACKUP_DIR${NC}"
                    fi
                    save_preferences "Restore Backup"
                    ;;
                0)
                    echo -e "${GREEN}Installation complete. Thank you for using HackerOS Installer!${NC}"
                    log "Script exited by user"
                    read -p "Press ENTER to close..."
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Invalid option, try again.${NC}"
                    ;;
            esac
            echo -e "${CYAN}Press ENTER to continue...${NC}"
            read
        done
    '
}

# Trap Ctrl+C
trap 'echo -e "${RED}Script interrupted. Cleaning up...${NC}"; rm -rf "$TEMP_DIR"; log "Script interrupted by user"; exit 1' INT

# Run main
main
