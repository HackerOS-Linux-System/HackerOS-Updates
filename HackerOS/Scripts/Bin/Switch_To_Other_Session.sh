#!/usr/bin/env bash

set -euo pipefail

LOGFILE="/var/log/switch_session.log"
exec 3>&1 1>>"$LOGFILE" 2>&1

# Helpers
log() { echo "$(date +'%F %T') - $*" >&3; }
user_name() {
  # Prefer SUDO_USER when run with sudo, otherwise $USER
  if [ -n "${SUDO_USER:-}" ]; then
    echo "$SUDO_USER"
  else
    echo "${USER:-$(whoami)}"
  fi
}

current_vt() {
  if command -v fgconsole >/dev/null 2>&1; then
    fgconsole 2>/dev/null || echo "$(who | awk '/:0/{print $2; exit}' || true)"
  else
    who | awk '/:0/{print $2; exit}' || true
  fi
}

is_running() {
  # is_running <process-name-or-fullpath>
  pkill -0 -f "$1" >/dev/null 2>&1
}

prompt() {
  zenity --info --width=450 --text="$1"
}

error_box() {
  zenity --error --width=520 --text="$1"
}

confirm() {
  zenity --question --width=520 --text="$1" && return 0 || return 1
}

# Start a command on a specific vt as the original user
start_on_vt() {
  local vt="$1"; shift
  local cmd="$*"
  local u="$(user_name)"

  log "Starting on VT${vt}: $cmd (user: $u)"

  # openvt starts a program on the given VT. Use su to run as the user.
  if command -v openvt >/dev/null 2>&1; then
    openvt -s -w -- su - "$u" -c "(exec setsid $cmd)" >/dev/null 2>&1 || return 1
  else
    # fallback: use chvt + nohup
    su - "$u" -c "nohup sh -c '$cmd' >/dev/null 2>&1 &" || return 1
  fi
}

switch_vt() {
  local vt="$1"
  log "Switching to VT$vt"
  if [ "$(id -u)" -ne 0 ]; then
    # try pkexec to run chvt as root
    if command -v pkexec >/dev/null 2>&1; then
      pkexec chvt "$vt" || return 1
    else
      sudo chvt "$vt" || return 1
    fi
  else
    chvt "$vt" || return 1
  fi
}

# Detect sessions
detect_desktop() {
  if is_running plasmashell || is_running startplasma || is_running kwin; then
    echo "kde"
  elif is_running wayfire || is_running wf-shell || is_running wayfired; then
    echo "wayfire"
  elif [ -x "/usr/share/HackerOS/Scripts/Bin/hacker_mode.sh" ] || [ -x "/usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Mode" ]; then
    echo "hacker-capable"
  else
    echo "unknown"
  fi
}

# Commands to launch
plasma_cmd() {
  # prefer startplasma-wayland if present, else startplasma-x11, else plasmashell
  if command -v startplasma-wayland >/dev/null 2>&1; then
    echo "startplasma-wayland"
  elif command -v startplasma-x11 >/dev/null 2>&1; then
    echo "startplasma-x11"
  elif command -v plasmashell >/dev/null 2>&1; then
    echo "plasmashell"
  else
    echo ""
  fi
}

wayfire_cmd() {
  if command -v wayfire >/dev/null 2>&1; then
    echo "wayfire"
  else
    echo ""
  fi
}

hacker_cmd() {
  if [ -x "/usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Mode" ]; then
    echo "/usr/share/HackerOS/Scripts/HackerOS-Apps/Hacker-Mode"
  elif [ -x "/usr/share/HackerOS/Scripts/Bin/hacker_mode.sh" ]; then
    echo "/usr/share/HackerOS/Scripts/Bin/hacker_mode.sh"
  else
    echo ""
  fi
}

# GUI selection
CHOICE=$(zenity --list --title="Wybierz sesję" --height=240 --width=420 --column="Opcja" "KDE (Plasma)" "Wayfire" "Hacker Mode" --text="Wybierz na jaką sesję chcesz się przełączyć:") || exit 1

log "User chose: $CHOICE"

