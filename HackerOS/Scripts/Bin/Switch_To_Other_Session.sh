#!/usr/bin/bash

# Plik do zapisywania błędów
ERROR_FILE="/tmp/Switch_To_Another_Session.txt"
# Plik do debugowania (oddzielony od błędów)
DEBUG_FILE="/tmp/session-switch-debug.log"
# Plik preferencji użytkownika
PREF_FILE="/home/$USER/.session-switch-prefs"

# Funkcja do logowania debugowania
log_debug() {
  echo "[$(date)] DEBUG: $1" >> "$DEBUG_FILE"
}

# Funkcja do zapisywania błędów
log_error() {
  echo "[$(date)] ERROR: $1" | tee -a "$ERROR_FILE" >&2
}

# Inicjalizacja plików logów
touch "$ERROR_FILE" "$DEBUG_FILE" 2>/dev/null || {
  log_error "Cannot create log files in /tmp"
  exit 1
}
log_debug "Starting session switch script"

# Sprawdzanie uprawnień roota
if [[ $EUID -ne 0 ]]; then
  log_error "Script must be run as root"
  exit 1
fi

# Pobieranie informacji o systemie z /etc/os-release
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  DISTRO_ID="${ID:-ubuntu}"
else
  log_error "/etc/os-release not found or not readable, assuming HackerOS"
  DISTRO_ID="HackerOS"
fi
log_debug "Distribution ID: $DISTRO_ID"

# Pobieranie informacji o użytkowniku
USER=$(id -nu 1000 2>/dev/null)
HOME=$(getent passwd "$USER" | cut -d: -f6)
if [[ -z "$USER" ]] || [[ -z "$HOME" ]] || [[ ! -d "$HOME" ]]; then
  log_error "Failed to detect valid user or home directory"
  exit 1
fi
log_debug "User: $USER, Home: $HOME"

# Sprawdzanie aktywnej sesji graficznej użytkownika
SESSION_ID=$(loginctl list-sessions --no-legend | grep "$USER" | awk '{print $1}' | head -n1)
if [[ -z "$SESSION_ID" ]]; then
  log_error "No active graphical session found for user $USER"
  exit 1
fi
log_debug "User session ID: $SESSION_ID"

# Wykrywanie sesji graficznej
SESSION_DESKTOP="${XDG_SESSION_DESKTOP:-${DESKTOP_SESSION:-unknown}}"
if [[ "$SESSION_DESKTOP" != *"plasma"* ]] && [[ "$SESSION_DESKTOP" != *"kde"* ]]; then
  log_error "Current session ($SESSION_DESKTOP) is not Plasma"
  exit 1
fi
log_debug "Detected session: $SESSION_DESKTOP"

# Sprawdzanie i włączanie SDDM
if ! systemctl is-active --quiet sddm; then
  if ! command -v sddm &> /dev/null; then
    log_error "SDDM is not installed"
    echo "Installing SDDM..."
    apt update && apt install -y sddm || {
      log_error "Failed to install SDDM"
      exit 1
    }
  fi
  systemctl enable sddm --now || {
    log_error "Failed to enable/start SDDM"
    exit 1
  }
  log_debug "SDDM installed and started"
fi
log_debug "Detected display manager: sddm"

# Sprawdzanie zależności
DEPENDENCIES=("gamescope" "steam" "gamemoderun" "sway" "xrandr")
for dep in "${DEPENDENCIES[@]}"; do
  if ! command -v "$dep" &> /dev/null; then
    log_error "$dep is not installed, some sessions may not work"
  fi
done
log_debug "Dependency check completed"

# Tworzenie brakujących katalogów
[[ -d /etc/sddm.conf.d ]] || mkdir -p /etc/sddm.conf.d || {
  log_error "Cannot create /etc/sddm.conf.d"
  exit 1
}
[[ -d /usr/share/xsessions ]] || mkdir -p /usr/share/xsessions || {
  log_error "Cannot create /usr/share/wayland-sessions"
  exit 1
}
log_debug "Ensured directories exist"

