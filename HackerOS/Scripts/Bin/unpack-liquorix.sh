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
#    ,--,                                                             
# ,---.'|                                                             
# |   | :                                                             
# :   : |     ,--,  ,----.                                     ,--,   
# |   ' :   ,--.'| /   /  \-.         ,--,   ,---.    __  ,-.,--.'|   
# ;   ; '   |  |, |   :    :|       ,'_ /|  '   ,'\ ,' ,'/ /||  |,    
# '   | |__ `--'_ |   | .\  .  .--. |  | : /   /   |'  | |' |`--'_    
# |   | :.'|,' ,'|.   ; |:  |,'_ /| :  . |.   ; ,. :|  |   ,',' ,'|   
# '   :    ;'  | |'   .  \  ||  ' | |  . .'   | |: :'  :  /  '  | |   
# |   |  ./ |  | : \   `.   ||  | ' |  | |'   | .; :|  | '   |  | :   
# ;   : ;   '  : |__`--'""| |:  | : ;  ; ||   :    |;  : |   '  : |__ 
# |   ,/    |  | '.'| |   | |'  :  `--'   \\   \  / |  , ;   |  | '.'|
# '---'     ;  :    ; |   | ::  ,      .-./ `----'   ---'    ;  :    ;
#           |  ,   /  `---'.| `--`----'                      |  ,   / 
#  ,--,  ,--,---`-'     `---`                                 ---`-'  
#  |'. \/ .`|                                                         
#  '  \/  / ;                                                         
#   \  \.' /                                                          
#    \  ;  ;                                                          
#   / \  \  \                                                         
# ./__;   ;  \                                                        
# |   :/\  \ ;                                                        
# `---'  `--`                                                                         

set -euo pipefail

TMPFILE="/tmp/xanmod-cpu.hacker"
GITHUB_RAW="https://raw.githubusercontent.com/HackerOS-Linux-System/Hacker-Lang/main/hacker-packages/xanmod-cpu.hacker"
LOGPREFIX="[liquorix-installer]"

echo "${LOGPREFIX} Start"

# 1) Pobierz plik
echo "${LOGPREFIX} Pobieram plik z GitHub: ${GITHUB_RAW} -> ${TMPFILE}"
if ! command -v curl >/dev/null 2>&1; then
  echo "${LOGPREFIX} curl nieznalezione, instaluję curl..."
  sudo apt update
  sudo apt install -y curl
fi

if ! curl -fsSL -o "${TMPFILE}" "${GITHUB_RAW}"; then
  echo "${LOGPREFIX} Błąd pobierania pliku z GitHub."
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
  echo "${LOGPREFIX} Brak poprawnych mapowań."
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
  pat="$(echo "${patterns[$i]}" | tr '[:upper:]' '[:lower:]')"
  tar="${targets[$i]}"
  if [ -n "${pat}" ] && echo "${CPU_TEXT}" | grep -F -i -q "${pat}"; then
    SELECTED_TARGET="${tar}"
    SELECTED_PATTERN="${patterns[$i]}"
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

# 5) Wariant CPU
if echo "${SELECTED_TARGET}" | grep -q "v3"; then
  CPU_VARIANT="x64v3"
elif echo "${SELECTED_TARGET}" | grep -q "v2"; then
  CPU_VARIANT="x64v2"
else
  CPU_VARIANT="x64v1"
fi

echo "${LOGPREFIX} Wariant CPU: ${CPU_VARIANT}"

# 6) Instalacja Liquorix
echo "${LOGPREFIX} Instaluję jądro Liquorix..."

if ! curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash; then
  echo "${LOGPREFIX} Błąd instalacji Liquorix!"
  exit 1
fi

echo "${LOGPREFIX} Jądro Liquorix zainstalowane."

# 6.1) Usuwanie starego jądra — Z MODYFIKACJĄ KTÓREJ CHCIAŁEŚ
current_kernel="$(uname -r)"

echo "${LOGPREFIX} Usuwam stare jądro: ${current_kernel}"

export DEBIAN_FRONTEND=noninteractive
sudo apt remove --purge -y "${current_kernel}" || true

echo "${LOGPREFIX} Stare jądro usunięte."

# 7) NVIDIA
echo "${LOGPREFIX} Sprawdzam NVIDIA..."
HAS_NVIDIA=0

if command -v lspci >/dev/null 2>&1; then
  if lspci -nnk | grep -i -E "nvidia|nvidia corporation" >/dev/null 2>&1; then
    HAS_NVIDIA=1
  fi
else
  echo "${LOGPREFIX} Instaluję pciutils..."
  sudo apt update
  sudo apt install -y pciutils
  if lspci -nnk | grep -i "nvidia" >/dev/null 2>&1; then
    HAS_NVIDIA=1
  fi
fi

if [ "${HAS_NVIDIA}" -eq 1 ]; then
  echo "${LOGPREFIX} Wykryto NVIDIA — instaluję sterowniki."
  sudo apt update
  sudo apt install -y nvidia-driver nvidia-kernel-dkms nvidia-smi libnvidia-ml1 nvidia-settings nvidia-cuda-mps || {
    echo "${LOGPREFIX} Błąd instalacji sterowników NVIDIA."
  }
else
  echo "${LOGPREFIX} Nie wykryto NVIDIA."
fi

echo "${LOGPREFIX} GOTOWE. Zrestartuj system, aby włączyć jądro Liquorix."