CURRENT_DESKTOP=$(detect_desktop)
CURRENT_VT=$(current_vt || echo "unknown")
log "Detected current desktop: $CURRENT_DESKTOP, VT: $CURRENT_VT"

case "$CHOICE" in
  "KDE (Plasma)")
    # Target: VT2. Current: if on KDE then don't show option? The user asked: if already KDE then don't show 'przelacz na kde' - but we can't re-prompt now, so check and warn.
    if [ "$CURRENT_DESKTOP" = "kde" ]; then
      zenity --info --text="Wygląda na to, że jesteś już w KDE (Plasma). Nic do zrobienia." || true
      exit 0
    fi

    TARGET_VT=2
    PL_CMD="$(plasma_cmd)"
    if [ -z "$PL_CMD" ]; then
      error_box "Nie znaleziono polecenia uruchamiającego Plasma (search: startplasma-wayland / startplasma-x11 / plasmashell). Upewnij się, że masz zainstalowane pakiety Plasma."
      exit 1
    fi

    # Start plasma on VT2 if not running
    if ! is_running plasmashell && ! is_running startplasma; then
      if confirm "Plasma nie jest uruchomiona — chcesz ją uruchomić na tty${TARGET_VT}?"; then
        start_on_vt "$TARGET_VT" "$PL_CMD" || error_box "Nie udało się uruchomić Plasma na vt${TARGET_VT}. Sprawdź logi."
        sleep 2
      else
        exit 0
      fi
    fi
    switch_vt "$TARGET_VT" || error_box "Nie udało się przełączyć na vt${TARGET_VT}."
    ;;

  "Wayfire")
    if [ "$CURRENT_DESKTOP" = "wayfire" ]; then
      zenity --info --text="Wygląda na to, że jesteś już w Wayfire. Nic do zrobienia." || true
      exit 0
    fi

    TARGET_VT=4
    WF_CMD="$(wayfire_cmd)"
    if [ -z "$WF_CMD" ]; then
      error_box "Nie znaleziono programu wayfire. Zainstaluj wayfire lub popraw ścieżkę."; exit 1
    fi

    if ! is_running wayfire; then
      if confirm "Wayfire nie jest uruchomiony — chcesz go uruchomić na tty${TARGET_VT}?"; then
        start_on_vt "$TARGET_VT" "$WF_CMD" || error_box "Nie udało się uruchomić Wayfire na vt${TARGET_VT}."
        sleep 2
      else
        exit 0
      fi
    fi
    switch_vt "$TARGET_VT" || error_box "Nie udało się przełączyć na vt${TARGET_VT}."
    ;;

  "Hacker Mode")
    # Always show Hacker Mode option
    H_CMD="$(hacker_cmd)"
    if [ -z "$H_CMD" ]; then
      error_box "Nie znaleziono skryptu Hacker Mode w /usr/share/HackerOS/Scripts/."; exit 1
    fi

    # Determine which vt we are switching from per spec: "przelacz z tty2 (jezeli plasma) lub z tty4 jezeli wayfire"
    if [ "$CURRENT_DESKTOP" = "kde" ]; then
      FROM_VT=2
    elif [ "$CURRENT_DESKTOP" = "wayfire" ]; then
      FROM_VT=4
    else
      # If unknown, ask user
      if confirm "Nie wykryto aktywnej sesji KDE/Wayfire. Przełączyć na Hacker Mode na tty3?"; then
        :
      else
        exit 0
      fi
      FROM_VT="auto"
    fi

    TARGET_VT=3

    # Start hacker mode if not running
    if ! is_running "$H_CMD" && ! is_running hacker_mode.sh; then
      if confirm "Hacker Mode nie jest uruchomiony — chcesz go uruchomić na tty${TARGET_VT}?"; then
        start_on_vt "$TARGET_VT" "$H_CMD" || error_box "Nie udało się uruchomić Hacker Mode.";
        sleep 1
      else
        exit 0
      fi
    fi

    switch_vt "$TARGET_VT" || error_box "Nie udało się przełączyć na vt${TARGET_VT}."
    ;;
  *)
    exit 0
    ;;
esac

zenity --info --text="Przełączanie zakończone. Sprawdź $LOGFILE dla szczegółów." || true
exit 0