# Automatyczne wykrywanie rozdzielczości (tylko dla Gamescope)
RESOLUTION="1920x1080"
if command -v xrandr &> /dev/null; then
  RESOLUTION=$(xrandr --current 2>/dev/null | grep '\*' | awk '{print $1}' | head -n1)
  if [[ -z "$RESOLUTION" ]]; then
    log_error "Could not detect resolution, using default $RESOLUTION"
  else
    log_debug "Detected resolution: $RESOLUTION"
  fi
fi
RES_WIDTH=$(echo "$RESOLUTION" | cut -d'x' -f1)
RES_HEIGHT=$(echo "$RESOLUTION" | cut -d'x' -f2)

# Dynamiczne wykrywanie dostępnych sesji
AVAILABLE_SESSIONS=()
[[ -f /usr/share/wayland-sessions/plasma.desktop ]] && AVAILABLE_SESSIONS+=("plasma")
[[ -f /usr/share/wayland-sessions/gamescope-session.desktop ]] && AVAILABLE_SESSIONS+=("gamescope-session")
[[ -f /usr/share/wayland-sessions/Hacker-Mode.desktop ]] && AVAILABLE_SESSIONS+=("sway-hacker-mode")
[[ -f /usr/share/wayland-sessions/Hacker-Viewer.desktop ]] && AVAILABLE_SESSIONS+=("sway-hacker-viewer")

# Interaktywne menu wyboru sesji
echo "Available sessions:"
echo "1) Gamescope (with Gamemode)"
echo "2) Hacker Mode"
echo "3) Hacker Viewer"
echo "4) Switch to Plasma"
if [[ -f "$PREF_FILE" ]]; then
  LAST_CHOICE=$(cat "$PREF_FILE")
  echo "Last selected: $LAST_CHOICE"
fi
echo -n "Select a session (1-4) [default: $LAST_CHOICE]: "
read -r CHOICE
CHOICE=${CHOICE:-$LAST_CHOICE}
log_debug "User selected choice: $CHOICE"

# Zapisywanie preferencji
echo "$CHOICE" > "$PREF_FILE" 2>/dev/null || log_error "Cannot write to $PREF_FILE"

# Konfiguracja wybranej sesji
case "$CHOICE" in
  1)
    SESSION_NAME="gamescope-session"
    SESSION_FILE="/usr/share/wayland-sessions/gamescope-session.desktop"
    if ! command -v gamemoderun &> /dev/null; then
      log_error "gamemoderun not installed for Gamescope session"
      exit 1
    fi
    if ! command -v steam &> /dev/null || [[ ! -f "$HOME/.local/share/Steam/ubuntu12_32/steamui.so" ]]; then
      log_error "Steam not installed or not configured"
      exit 1
    fi
    SESSION_EXEC="/usr/bin/gamemoderun /opt/gamescope/bin/gamescope -W $RES_WIDTH -H $RES_HEIGHT -e -- steam -gamepadui"
    ;;
  2)
    SESSION_NAME="sway-hacker-mode"
    SESSION_FILE="/usr/share/wayland-sessions/Hacker-Mode.desktop"
    if [[ ! -r /etc/sway/config ]]; then
      log_error "/etc/sway/config not found or not readable"
      exit 1
    fi
    SESSION_EXEC="/usr/bin/sway"
    SESSION_CONFIG="/etc/sway/config"
    ;;
  3)
    SESSION_NAME="sway-hacker-viewer"
    SESSION_FILE="/usr/share/wayland-sessions/Hacker-Viewer.desktop"
    if [[ ! -r /etc/sway/config1 ]]; then
      log_error "/etc/sway/config1 not found or not readable"
      exit 1
    fi
    SESSION_EXEC="/usr/bin/sway"
    SESSION_CONFIG="/etc/sway/config1"
    ;;
  4)
    SESSION_NAME="plasma"
    SESSION_FILE="/usr/share/wayland-sessions/plasma.desktop"
    if [[ ! -f "$SESSION_FILE" ]]; then
      log_error "Plasma session file not found"
      exit 1
    fi
    if [[ -f /etc/sddm.conf.d/zz-steamos-autologin.conf ]]; then
      rm /etc/sddm.conf.d/zz-steamos-autologin.conf 2>/dev/null || log_error "Cannot remove SDDM autologin config"
    fi
    log_debug "Reverting to Plasma session"
    ;;
  *)
    log_error "Invalid session choice: $CHOICE"
    exit 1
    ;;
