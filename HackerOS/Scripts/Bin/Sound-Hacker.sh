#!/bin/bash

#  ________  ________  ___  ___  ________   ________               
# |\   ____\|\   __  \|\  \|\  \|\   ___  \|\   ___ \              
# \ \  \___|\ \  \|\  \ \  \\\  \ \  \\ \  \ \  \_|\ \             
#  \ \_____  \ \  \\\  \ \  \\\  \ \  \\ \  \ \  \ \\ \            
#   \|____|\  \ \  \\\  \ \  \\\  \ \  \\ \  \ \  \_\\ \           
#     ____\_\  \ \_______\ \_______\ \__\\ \__\ \_______\          
#    |\_________\|_______|\|_______|\|__| \|__|\|_______|          
#    \|_________|                                                  
#                                                                  
#                                                                  
#  ___  ___  ________  ________  ___  __    _______   ________     
# |\  \|\  \|\   __  \|\   ____\|\  \|\  \ |\  ___ \ |\   __  \    
# \ \  \\\  \ \  \|\  \ \  \___|\ \  \/  /|\ \   __/|\ \  \|\  \   
#  \ \   __  \ \   __  \ \  \    \ \   ___  \ \  \_|/_\ \   _  _\  
#   \ \  \ \  \ \  \ \  \ \  \____\ \  \\ \  \ \  \_|\ \ \  \\  \| 
#    \ \__\ \__\ \__\ \__\ \_______\ \__\\ \__\ \_______\ \__\\ _\ 
#     \|__|\|__|\|__|\|__|\|_______|\|__| \|__|\|_______|\|__|\|__|

# Sound-Hacker.sh
# Better audio for HackerOS
# HackerOS Team

set -e

# --- Konfiguracja ---

USER_HOME="$HOME"
LOG_FILE="/tmp/audio-enhancer.log"
PRESET_DIR="$USER_HOME/.config/easyeffects/presets"
TMP_PRESET="$USER_HOME/.config/easyeffects/temp_preset.json"

# --- Funkcje logowania ---

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# --- Instalacja zależności ---

install_dependencies() {
  if ! command -v zenity >/dev/null 2>&1; then
    echo "Proszę zainstalować pakiet 'zenity' przed uruchomieniem skryptu."
    exit 1
  fi

  for cmd in pactl pw-cli easyeffects systemctl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "Brak polecenia: $cmd. Proszę zainstalować wymagane pakiety."
      exit 1
    fi
  done

  log "Sprawdzono zależności."
}

# --- Wybór urządzenia audio ---

