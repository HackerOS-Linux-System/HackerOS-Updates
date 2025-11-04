#!/bin/bash
# Log file for updates in /tmp
LOGFILE="/tmp/update_log_$(date +%Y%m%d_%H%M%S).txt"
# Expanded color palette for vibrant output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
ORANGE='\033[1;38;5;208m'
PURPLE='\033[1;38;5;135m'
PINK='\033[1;38;5;201m'
LIME='\033[1;38;5;154m'
TEAL='\033[1;38;5;51m'
VIOLET='\033[1;38;5;141m'
GOLD='\033[1;38;5;220m'
CORAL='\033[1;38;5;203m'
AQUA='\033[1;38;5;45m'
EMERALD='\033[1;38;5;48m'
FUCHSIA='\033[1;38;5;198m'
NC='\033[0m' # No Color
# Proton-GE Configuration
VERSION_FILE="$HOME/.hackeros/proton-version"
PROTON_DIR="$HOME/.steam/root/compatibilitytools.d"
TMP_DIR="/tmp/proton-ge-update"
# Check if running in Alacritty
if [ -z "$ALACRITTY_WINDOW_ID" ]; then
    if command -v alacritty >/dev/null 2>&1; then
        exec alacritty -e bash -c "$0"
    else
        echo -e "${RED}Alacritty not found. Please install Alacritty to run this script.${NC}"
        exit 1
    fi