esac

# Tworzenie lub aktualizacja pliku sesji (oprócz powrotu do Plasma)
if [[ "$CHOICE" != "4" ]]; then
  # Przygotowanie treści pliku .desktop
  DESKTOP_CONTENT="[Desktop Entry]
Name=${SESSION_NAME//-/ }
Comment=Custom session for ${SESSION_NAME}
Exec=$SESSION_EXEC${SESSION_CONFIG:+ --config $SESSION_CONFIG}
Type=Application
DesktopNames=$SESSION_NAME
Terminal=false"
  # Walidacja składni pliku .desktop
  if ! echo "$DESKTOP_CONTENT" | desktop-file-validate >/dev/null 2>&1; then
    log_error "Invalid .desktop file syntax for $SESSION_NAME"
    exit 1
  fi
  if [[ ! -f "$SESSION_FILE" ]]; then
    echo "$DESKTOP_CONTENT" > "$SESSION_FILE" 2>/dev/null || {
      log_error "Cannot write to $SESSION_FILE"
      exit 1
    }
    log_debug "Created session file: $SESSION_FILE"
  else
    CURRENT_EXEC=$(grep "^Exec=" "$SESSION_FILE" | cut -d= -f2-)
    EXPECTED_EXEC="$SESSION_EXEC${SESSION_CONFIG:+ --config $SESSION_CONFIG}"
    if [[ "$CURRENT_EXEC" != "$EXPECTED_EXEC" ]]; then
      sed -i "s|^Exec=.*|Exec=$EXPECTED_EXEC|" "$SESSION_FILE" 2>/dev/null || {
        log_error "Cannot update $SESSION_FILE"
        exit 1
      }
      log_debug "Updated session Exec in $SESSION_FILE to: $EXPECTED_EXEC"
    fi
  fi

  # Konfiguracja autologinu dla SDDM
  AUTOLOGIN_CONTENT="[Autologin]
User=$USER
Session=$SESSION_NAME.desktop"
  echo "$AUTOLOGIN_CONTENT" > /etc/sddm.conf.d/zz-steamos-autologin.conf 2>/dev/null || {
    log_error "Cannot write SDDM autologin config"
    exit 1
  }
  log_debug "Configured SDDM autologin for session: $SESSION_NAME"
fi

# Aktualizacja skryptu powrotu do Plasma
REVERT_SCRIPT="/usr/share/HackerOS/Scripts/Bin/revert_to_plasma.sh"
if [[ ! -f "$REVERT_SCRIPT" ]]; then
  {
    echo "#!/usr/bin/bash"
    echo "USER=\$(id -nu 1000)"
    echo "if [[ -f /etc/sddm.conf.d/zz-steamos-autologin.conf ]]; then"
    echo "  sudo rm /etc/sddm.conf.d/zz-steamos-autologin.conf"
    echo "fi"
    echo "sudo -Eu \$USER qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout"
  } > "$REVERT_SCRIPT" 2>/dev/null || {
    log_error "Cannot create $REVERT_SCRIPT"
    exit 1
  }
  chmod +x "$REVERT_SCRIPT" 2>/dev/null || {
    log_error "Cannot make $REVERT_SCRIPT executable"
    exit 1
  }
  log_debug "Created revert script: $REVERT_SCRIPT"
fi

# Wylogowanie bieżącej sesji
log_debug "Logging out current session"
sudo -Eu "$USER" qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>> "$DEBUG_FILE" || {
  log_debug "qdbus failed, trying loginctl"
  sudo -Eu "$USER" loginctl terminate-session "$SESSION_ID" 2>> "$DEBUG_FILE" || {
    log_error "Failed to logout session for user $USER"
    exit 1
  }
}

log_debug "Script execution completed"
