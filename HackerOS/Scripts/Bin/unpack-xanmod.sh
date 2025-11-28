#!/bin/bash

#                                                                ,-.         
#          ,--,             ,-.----.                         ,--/ /|         
#        ,'_ /|       ,---, \    /  \                      ,--. :/ |         
#   .--. |  | :   ,-+-. /  ||   :    |                     :  : ' /          
# ,'_ /| :  . |  ,--.'|'   ||   | .\ :  ,--.--.     ,---.  |  '  /           
# |  ' | |  . . |   |  ,"' |.   : |: | /       \   /     \ '  |  :           
# |  | ' |  | | |   | /  | ||   |  \ :.--.  .-. | /    / ' |  |   \          
# :  | | :  ' ; |   | |  | ||   : .  | \__\/: . ..    ' /  '  : |. \         
# |  ; ' |  | ' |   | |  |/ :     |`-' ," .--.; |'   ; :__ |  | ' \ \        
# :  | : ;  ; | |   | |--'  :   : :   /  /  ,.  |'   | '.'|'  : |--'         
# '  :  `--'   \|   |/      |   | :  ;  :   .'   \   :    :;  |,'            
# :  ,      .-./'---'       `---'.|  |  ,     .-./\   \  / '--'              
#  `--`----'                  `---`   `--`---'     `----'                    
#  ,--,     ,--,                                  ____                       
#  |'. \   / .`|                                ,'  , `.                ,---,
#  ; \ `\ /' / ;                   ,---,     ,-+-,.' _ |   ,---.      ,---.'|
#  `. \  /  / .'               ,-+-. /  | ,-+-. ;   , ||  '   ,'\     |   | :
#   \  \/  / ./    ,--.--.    ,--.'|'   |,--.'|'   |  || /   /   |    |   | |
#    \  \.'  /    /       \  |   |  ,"' |   |  ,', |  |,.   ; ,. :  ,--.__| |
#     \  ;  ;    .--.  .-. | |   | /  | |   | /  | |--' '   | |: : /   ,'   |
#    / \  \  \    \__\/: . . |   | |  | |   : |  | ,    '   | .; :.   '  /  |
#   ;  /\  \  \   ," .--.; | |   | |  |/|   : |  |/     |   :    |'   ; |:  |
# ./__;  \  ;  \ /  /  ,.  | |   | |--' |   | |`-'       \   \  / |   | '/  '
# |   : / \  \  ;  :   .'   \|   |/     |   ;/            `----'  |   :    :|
# ;   |/   \  ' |  ,     .-./'---'      '---'                      \   \  /  
# `---'     `--` `--`---'                                           `----'   

set -euo pipefail

TMPFILE="/tmp/xanmod-cpu.hacker"
GITHUB_RAW="https://raw.githubusercontent.com/HackerOS-Linux-System/Hacker-Lang/main/hacker-packages/xanmod-cpu.hacker"
LOGPREFIX="[xanmod-installer]"

echo "${LOGPREFIX} Start"

# 1) Pobierz plik (nadpisz jeśli istnieje)
echo "${LOGPREFIX} Pobieram plik z GitHub: ${GITHUB_RAW} -> ${TMPFILE}"
if ! command -v curl >/dev/null 2>&1; then
  echo "${LOGPREFIX} curl nieznalezione, instaluję curl..."
  sudo apt update
  sudo apt install -y curl
fi

if ! curl -fsSL -o "${TMPFILE}" "${GITHUB_RAW}"; then
  echo "${LOGPREFIX} Błąd pobierania pliku z GitHub. Sprawdź połączenie i URL."
  exit 1
fi

echo "${LOGPREFIX} Plik pobrany."

# 2) Parse patterns
mapfile -t mappings < <(sed -e 's/^\s*//;s/\s*$//' "${TMPFILE}" \
                       | sed '/^\s*$/d' \
                       | sed '/^\s*#/d' \
                       | sed 's/^\[\(.*\)\]$/\1/' \
                       | awk -F'>' '/>/{gsub(/^[ \t]+|[ \t]+$/,"",$1); gsub(/^[ \t]+|[ \t]+$/,"",$2); print $1 "###" $2 }')