fi
# Function to log messages
log_message() {
    local message="$1"
    echo -e "$message" | tee -a "$LOGFILE"
}
# Function to display a spinner with enhanced Unicode
spinner() {
    local pid=$1
    local delay=0.08
    local spinstr='⡿⣟⣯⣷⣾⣽⣻⢿'
    local message="$2"
    local max_width=60
    local trunc_message="${message:0:$((max_width-4))}"
    tput civis
    while ps -p "$pid" > /dev/null; do
        for ((i=0; i<${#spinstr}; i++)); do
            printf "\r${AQUA}%s${NC} %-${max_width}s" "${spinstr:$i:1}" "$trunc_message"
            sleep "$delay"
        done
    done
    wait "$pid"
    local exit_status=$?
    printf "\r%*s\r" "$((max_width+4))" ""
    tput cnorm
    return $exit_status
}
# Function to check command existence
check_command() {
    command -v "$1" &>/dev/null
}
# Function to print section header
print_header() {
    local message="$1"
    local width=60
    local title_width=$(( ${#message} + 2 ))
    local left_pad=$(( (width - title_width) / 2 ))
    local right_pad=$(( width - title_width - left_pad ))
    log_message "${GOLD}┌$(printf '─%.0s' $(seq 1 $width))┐${NC}"
    log_message "${GOLD}│$(printf '%*s' "$left_pad" '') ${FUCHSIA}${message}${NC} $(printf '%*s' "$right_pad" '')│${NC}"
    log_message "${GOLD}└$(printf '─%.0s' $(seq 1 $width))┘${NC}"
}
# Function to authenticate sudo upfront
authenticate_sudo() {
    log_message "${YELLOW}🔐 Authenticating sudo credentials...${NC}"
    sudo -v
    if [ $? -ne 0 ]; then
        log_message "${RED}❌ Sudo authentication failed. Exiting.${NC}"
        exit 1
    fi
}
# Function to update Proton-GE
update_proton() {
    print_header "Proton-GE Update"
    local temp_log=$(mktemp)
    # Create necessary directories
    mkdir -p "$PROTON_DIR" "$(dirname "$VERSION_FILE")" "$TMP_DIR" 2>&1 | tee -a "$temp_log" &
    spinner $! "Creating Proton-GE directories"
    # Fetch latest Proton-GE version
    log_message "${CYAN}[1/5] Sprawdzanie najnowszej wersji...${NC}"
    LATEST_URL=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | grep "browser_download_url.*tar.gz" \
        | cut -d '"' -f 4) 2>&1 | tee -a "$temp_log" &
    spinner $! "Fetching latest Proton-GE release"
    if [ $? -ne 0 ] || [[ -z "$LATEST_URL" ]]; then
        log_message "${RED}❌ Błąd: Nie udało się uzyskać informacji o najnowszej wersji.${NC}"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 1
    fi
    FILENAME=$(basename "$LATEST_URL")
    LATEST_VERSION="${FILENAME%.tar.gz}"
    # Read installed version
    if [[ -f "$VERSION_FILE" ]]; then
        INSTALLED_VERSION=$(cat "$VERSION_FILE")
    else
        INSTALLED_VERSION="Brak"
    fi
    log_message "${CYAN}[2/5] Zainstalowana wersja: $INSTALLED_VERSION${NC}"
    log_message "${CYAN}[2/5] Najnowsza dostępna wersja: $LATEST_VERSION${NC}"
    # Check if latest version is already installed
    if [[ -d "$PROTON_DIR/$LATEST_VERSION" ]]; then
        log_message "${LIME}✅ Masz już najnowszą wersję Proton-GE ($LATEST_VERSION).${NC}"
        echo "$LATEST_VERSION" > "$VERSION_FILE" 2>&1 | tee -a "$temp_log" &
        spinner $! "Updating Proton-GE version file"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 0
    fi
    # Prompt user for update confirmation
    log_message "${YELLOW}➤ Czy chcesz zaktualizować do wersji $LATEST_VERSION? [t/n]: ${NC}"
    read -t 30 -n 1 -r CONFIRM
    echo
    if [[ "$CONFIRM" != "t" && "$CONFIRM" != "T" ]]; then
        log_message "${YELLOW}Anulowano aktualizację Proton-GE.${NC}"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 0
    fi
    # Remove previous version if exists
    if [[ -n "$INSTALLED_VERSION" && "$INSTALLED_VERSION" != "Brak" && -d "$PROTON_DIR/$INSTALLED_VERSION" ]]; then
        log_message "${CYAN}[3/5] Usuwanie poprzedniej wersji: $INSTALLED_VERSION${NC}"
        rm -rf "$PROTON_DIR/$INSTALLED_VERSION" 2>&1 | tee -a "$temp_log" &
        spinner $! "Removing previous Proton-GE version"
    fi
    # Download new version
    log_message "${CYAN}[4/5] Pobieranie $FILENAME...${NC}"
    curl -L -o "$TMP_DIR/$FILENAME" "$LATEST_URL" 2>&1 | tee -a "$temp_log" &
    spinner $! "Download Proton-GE $LATEST_VERSION"
    if [ $? -ne 0 ] || [[ ! -f "$TMP_DIR/$FILENAME" ]]; then
        log_message "${RED}❌ Błąd: Pobieranie zakończone niepowodzeniem.${NC}"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 1
    fi
    # Install new version
    log_message "${CYAN}[5/5] Instalowanie nowej wersji...${NC}"
    tar -xf "$TMP_DIR/$FILENAME" -C "$PROTON_DIR" 2>&1 | tee -a "$temp_log" &
    spinner $! "Installing Proton-GE $LATEST_VERSION"
    if [ $? -ne 0 ]; then
        log_message "${RED}❌ Instalacja zakończona niepowodzeniem.${NC}"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 1
    fi
    # Update version file
    echo "$LATEST_VERSION" > "$VERSION_FILE" 2>&1 | tee -a "$temp_log" &
    spinner $! "Updating Proton-GE version file"
    log_message "${LIME}✅ Instalacja zakończona. Zainstalowano Proton-GE: $LATEST_VERSION${NC}"
    # Cleanup
    rm -rf "$TMP_DIR" 2>&1 | tee -a "$temp_log" &
    spinner $! "Cleaning up temporary files"
    cat "$temp_log" >> "$LOGFILE"
    rm "$temp_log"
}
# Function to update Steam desktop file
update_steam() {
    print_header "Steam Updates"
    local temp_log=$(mktemp)
    local updated=false
    local steam_count=0
    local config_dir="/usr/share/HackerOS/Config-Files"
    local dest_dir="/usr/share/applications"
    local src="$config_dir/HackerOS-Steam.desktop"
    local dest="$dest_dir"
    if [ -f "$src" ]; then
        sudo mkdir -p "$dest" 2>&1 | tee -a "$temp_log" &
        spinner $! "Creating directory $dest"
        sudo cp -r "$src" "$dest" 2>&1 | tee -a "$temp_log" &
        spinner $! "Copying $(basename "$src") to $dest"
        if [ $? -eq 0 ]; then
            updated=true
            ((steam_count++))
            log_message "${LIME}✅ Successfully copied $(basename "$src") to $dest${NC}"
        else
            log_message "${RED}❌ Failed to copy $(basename "$src") to $dest${NC}"
        fi
    else
        log_message "${RED}❌ File $(basename "$src") not found in $config_dir${NC}"
    fi
    if $updated; then
        log_message "${LIME}✔ Steam updates completed successfully. Copied $steam_count file.${NC}"
    else
        log_message "${RED}❌ Steam updates failed. No files were copied.${NC}"
    fi
    cat "$temp_log" >> "$LOGFILE"
    rm "$temp_log"
}
# Function to perform updates
perform_updates() {
    print_header "System Update Process"
    log_message "${CYAN}🚀 Starting system updates...${NC}"
    # Update APT
    if check_command /usr/lib/HackerOS/apt; then
        print_header "APT Package Updates"
        sudo apt update -y 2>&1 | tee -a "$LOGFILE" &
        spinner $! "Updating package lists"
        if [ $? -ne 0 ]; then
            log_message "${RED}❌ APT update failed. Check log for details.${NC}"
            return 1
        fi
        sudo apt upgrade -y 2>&1 | tee -a "$LOGFILE" &
        spinner $! "Installing package upgrades"
        if [ $? -ne 0 ]; then
            log_message "${RED}❌ APT upgrade failed. Check log for details.${NC}"
            return 1
        fi
        sudo apt autoremove -y 2>&1 | tee -a "$LOGFILE" &
        spinner $! "Removing unused packages"
        sudo apt autoclean -y 2>&1 | tee -a "$LOGFILE" &
        spinner $! "Cleaning package cache"
        log_message "${LIME}✔ APT updates completed successfully.${NC}"
    else
        log_message "${RED}❌ APT not found at /usr/lib/HackerOS/apt. Skipping APT updates.${NC}"
    fi
    # Update Proton-GE
    if check_command curl; then
        update_proton
    else
        log_message "${RED}❌ curl not installed. Skipping Proton-GE updates.${NC}"
    fi
    # Update Snap
    if check_command snap; then
        print_header "Snap Package Updates"
        sudo snap refresh 2>&1 | tee -a "$LOGFILE" &
        spinner $! "Refreshing Snap packages"
        if [ $? -ne 0 ]; then
            log_message "${RED}❌ Snap refresh failed. Check log for details.${NC}"
        else
            log_message "${LIME}✔ Snap updates completed successfully.${NC}"
        fi
    else
        log_message "${RED}❌ Snap not installed. Skipping Snap updates.${NC}"
    fi
    # Update Flatpak
    if check_command flatpak; then
        print_header "Flatpak Package Updates"
        flatpak update -y 2>&1 | tee -a "$LOGFILE" &
        spinner $! "Updating Flatpak packages"
        if [ $? -ne 0 ]; then
            log_message "${RED}❌ Flatpak update failed. Check log for details.${NC}"
        else
            log_message "${LIME}✔ Flatpak updates completed successfully.${NC}"
        fi
    else
        log_message "${RED}❌ Flatpak not installed. Skipping Flatpak updates.${NC}"
    fi
    # Update Firmware
    if check_command fwupdmgr; then
        print_header "Firmware Updates"
        sudo fwupdmgr refresh 2>&1 | tee -a "$LOGFILE" &
        spinner $! "Refreshing firmware metadata"
        sudo fwupdmgr update 2>&1 | tee -a "$LOGFILE" &
        spinner $! "Applying firmware updates"
        if [ $? -ne 0 ]; then
            log_message "${RED}❌ Firmware update failed. Check log for details.${NC}"
        else
            log_message "${LIME}✔ Firmware updates completed successfully.${NC}"
        fi
    else
        log_message "${RED}❌ fwupdmgr not installed. Skipping firmware updates.${NC}"
    fi
    # Update Plymouth
    print_header "Plymouth Updates"
    local plymouth_updated=false
    local source_dir="/usr/share/HackerOS/ICONS/Plymouth-Icons"
    local config_dir="/usr/share/HackerOS/Config-Files"
    for file in \
        "$source_dir/ubuntu-logo.png:/usr/share/plymouth" \
        "$source_dir/watermark.png:/usr/share/plymouth/themes/spinner" \
        "$config_dir/org.gnome.Software.desktop:/usr/share/applications" \
        "$source_dir/bgrt-fallback.png:/usr/share/plymouth/themes/spinner"; do
        src=${file%%:*}
        dest=${file##*:}
        if [ -f "$src" ]; then
            sudo mkdir -p "$dest" 2>&1 | tee -a "$LOGFILE"
            sudo cp -f "$src" "$dest" 2>&1 | tee -a "$LOGFILE" &
            spinner $! "Copying $(basename "$src")"
            plymouth_updated=true
        else
            log_message "${RED}❌ File $(basename "$src") not found in $source_dir.${NC}"
        fi
    done
    if $plymouth_updated; then
        log_message "${LIME}✔ Plymouth updates completed successfully.${NC}"
    else
        log_message "${RED}❌ Plymouth update failed. No files were updated.${NC}"
    fi
    # Update Steam
    update_steam
}
# Function to display menu
show_menu() {
    while true; do
        print_header "Update Options"
        log_message "${CYAN}Available actions:${NC}"
        log_message "${WHITE} e) Exit Close the terminal${NC}"
        log_message "${WHITE} r) Reboot Reboot the system${NC}"
        log_message "${WHITE} s) Shutdown Shut down the system${NC}"
        log_message "${WHITE} l) Log out Log out of the current session${NC}"
        log_message "${WHITE} t) Try again Rerun the update process${NC}"
        printf "${ORANGE}⤷ Select an option [e/r/s/l/t]: ${NC}"
        read -n 1 choice
        echo
        case "${choice,,}" in
            e)
                log_message "${GREEN}Exiting update mode...${NC}"
                exit 0
                ;;
            r)
                log_message "${YELLOW}Initiating system reboot...${NC}"
                sudo reboot
                ;;
            s)
                log_message "${YELLOW}Initiating system shutdown...${NC}"
                sudo shutdown -h now
                ;;
            l)
                log_message "${YELLOW}Logging out of session...${NC}"
                if gnome-session-quit --no-prompt 2>&1 | tee -a "$LOGFILE"; then
                    log_message "${GREEN}Logout successful.${NC}"
                else
                    log_message "${RED}Logout failed. Check log for details.${NC}"
                fi
                ;;
            t)
                log_message "${YELLOW}Restarting update process...${NC}"
                authenticate_sudo
                perform_updates
                ;;
            *)
                log_message "${RED}Invalid option. Please use e, r, s, l, or t.${NC}"
                ;;
        esac
    done
}
# Main execution
{
    print_header "System Update Script"
    log_message "${CYAN}Initializing update process...${NC}"
    authenticate_sudo
    perform_updates
    show_menu
} 2>&1 | tee -a "$LOGFILE"
