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
SKYBLUE='\033[1;38;5;117m'
EMERALD='\033[1;38;5;36m'
NC='\033[0m' # No Color

# HackerOS Configuration
RSS_URL="https://sourceforge.net/p/hackeros/activity/feed"
RELEASE_FILE="/usr/share/HackerOS/Release.txt"
CLONE_DIR="/tmp/HackerOS-Updates"
GITHUB_REPO="https://github.com/HackerOS-Linux-System/HackerOS-Updates.git"

# Proton-GE Configuration
VERSION_FILE="$HOME/.hackeros/proton-version"
PROTON_DIR="$HOME/.steam/root/compatibilitytools.d"
TMP_DIR="/tmp/proton-ge-update"

# Function to log messages
log_message() {
    local message="$1"
    echo -e "$message" | tee -a "$LOGFILE"
}

# Function to display a spinner with enhanced Unicode
spinner() {
    local pid=$1
    local delay=0.08
    local spinstr='⠇⠋⠙⠸⠴⠦⠧⠏'
    local message="$2"
    local max_width=60
    local trunc_message="${message:0:$((max_width-4))}"
    tput civis
    while ps -p "$pid" > /dev/null; do
        for ((i=0; i<${#spinstr}; i++)); do
            printf "\r${PURPLE}${spinstr:$i:1}${NC} %-${max_width}s" "$trunc_message"
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
    local width=80
    local title_width=$(( ${#message} + 12 ))
    local left_pad=$(( (width - title_width) / 2 ))
    local right_pad=$(( width - title_width - left_pad ))
    log_message "${GOLD}╒$(printf '═%.0s' $(seq 1 $width))╕${NC}"
    log_message "${GOLD}│$(printf '%*s' "$left_pad" '') ${CORAL}✦ ${message} ✦${NC} $(printf '%*s' "$right_pad" '')│${NC}"
    log_message "${GOLD}╘$(printf '═%.0s' $(seq 1 $width))╛${NC}"
}

# Function to print table row
print_table_row() {
    local name="$1"
    local status="$2"
    local count="$3"
    printf "${WHITE}│ %-32s │ %-32s │ %-17s │${NC}\n" "$name" "$status" "$count"
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

# Function to count updated packages
count_updated_packages() {
    local log_snippet="$1"
    local count=0
    if [ -n "$log_snippet" ]; then
        count=$(grep -c "upgraded.*[0-9]\+ newly installed" "$log_snippet" || echo 0)
    fi
    echo "$count"
}

# Function to compare versions
version_gt() {
    [[ "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1" ]]
}

# Function to update HackerOS
update_hackeros() {
    print_header "HackerOS Version Update"
    local hackeros_count=0
    local temp_log=$(mktemp)
    local updated=false

    # Check current version
    if [[ -f "$RELEASE_FILE" ]]; then
        CURRENT_VERSION=$(grep -oE '[0-9]+\.[0-9]+' "$RELEASE_FILE")
    else
        log_message "${RED}❌ Brak pliku wersji: $RELEASE_FILE${NC}"
        print_table_row "HackerOS" "${RED}Failed${NC}" "N/A"
        return 1
    fi

    # Fetch RSS and extract available ISO versions
    log_message "${SKYBLUE}🔄 Fetching HackerOS version information...${NC}"
    RSS_CONTENT=$(curl -s "$RSS_URL" 2>&1 | tee -a "$temp_log") &
    spinner $! "Fetching RSS feed from SourceForge"
    if [ $? -ne 0 ]; then
        log_message "${RED}❌ Failed to fetch RSS feed. Check log for details.${NC}"
        print_table_row "HackerOS" "${RED}Failed${NC}" "N/A"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 1
    fi

    ISO_VERSIONS=($(echo "$RSS_CONTENT" | grep -oE 'HackerOS-V[0-9]+\.[0-9]+\.iso' | grep -oE '[0-9]+\.[0-9]+' | sort -Vu))

    # Check for newer versions
    for VERSION in "${ISO_VERSIONS[@]}"; do
        if version_gt "$VERSION" "$CURRENT_VERSION"; then
            log_message "${SKYBLUE}🔄 Wykryto nową wersję ISO: $VERSION${NC}"

            # Remove old repository if exists
            rm -rf "$CLONE_DIR" 2>&1 | tee -a "$temp_log" &
            spinner $! "Removing old HackerOS repository"

            # Clone new repository
            git clone "$GITHUB_REPO" "$CLONE_DIR" 2>&1 | tee -a "$temp_log" &
            spinner $! "Cloning HackerOS updates repository"
            if [ $? -ne 0 ]; then
                log_message "${RED}❌ Failed to clone repository. Check log for details.${NC}"
                print_table_row "HackerOS" "${RED}Failed${NC}" "N/A"
                cat "$temp_log" >> "$LOGFILE"
                rm "$temp_log"
                return 1
            fi

            # Run unpack.sh
            if [[ -f "$CLONE_DIR/unpack.sh" ]]; then
                chmod +x "$CLONE_DIR/unpack.sh" 2>&1 | tee -a "$temp_log" &
                spinner $! "Setting execute permissions for unpack.sh"
                sudo "$CLONE_DIR/unpack.sh" 2>&1 | tee -a "$temp_log" &
                spinner $! "Running unpack.sh for HackerOS update"
                if [ $? -ne 0 ]; then
                    log_message "${RED}❌ Failed to run unpack.sh. Check log for details.${NC}"
                    print_table_row "HackerOS" "${RED}Failed${NC}" "N/A"
                    cat "$temp_log" >> "$LOGFILE"
                    rm "$temp_log"
                    return 1
                fi

                # Update version in file
                echo "HackerOS Version $VERSION" | sudo tee "$RELEASE_FILE" > /dev/null 2>&1 | tee -a "$temp_log" &
                spinner $! "Updating version in $RELEASE_FILE"
                CURRENT_VERSION="$VERSION"
                updated=true
                ((hackeros_count++))
                log_message "${EMERALD}✅ Zaktualizowano do wersji $VERSION${NC}"
            else
                log_message "${RED}❌ Nie znaleziono pliku $CLONE_DIR/unpack.sh${NC}"
                print_table_row "HackerOS" "${RED}Failed${NC}" "N/A"
                cat "$temp_log" >> "$LOGFILE"
                rm "$temp_log"
                return 1
            fi
        fi
    done

    # Final run of unpack.sh if updated
    if $updated; then
        log_message "${SKYBLUE}🚀 Finalne uruchomienie: sudo $CLONE_DIR/unpack.sh${NC}"
        sudo "$CLONE_DIR/unpack.sh" 2>&1 | tee -a "$temp_log" &
        spinner $! "Running final unpack.sh for HackerOS"
        if [ $? -ne 0 ]; then
            log_message "${RED}❌ Final unpack.sh failed. Check log for details.${NC}"
            print_table_row "HackerOS" "${RED}Failed${NC}" "$hackeros_count versions"
        else
            log_message "${EMERALD}✔ HackerOS updates completed successfully.${NC}"
            print_table_row "HackerOS" "${EMERALD}Success${NC}" "$hackeros_count versions"
        fi
    else
        log_message "${EMERALD}✅ System aktualny. Obecna wersja: $CURRENT_VERSION${NC}"
        print_table_row "HackerOS" "${EMERALD}Up-to-date${NC}" "$CURRENT_VERSION"
    fi

    cat "$temp_log" >> "$LOGFILE"
    rm "$temp_log"
}

# Function to update Proton-GE
update_proton() {
    print_header "Proton-GE Update"
    local proton_count=0
    local temp_log=$(mktemp)

    # Create necessary directories
    mkdir -p "$PROTON_DIR" "$(dirname "$VERSION_FILE")" "$TMP_DIR" 2>&1 | tee -a "$temp_log" &
    spinner $! "Creating Proton-GE directories"

    # Fetch latest Proton-GE version
    log_message "${SKYBLUE}🔄 Checking latest Proton-GE version...${NC}"
    LATEST_URL=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest \
        | grep "browser_download_url.*tar.gz" \
        | cut -d '"' -f 4) 2>&1 | tee -a "$temp_log" &
    spinner $! "Fetching latest Proton-GE release"
    if [ $? -ne 0 ] || [[ -z "$LATEST_URL" ]]; then
        log_message "${RED}❌ Failed to fetch Proton-GE release info. Check log for details.${NC}"
        print_table_row "Proton-GE" "${RED}Failed${NC}" "N/A"
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

    log_message "${SKYBLUE}[2/5] Zainstalowana wersja: $INSTALLED_VERSION${NC}"
    log_message "${SKYBLUE}[2/5] Najnowsza dostępna wersja: $LATEST_VERSION${NC}"

    # Check if latest version is already installed
    if [[ -d "$PROTON_DIR/$LATEST_VERSION" ]]; then
        log_message "${EMERALD}✅ Masz już najnowszą wersję Proton-GE ($LATEST_VERSION).${NC}"
        echoMelad"$LATEST_VERSION" > "$VERSION_FILE"
        print_table_row "Proton-GE" "${EMERALD}Up-to-date${NC}" "$LATEST_VERSION"
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
        print_table_row "Proton-GE" "${YELLOW}Skipped${NC}" "N/A"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 0
    fi

    # Remove previous version if exists
    if [[ -n "$INSTALLED_VERSION" && "$INSTALLED_VERSION" != "Brak" && -d "$PROTON_DIR/$INSTALLED_VERSION" ]]; then
        log_message "${SKYBLUE}[3/5] Usuwanie poprzedniej wersji: $INSTALLED_VERSION${NC}"
        rm -rf "$PROTON_DIR/$INSTALLED_VERSION" 2>&1 | tee -a "$temp_log" &
        spinner $! "Removing previous Proton-GE version"
    fi

    # Download new version
    log_message "${SKYBLUE}[4/5] Pobieranie $FILENAME...${NC}"
    curl -L -o "$TMP_DIR/$FILENAME" "$LATEST_URL" 2>&1 | tee -a "$temp_log" &
    spinner $! "Downloading Proton-GE $LATEST_VERSION"
    if [ $? -ne 0 ] || [[ ! -f "$TMP_DIR/$FILENAME" ]]; then
        log_message "${RED}❌ Pobieranie zakończone niepowodzeniem. Check log for details.${NC}"
        print_table_row "Proton-GE" "${RED}Failed${NC}" "N/A"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 1
    fi

    # Install new version
    log_message "${SKYBLUE}[5/5] Instalowanie nowej wersji...${NC}"
    tar -xf "$TMP_DIR/$FILENAME" -C "$PROTON_DIR" 2>&1 | tee -a "$temp_log" &
    spinner $! "Installing Proton-GE $LATEST_VERSION"
    if [ $? -ne 0 ]; then
        log_message "${RED}❌ Instalacja zakończona niepowodzeniem. Check log for details.${NC}"
        print_table_row "Proton-GE" "${RED}Failed${NC}" "N/A"
        cat "$temp_log" >> "$LOGFILE"
        rm "$temp_log"
        return 1
    fi

    # Update version file
    echo "$LATEST_VERSION" > "$VERSION_FILE" 2>&1 | tee -a "$temp_log" &
    spinner $! "Updating Proton-GE version file"
    ((proton_count++))

    log_message "${EMERALD}✅ Zainstalowano Proton-GE: $LATEST_VERSION${NC}"
    print_table_row "Proton-GE" "${EMERALD}Success${NC}" "$proton_count version"

    # Cleanup
    rm -rf "$TMP_DIR" 2>&1 | tee -a "$temp_log" &
    spinner $! "Cleaning up temporary files"

    cat "$temp_log" >> "$LOGFILE"
    rm "$temp_log"
}

# Function to update Steam and Ghostty desktop files
update_steam_ghostty() {
    print_header "Steam and Ghostty Desktop Updates"
    local steam_ghostty_count=0
    local temp_log=$(mktemp)
    local updated=false
    local config_dir="/usr/share/HackerOS/Config-Files"
    local dest_dir="/usr/share/applications"

    # Define files to copy
    local files=(
        "$config_dir/steam.desktop:$dest_dir"
        "$config_dir/com.mitchellh.ghostty.desktop:$dest_dir"
    )

    for file in "${files[@]}"; do
        src=${file%%:*}
        dest=${file##*:}
        if [ -f "$src" ]; then
            sudo mkdir -p "$dest" 2>&1 | tee -a "$temp_log" &
            spinner $! "Creating directory $dest"
            sudo cp -r "$src" "$dest" 2>&1 | tee -a "$temp_log" &
            spinner $! "Copying $(basename "$src") to $dest"
            if [ $? -eq 0 ]; then
                updated=true
                ((steam_ghostty_count++))
                log_message "${EMERALD}✅ Successfully copied $(basename "$src") to $dest${NC}"
            else
                log_message "${RED}❌ Failed to copy $(basename "$src") to $dest${NC}"
            fi
        else
            log_message "${RED}❌ File $(basename "$src") not found in $config_dir${NC}"
        fi
    done

    if $updated; then
        print_table_row "Steam & Ghostty" "${EMERALD}Success${NC}" "$steam_ghostty_count files"
        log_message "${EMERALD}✔ Steam and Ghostty desktop updates completed successfully.${NC}"
    else
        print_table_row "Steam & Ghostty" "${RED}Failed${NC}" "N/A"
        log_message "${RED}❌ Steam and Ghostty desktop updates failed. Check log for details.${NC}"
    fi

    cat "$temp_log" >> "$LOGFILE"
    rm "$temp_log"
}

# Function to perform updates and track counts
perform_updates() {
    local apt_count=0 snap_count=0 flatpak_count=0 firmware_count=0 proton_count=0
    local temp_log=$(mktemp)

    print_header "System Update Process"
    log_message "${SKYBLUE}🚀 Starting system updates...${NC}"

    # Display table header
    log_message "${GOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━┓${NC}"
    log_message "${GOLD}┃ Package Manager                  ┃ Status                           ┃ Updated Packages  ┃${NC}"
    log_message "${GOLD}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━┫${NC}"

    # Update APT
    if check_command apt; then
        print_header "APT Package Updates"
        sudo apt update -y 2>&1 | tee -a "$temp_log" &
        spinner $! "Updating APT package lists"
        if [ $? -ne 0 ]; then
            print_table_row "APT" "${RED}Failed${NC}" "N/A"
            log_message "${RED}❌ APT update failed. Check log for details.${NC}"
        else
            sudo apt upgrade -y 2>&1 | tee -a "$temp_log" &
            spinner $! "Installing APT package upgrades"
            if [ $? -ne 0 ]; then
                print_table_row "APT" "${RED}Failed${NC}" "N/A"
                log_message "${RED}❌ APT upgrade failed. Check log for details.${NC}"
            else
                apt_count=$(count_updated_packages "$temp_log")
                print_table_row "APT" "${EMERALD}Success${NC}" "$apt_count packages"
                log_message "${EMERALD}✔ APT updates completed successfully.${NC}"
            fi
            sudo apt autoremove -y 2>&1 | tee -a "$temp_log" &
            spinner $! "Removing unused APT packages"
            sudo apt autoclean -y 2>&1 | tee -a "$temp_log" &
            spinner $! "Cleaning APT package cache"
        fi
    else
        print_table_row "APT" "${RED}Not Installed${NC}" "N/A"
        log_message "${RED}❌ APT not found. Skipping APT updates.${NC}"
    fi

    # Update HackerOS
    update_hackeros

    # Update Proton-GE
    update_proton

    # Update Snap
    if check_command snap; then
        print_header "Snap Package Updates"
        sudo snap refresh 2>&1 | tee -a "$temp_log" &
        spinner $! "Refreshing Snap packages"
        if [ $? -ne 0 ]; then
            print_table_row "Snap" "${RED}Failed${NC}" "N/A"
            log_message "${RED}❌ Snap refresh failed. Check log for details.${NC}"
        else
            snap_count=$(snap changes | grep -c "Done.*Refresh" || echo 0)
            print_table_row "Snap" "${EMERALD}Success${NC}" "$snap_count packages"
            log_message "${EMERALD}✔ Snap updates completed successfully.${NC}"
        fi
    else
        print_table_row "Snap" "${RED}Not Installed${NC}" "N/A"
        log_message "${RED}❌ Snap not installed. Skipping Snap updates.${NC}"
    fi

    # Update Flatpak
    if check_command flatpak; then
        print_header "Flatpak Package Updates"
        flatpak update -y 2>&1 | tee -a "$temp_log" &
        spinner $! "Updating Flatpak packages"
        if [ $? -ne 0 ]; then
            print_table_row "Flatpak" "${RED}Failed${NC}" "N/A"
            log_message "${RED}❌ Flatpak update failed. Check log for details.${NC}"
        else
            flatpak_count=$(flatpak list --app | wc -l)
            print_table_row "Flatpak" "${EMERALD}Success${NC}" "$flatpak_count packages"
            log_message "${EMERALD}✔ Flatpak updates completed successfully.${NC}"
        fi
    else
        print_table_row "Flatpak" "${RED}Not Installed${NC}" "N/A"
        log_message "${RED}❌ Flatpak not installed. Skipping Flatpak updates.${NC}"
    fi

    # Update Firmware
    if check_command fwupdmgr; then
        print_header "Firmware Updates"
        sudo fwupdmgr refresh 2>&1 | tee -a "$temp_log" &
        spinner $! "Refreshing firmware metadata"
        sudo fwupdmgr update 2>&1 | tee -a "$temp_log" &
        spinner $! "Applying firmware updates"
        if [ $? -ne 0 ]; then
            print_table_row "Firmware" "${RED}Failed${NC}" "N/A"
            log_message "${RED}❌ Firmware update failed. Check log for details.${NC}"
        else
            firmware_count=$(fwupdmgr get-updates | grep -c "Update Version" || echo 0)
            print_table_row "Firmware" "${EMERALD}Success${NC}" "$firmware_count updates"
            log_message "${EMERALD}✔ Firmware updates completed successfully.${NC}"
        fi
    else
        print_table_row "Firmware" "${RED}Not Installed${NC}" "N/A"
        log_message "${RED}❌ fwupdmgr not installed. Skipping firmware updates.${NC}"
    fi

    # Update Plymouth
    print_header "Plymouth Updates"
    local plymouth_updated=false
    local plymouth_count=0
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
            sudo cp -f "$src" "$dest" 2>&1 | tee -a "$temp_log" &
            spinner $! "Copying $(basename "$src")"
            plymouth_updated=true
            ((plymouth_count++))
        else
            log_message "${RED}❌ File $(basename "$src") not found in $source_dir.${NC}"
        fi
    done
    if $plymouth_updated; then
        print_table_row "Plymouth" "${EMERALD}Success${NC}" "$plymouth_count files"
        log_message "${EMERALD}✔ Plymouth updates completed successfully.${NC}"
    else
        print_table_row "Plymouth" "${RED}Failed${NC}" "N/A"
    fi

    # Update Steam and Ghostty Desktop Files
    update_steam_ghostty

    # Close table
    log_message "${GOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━┛${NC}"
    cat "$temp_log" >> "$LOGFILE"
    rm "$temp_log"
}

# Function to display menu
show_menu() {
    print_header "Update Options"
    log_message "${SKYBLUE}Available actions:${NC}"
    log_message "${GOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    log_message "${GOLD}┃ Option                           ┃ Description                            ┃${NC}"
    log_message "${GOLD}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╋━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${NC}"
    printf "${WHITE}┃ %-32s ┃ %-38s ┃${NC}\n" "e) Exit" "Close the terminal"
    printf "${WHITE}┃ %-32s ┃ %-38s ┃${NC}\n" "r) Reboot" "Reboot the system"
    printf "${WHITE}┃ %-32s ┃ %-38s ┃${NC}\n" "s) Shutdown" "Shut down the system"
    printf "${WHITE}┃ %-32s ┃ %-38s ┃${NC}\n" "l) Log out" "Log out of the current session"
    printf "${WHITE}┃ %-32s ┃ %-38s ┃${NC}\n" "t) Try again" "Rerun the update process"
    printf "${WHITE}┃ %-32s ┃ %-38s ┃${NC}\n" "v) View log" "View the update log"
    log_message "${GOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    printf "${GOLD}➤ Select an option [e/r/s/l/t/v]: ${NC}"
    read -n 1 -r choice
    read -t 0.1 -r -s -d ''  # Clear any remaining input
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
            exit 0
            ;;
        t)
            log_message "${YELLOW}Restarting update process...${NC}"
            authenticate_sudo
            perform_updates
            ;;
        v)
            log_message "${SKYBLUE}Viewing update log...${NC}"
            if [ -f "$LOGFILE" ]; then
                less "$LOGFILE"
            else
                log_message "${RED}Log file not found.${NC}"
            fi
            ;;
        *)
            log_message "${RED}Invalid option. Please use e, r, s, l, t, or v.${NC}"
            ;;
    esac
}

# Main execution
clear
print_header "System Update Script"
log_message "${SKYBLUE}Initializing update process...${NC}"
if check_command neofetch; then
    log_message "${CYAN}Displaying system information...${NC}"
    neofetch | tee -a "$LOGFILE"
else
    log_message "${RED}neofetch not installed. Skipping system info display.${NC}"
fi
authenticate_sudo
perform_updates
while true; do
    show_menu
done