if [ ${#mappings[@]} -eq 0 ]; then
  echo "${LOGPREFIX} Nie znaleziono poprawnych mapowań w pliku. Kończę."
  exit 1
fi

declare -a patterns
declare -a targets

tmp_sort="$(mktemp)"
for m in "${mappings[@]}"; do
  pat="${m%%###*}"
  tar="${m##*###}"
  printf '%s\t%s\n' "${pat}" "${tar}" >> "${tmp_sort}"
done

mapfile -t sorted_pairs < <(
  awk -F'\t' '{print length($1) "\t" $0}' "${tmp_sort}" \
  | sort -rn \
  | cut -f2- \
  | awk -F'\t' '{print $1 "###" $2 }'
)

rm -f "${tmp_sort}"

patterns=()
targets=()
for sp in "${sorted_pairs[@]}"; do
  patterns+=("${sp%%###*}")
  targets+=("${sp##*###}")
done

# 3) CPU INFO
CPU_INFO="$(lscpu 2>/dev/null || true)"
CPU_MODEL="$(awk -F: '/Model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || true)"
CPU_VENDOR="$(awk -F: '/Vendor ID/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || true)"
CPU_TEXT="${CPU_MODEL} ${CPU_VENDOR} ${CPU_INFO}"
CPU_TEXT="$(echo "${CPU_TEXT}" | tr '[:upper:]' '[:lower:]')"

echo "${LOGPREFIX} Wykryty CPU:"
echo "${LOGPREFIX} ${CPU_MODEL}"

# 4) Pattern match
SELECTED_TARGET=""
SELECTED_PATTERN=""
for i in "${!patterns[@]}"; do
  pat="${patterns[$i]}"
  tar="${targets[$i]}"
  pat_lc="$(echo "${pat}" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]')"
  if [ -n "${pat_lc}" ] && echo "${CPU_TEXT}" | grep -F -i -q "${pat_lc}"; then
    SELECTED_TARGET="${tar}"
    SELECTED_PATTERN="${pat}"
    break
  fi
done

if [ -z "${SELECTED_TARGET}" ]; then
  for i in "${!patterns[@]}"; do
    if echo "${patterns[$i]}" | tr '[:upper:]' '[:lower:]' | grep -q "all x86-64"; then
      SELECTED_TARGET="${targets[$i]}"
      SELECTED_PATTERN="${patterns[$i]}"
      break
    fi
  done
fi

if [ -z "${SELECTED_TARGET}" ]; then
  echo "${LOGPREFIX} Brak dopasowania — używam domyślnego x86-64"
  SELECTED_TARGET="x86-64"
  SELECTED_PATTERN="(default x86-64)"
fi

echo "${LOGPREFIX} Dopasowano: '${SELECTED_PATTERN}' -> '${SELECTED_TARGET}'"

# 5) Mapowanie wariantu
if echo "${SELECTED_TARGET}" | grep -q "v3"; then
  XANMOD_VARIANT="x64v3"
elif echo "${SELECTED_TARGET}" | grep -q "v2"; then
  XANMOD_VARIANT="x64v2"
else
  XANMOD_VARIANT="x64v1"
fi

echo "${LOGPREFIX} Wybrana wersja xanmod: ${XANMOD_VARIANT}"

# 6) Instalacja repozytorium i pakietu
add_xanmod_repo() {
  echo "${LOGPREFIX} Dodaję repozytorium xanmod..."
  sudo mkdir -p /etc/apt/keyrings
  if ! command -v wget >/dev/null 2>&1; then
    echo "${LOGPREFIX} wget nieznalezione, instaluję wget..."
    sudo apt update
    sudo apt install -y wget
  fi
  wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /etc/apt/keyrings/xanmod-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $(lsb_release -sc) main" \
    | sudo tee /etc/apt/sources.list.d/xanmod-release.list > /dev/null
  sudo apt update
}

install_xanmod_pkg() {
  local pkg="$1"
  echo "${LOGPREFIX} Instaluję: ${pkg}"
  sudo apt install -y "${pkg}"
}

# NOTE: Nie usuwamy aktualnego jądra przed zainstalowaniem nowego.
# Usuwanie (purge) będzie wykonywane dopiero przez zewnętrzny skrypt
# /usr/share/HackerOS/Scripts/Bin/remove-debian-kernel.sh po zakończeniu instalacji.

case "${XANMOD_VARIANT}" in
  x64v3)
    add_xanmod_repo
    install_xanmod_pkg "linux-xanmod-lts-x64v3"
    ;;
  x64v2)
    add_xanmod_repo
    install_xanmod_pkg "linux-xanmod-lts-x64v2"
    ;;
  x64v1)
    add_xanmod_repo
    install_xanmod_pkg "linux-xanmod-lts-x64v1"
    ;;
  *)
    echo "${LOGPREFIX} Nieznany wariant. STOP."
    exit 1
    ;;
