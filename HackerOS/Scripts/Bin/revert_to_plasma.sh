#!/usr/bin/bash

# Plik do zapisywania błędów
ERROR_FILE="/tmp/Switch_To_Another_Session.txt"
# Plik do debugowania
DEBUG_FILE="/tmp/session-switch-debug.log"

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
log_debug "Starting Switching to plasma"

# Sprawdzanie uprawnień roota
if [[ $EUID -ne 0 ]]; then
  log_error "Script must be run as root"
  exit 1
}

# Pobieranie informacji o użytkowniku
USER=$(id -nu 1000 2>/dev/null)
HOME=$(getent passwd "$USER" | cut -d: -f6)
if [[ -z "$USER" ]] || [[ -z "$HOME" ]] || [[ ! -d "$HOME" ]]; then
  log_error "Failed to detect valid user or home directory"
  exit 1
}
log_debug "User: $USER, Home: $HOME"

# Sprawdzanie aktywnej sesji graficznej użytkownika
SESSION_ID=$(loginctl list-sessions --no-legend | grep "$USER" | awk '{print $1}' | head -n1)
if [[ -z "$SESSION_ID" ]]; then
  log_error "No active graphical session found for user $USER"
  exit 1
}
log_debug "User session ID: $SESSION_ID"

# Sprawdzanie, czy SDDM jest aktywny
if ! systemctl is-active --quiet sddm; then
  log_error "SDDM is not active"
  exit 1
}
log_debug "Detected display manager: sddm"

# Usuwanie konfiguracji autologinu SDDM
AUTOLOGIN_CONF="/etc/sddm.conf.d/zz-steamos-autologin.conf"
if [[ -f "$AUTOLOGIN_CONF" ]]; then
  rm "$AUTOLOGIN_CONF" 2>/dev/null || {
    log_error "Cannot remove $AUTOLOGIN_CONF"
    exit 1
  }
  log_debug "Removed SDDM autologin configuration"
else
  log_debug "No autologin configuration found at $AUTOLOGIN_CONF"
fi

# Sprawdzanie, czy sesja Plasma jest dostępna
PLASMA_SESSION="/usr/share/wayland-sessions/plasma.desktop"
if [[ ! -f "$PLASMA_SESSION" ]]; then
  log_error "Plasma session file not found at $PLASMA_SESSION"
  exit 1
}
log_debug "Plasma session file verified: $PLASMA_SESSION"

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