choose_audio_device() {
  mapfile -t devices < <(pactl list short sinks | awk '{print $2}')
  if [ ${#devices[@]} -eq 0 ]; then
    zenity --error --title="Błąd" --text="Nie znaleziono urządzeń audio."
    exit 1
  fi
  choice=$(zenity --list --title="Wybierz urządzenie audio" --column="Urządzenia" "${devices[@]}")
  echo "$choice"
}

set_default_sink() {
  local device="$1"
  pactl set-default-sink "$device"
  log "Ustawiono domyślne urządzenie audio: $device"
  zenity --info --title="Ustawienia audio" --text="Domyślne urządzenie audio ustawione na:\n$device"
}

# --- Presety EasyEffects ---

create_default_presets() {
  mkdir -p "$PRESET_DIR"
  # Przykładowy preset Gaming
  cat > "$PRESET_DIR/Gaming.json" <<EOF
{
  "name": "Gaming",
  "description": "Preset do gier - podbicie basów i klarowność",
  "effects": {
    "bass_boost": {
      "enabled": true,
      "gain": 6
    },
    "equalizer": {
      "enabled": true,
      "bands": [0, 3, 6, 9, 12]
    }
  }
}
EOF
  log "Utworzono preset Gaming."
}

choose_profile() {
  mapfile -t profiles < <(ls "$PRESET_DIR" | grep '\.json$' | sed 's/\.json$//')
  if [ ${#profiles[@]} -eq 0 ]; then
    zenity --error --title="Błąd" --text="Brak presetów EasyEffects."
    exit 1
  fi
  choice=$(zenity --list --title="Wybierz preset EasyEffects" --column="Presety" "${profiles[@]}")
  echo "$choice"
}

run_temp_easyeffects() {
  local preset_path="$1"
  if [ ! -f "$preset_path" ]; then
    zenity --error --title="Błąd" --text="Preset nie istnieje: $preset_path"
    return 1
  fi

  if pgrep easyeffects >/dev/null 2>&1; then
    pkill easyeffects
    sleep 1
  fi

  /usr/bin/easyeffects -l "$preset_path" &
  log "Uruchomiono EasyEffects z presetem: $preset_path"
  zenity --info --title="EasyEffects" --text="EasyEffects uruchomiony z presetem:\n$(basename "$preset_path")"
}

enable_systemd_service() {
  local profile="$1"
  local service_name="easyeffects@$USER.service"
  # Zakładamy, że usługa systemd została przygotowana do obsługi profili

  systemctl --user enable "$service_name"
  systemctl --user start "$service_name"
  log "Włączono usługę systemd EasyEffects: $service_name"
  zenity --info --title="Usługa systemd" --text="EasyEffects uruchomiony jako usługa systemd."
}

save_temp_config() {
  if pgrep easyeffects >/dev/null 2>&1; then
    cp "$TMP_PRESET" "$PRESET_DIR/SavedSession.json"
    log "Zapisano konfigurację tymczasową do SavedSession.json"
    zenity --info --title="Zapis konfiguracji" --text="Konfiguracja tymczasowa została zapisana."
  else
    zenity --error --title="Błąd" --text="EasyEffects nie jest uruchomiony."
  fi
}

load_temp_config() {
  if [ -f "$PRESET_DIR/SavedSession.json" ]; then
    cp "$PRESET_DIR/SavedSession.json" "$TMP_PRESET"
    log "Wczytano zapis konfiguracji."
    return 0
  else
    return 1
  fi
}

# --- Naprawa dźwięku Intel + PipeWire ---

repair_sound_intel_pipewire() {
  log "Rozpoczęto naprawę dźwięku Intel + PipeWire."

  # Usunięcie cache PulseAudio i PipeWire
  rm -rf "$USER_HOME/.config/pulse/*" "$USER_HOME/.config/pipewire/*"
  log "Usunięto pliki cache konfiguracji PulseAudio i PipeWire."

  # Restart EasyEffects, jeśli działa
  if pgrep easyeffects >/dev/null 2>&1; then
    pkill easyeffects
    sleep 2
    /usr/bin/easyeffects -l "$PRESET_DIR/Gaming.json" &
    log "EasyEffects został ponownie uruchomiony z presetem Gaming."
  fi

  zenity --info --title="Naprawa dźwięku" --text="Naprawa dźwięku dla Intel + PipeWire zakończona pomyślnie."
  log "Naprawa dźwięku zakończona."
}

# --- Status audio ---

show_current_audio_status() {
  local default_sink
  default_sink=$(pactl get-default-sink)
  local status
  status=$(pactl info | grep 'Server Name')
  local volume
  volume=$(pactl get-sink-volume "$default_sink" | head -n1 | awk '{print $5}')
  local mute
  mute=$(pactl get-sink-mute "$default_sink" | awk '{print $2}')

  zenity --info --title="Status audio" --text="Domyślne urządzenie: $default_sink
Status serwera: $status
Głośność: $volume
Wyciszenie: $mute"
  log "Wyświetlono status audio."
}

# --- Wyłącz EasyEffects ---

stop_easyeffects() {
  if pgrep easyeffects >/dev/null 2>&1; then
    pkill easyeffects
    log "EasyEffects został zatrzymany."
    zenity --info --title="EasyEffects" --text="EasyEffects został wyłączony."
  else
    zenity --info --title="EasyEffects" --text="EasyEffects nie był uruchomiony."
  fi
}

# --- Przywróć domyślne ustawienia ---

reset_defaults() {
  if zenity --question --title="Przywracanie ustawień" --text="Czy na pewno chcesz przywrócić domyślne ustawienia EasyEffects?"; then
    rm -rf "$PRESET_DIR"/*
    create_default_presets
    zenity --info --title="Przywracanie ustawień" --text="Domyślne presety zostały przywrócone."
    log "Przywrócono domyślne presety."
  fi
}

# --- Menu główne ---

main_menu() {
  while true; do
    option=$(zenity --list --title="Audio Enhancer - Menu" --column="Opcje" \
      "Ustaw domyślne urządzenie audio" \
      "Wybierz i uruchom profil EasyEffects (tymczasowy)" \
      "Włącz EasyEffects jako usługę systemd" \
      "Zapisz konfigurację tymczasową" \
      "Wczytaj konfigurację z ostatniej sesji" \
      "Wyświetl status audio" \
      "Napraw dźwięk dla Intel + PipeWire" \
      "Wyłącz EasyEffects" \
      "Przywróć domyślne ustawienia" \
      "Zakończ")

    case "$option" in
      "Ustaw domyślne urządzenie audio")
        device=$(choose_audio_device)
        set_default_sink "$device"
        ;;
      "Wybierz i uruchom profil EasyEffects (tymczasowy)")
        profile=$(choose_profile)
        run_temp_easyeffects "$PRESET_DIR/$profile.json"
        ;;
      "Włącz EasyEffects jako usługę systemd")
        profile=$(choose_profile)
        enable_systemd_service "$profile"
        ;;
      "Zapisz konfigurację tymczasową")
        save_temp_config
        ;;
      "Wczytaj konfigurację z ostatniej sesji")
        if load_temp_config; then
          run_temp_easyeffects "$TMP_PRESET"
        else
          zenity --error --title="Błąd" --text="Brak zapisanej konfiguracji."
        fi
        ;;
      "Wyświetl status audio")
        show_current_audio_status
        ;;
      "Napraw dźwięk dla Intel + PipeWire")
        repair_sound_intel_pipewire
        ;;
      "Wyłącz EasyEffects")
        stop_easyeffects
        ;;
      "Przywróć domyślne ustawienia")
        reset_defaults
        ;;
      "Zakończ")
        log "Zakończono działanie skryptu."
        exit 0
        ;;
      *)
        zenity --error --title="Błąd" --text="Nieznana opcja."
        ;;
    esac
  done
}

# --- Start programu ---

log "Uruchomiono audio-enhancer.sh"
install_dependencies
create_default_presets
main_menu