esac

echo "${LOGPREFIX} Instalacja kernela xanmod zakończona (jeśli nie było błędów)."

# 7) NVIDIA
echo "${LOGPREFIX} Sprawdzam NVIDIA..."
HAS_NVIDIA=0

if command -v lspci >/dev/null 2>&1; then
  if lspci -nnk | grep -i -E "nvidia|nvidia corporation" >/dev/null 2>&1; then
    HAS_NVIDIA=1
  fi
else
  echo "${LOGPREFIX} Brak lspci. Instaluję pciutils..."
  sudo apt update
  sudo apt install -y pciutils
  if lspci -nnk | grep -i -E "nvidia" >/dev/null 2>&1; then
    HAS_NVIDIA=1
  fi
fi

if [ "${HAS_NVIDIA}" -eq 1 ]; then
  echo "${LOGPREFIX} Wykryto NVIDIA — instaluję sterowniki."
  sudo apt update
  sudo apt install -y nvidia-driver nvidia-kernel-dkms nvidia-smi libnvidia-ml1 nvidia-settings nvidia-cuda-mps || {
    echo "${LOGPREFIX} Instalacja sterowników NVIDIA zakończyła się błędem."
  }
else
  echo "${LOGPREFIX} Nie wykryto NVIDIA."
fi

# 8) Po instalacji: uruchom zewnętrzny skrypt usuwający debianowe jądra (jeśli istnieje)
REMOVE_SCRIPT="/usr/share/HackerOS/Scripts/Bin/remove-debian-kernel.sh"
if [ -x "${REMOVE_SCRIPT}" ]; then
  echo "${LOGPREFIX} Uruchamiam skrypt usuwający stare jądra: ${REMOVE_SCRIPT}"
  # Uruchamiamy z sudo, bo skrypt może wymagać uprawnień do usunięcia pakietów.
  if sudo "${REMOVE_SCRIPT}"; then
    echo "${LOGPREFIX} Skrypt usuwania starych jąder zakończony pomyślnie."
  else
    echo "${LOGPREFIX} Skrypt usuwania jąder zakończył się błędem (kod niezerowy)."
  fi
else
  echo "${LOGPREFIX} Skrypt do usuwania debianowych jąder nie istnieje lub nie jest wykonywalny: ${REMOVE_SCRIPT}"
fi

# 9) Utwórz plik konfiguracyjny informujący o użyciu xanmod
CONFIG_DIR="${HOME}/.config/hackeros"
CONFIG_FILE="${CONFIG_DIR}/kernel.hacker"

echo "${LOGPREFIX} Tworzę katalog konfiguracji: ${CONFIG_DIR}"
mkdir -p "${CONFIG_DIR}"
echo "[xanmod]" > "${CONFIG_FILE}"
chmod 644 "${CONFIG_FILE}"
echo "${LOGPREFIX} Zapisano: ${CONFIG_FILE}"

# 10) Aktualizuj GRUB i poinformuj użytkownika
echo "${LOGPREFIX} Aktualizuję GRUB..."
sudo update-grub || true

echo "${LOGPREFIX} GOTOWE. Zrestartuj system, aby uruchomić nowe jądro."

