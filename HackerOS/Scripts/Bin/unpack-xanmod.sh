#!/bin/bash
#   .--.--.                 ___
#  /  /    '.             ,--.'|_
# |  :  /`. /             |  | :,'
# ;  |  |--`              :  : ' :
# |  :  ;_       ,---.  .;__,'  /
#  \  \    `.   /     \ |  |   |
#   `----.   \ /    /  |:__,'| :
#   __ \  \  |.    ' / |  '  : |__
#  /  /`--'  /'   ;   /|  |  | '.'|
# '--'.     / '   |  / |  ;  :    ;
#   `--'---'  |   :    |  |  ,   /             ____
#              \   \  /    ---`-'            ,'  , `.                ,---,
#               `----'          ,---,     ,-+-,.' _ |   ,---.      ,---.'|
#  ,--,  ,--,               ,-+-. /  | ,-+-. ;   , ||  '   ,'\     |   | :
#  |'. \/ .`|   ,--.--.    ,--.'|'   |,--.'|'   |  || /   /   |    |   | |
#  '  \/  / ;  /       \  |   |  ,"' |   |  ,', |  |,.   ; ,. :  ,--.__| |
#   \  \.' /  .--.  .-. | |   | /  | |   | /  | |--' '   | |: : /   ,'   |
#    \  ;  ;   \__\/: . . |   | |  | |   : |  | ,    '   | .; :.   '  /  |
#   / \  \  \  ," .--.; | |   | |  |/|   : |  |/     |   :    |'   ; |:  |
# ./__;   ;  \/  /  ,.  | |   | |--' |   | |`-'       \   \  / |   | '/  '
# |   :/\  \ ;  :   .'   \|   |/     |   ;/            `----'  |   :    :|
# `---'  `--`|  ,     .-./'---'      '---'                      \   \  /
#             `--`---'                                     ,--,  `-==='
#       ,---,            .--.,                           ,--.'|  ,--.'|_
#     ,---.'|          ,--.'  \                     ,--, |  | :  |  | :,'
#     |   | :          |  | /\/                   ,'_ /| :  : '  :  : ' :
#     |   | |   ,---.  :  : :    ,--.--.     .--. |  | : |  ' |.;__,'  /
#   ,--.__| |  /     \ :  | |-, /       \  ,'_ /| :  . | '  | ||  |   |
#  /   ,'   | /    /  ||  : :/|.--.  .-. | |  ' | |  . . |  | ::__,'| :
# .   '  /  |.    ' / ||  |  .' \__\/: . . |  | ' |  | | '  : |__'  : |__
# '   ; |:  |'   |  / ||  : '   ," .--.; | :  | : ;  ; | |  | '.'|  | '.'|
# |   | '/  ''   |  / ||  | |  /  /  ,.  | '  :  `--'   \;  :    ;  :    ;
# |   :    :||   :    ||  : \ ;  :   .'   \:  ,      .-./|  ,   /|  ,   /
#  \   \  /   \   \  / |  |,' |  ,     .-./ `--`----'     ---`-'  ---`-'
#   `----'     `----'  `--'    `--`---'

set -euo pipefail

# install-xanmod.sh
# Pobiera plik xanmod-cpu.hacker do /tmp, dopasowuje CPU do x64/x64-v2/x64-v3 i uruchamia odpowiednie komendy.
# Dodatkowo, jeśli wykryje GPU NVIDIA, instaluje sterowniki NVIDIA.

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

# 2) Wczytaj i sparsuj mapowania: "pattern > target"
# Usuwamy linie puste i komentarze (zaczynające się od #) i nawiasy [] jeśli są
mapfile -t mappings < <(sed -e 's/^\s*//;s/\s*$//' "${TMPFILE}" \
                       | sed '/^\s*$/d' \
                       | sed '/^\s*#/d' \
                       | sed 's/^\[\(.*\)\]$/\1/' \
                       | awk -F'>' '/>/{gsub(/^[ \t]+|[ \t]+$/,"",$1); gsub(/^[ \t]+|[ \t]+$/,"",$2); print $1 "###" $2 }')

if [ ${#mappings[@]} -eq 0 ]; then
  echo "${LOGPREFIX} Nie znaleziono poprawnych mapowań w pliku. Kończę."
  exit 1
fi

# Przygotuj tablicę z par (pattern, target) i posortuj wg długości patternu malejąco (bardziej specyficzne pierwsze)
declare -a patterns
declare -a targets

# tymczasowy plik sortujący po długości patternu
tmp_sort="$(mktemp)"
for m in "${mappings[@]}"; do
  pat="${m%%###*}"
  tar="${m##*###}"
  # escape tabs/newlines
  printf '%s\t%s\n' "${pat}" "${tar}" >> "${tmp_sort}"
done

# sortuj malejąco po długości pola 1
while IFS=$'\t' read -r pat tar; do
  echo "${pat}###${tar}"
done < <(awk -F'\t' '{print length($1), $0}' "${tmp_sort}" | sort -rn | cut -d' ' -f2- | sed 's/\t/###/')

# wczytaj do tablic
mapfile -t sorted_pairs < <(awk -F'\t' '{print length($1) "\t" $0}' "${tmp_sort}" | sort -rn | cut -f2- | awk -F'\t' '{print $1 "###" $2 }')

rm -f "${tmp_sort}"

patterns=()
targets=()
for sp in "${sorted_pairs[@]}"; do
  patterns+=("${sp%%###*}")
  targets+=("${sp##*###}")
done

# 3) Odczytaj informacje o CPU do zmiennej (użyjemy lscpu i /proc/cpuinfo)
CPU_INFO="$(lscpu 2>/dev/null || true)"
CPU_MODEL="$(awk -F: '/Model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || true)"
CPU_VENDOR="$(awk -F: '/Vendor ID/ {print $2; exit}' /proc/cpuinfo 2>/dev/null || true)"
CPU_TEXT="${CPU_MODEL} ${CPU_VENDOR} ${CPU_INFO}"
CPU_TEXT="$(echo "${CPU_TEXT}" | tr '[:upper:]' '[:lower:]')"

echo "${LOGPREFIX} Wykryty CPU (fragment):"
echo "${LOGPREFIX} ${CPU_MODEL}" | sed -n '1p'

# 4) Dopasowanie: szukamy pierwszego patternu, którego lowercase substring występuje w CPU_TEXT
SELECTED_TARGET=""
SELECTED_PATTERN=""
for i in "${!patterns[@]}"; do
  pat="${patterns[$i]}"
  tar="${targets[$i]}"
  # znormalizuj pattern do lowercase
  pat_lc="$(echo "${pat}" | tr '[:upper:]' '[:lower:]')"
  # zamień wielokrotne spacje na pojedynczą
  pat_lc="$(echo "${pat_lc}" | tr -s '[:space:]')"
  # prosty substring match
  if [ -n "${pat_lc}" ] && echo "${CPU_TEXT}" | grep -F -i -q "${pat_lc}"; then
    SELECTED_TARGET="${tar}"
    SELECTED_PATTERN="${pat}"
    break
  fi
done

# Fallback: jeśli nic nie znaleziono - spróbuj dopasować "all x86-64" lub ustaw default x86-64
if [ -z "${SELECTED_TARGET}" ]; then
  # spróbuj znaleźć linię zawierającą "all x86-64"
  for i in "${!patterns[@]}"; do
    if echo "${patterns[$i]}" | tr '[:upper:]' '[:lower:]' | grep -q "all x86-64"; then
      SELECTED_TARGET="${targets[$i]}"
      SELECTED_PATTERN="${patterns[$i]}"
      break
    fi
  done
fi

if [ -z "${SELECTED_TARGET}" ]; then
  echo "${LOGPREFIX} Nie znaleziono dopasowania w pliku. Ustawiam domyślne: x86-64"
  SELECTED_TARGET="x86-64"
  SELECTED_PATTERN="(default x86-64)"
fi

echo "${LOGPREFIX} Dopasowano pattern: '${SELECTED_PATTERN}' -> '${SELECTED_TARGET}'"

# 5) Mapowanie docelowe na wersję xanmod (v1/v2/v3)
# Przyjmujemy prostą regułę: jeśli target zawiera "v3" -> x64v3, "v2" -> x64v2, jeśli tylko "x86-64" -> x64v1
XANMOD_VARIANT=""
if echo "${SELECTED_TARGET}" | grep -q -E "v3"; then
  XANMOD_VARIANT="x64v3"
elif echo "${SELECTED_TARGET}" | grep -q -E "v2"; then
  XANMOD_VARIANT="x64v2"
else
  XANMOD_VARIANT="x64v1"
fi

echo "${LOGPREFIX} Wybrana wersja xanmod: ${XANMOD_VARIANT}"

# 6) Przygotuj i uruchom odpowiednie komendy dla wybranej wersji
# Wspólny blok: dodanie repozytorium xanmod (klucz + sources.list)
add_xanmod_repo() {
  echo "${LOGPREFIX} Dodaję repozytorium xanmod i klucz..."
  sudo mkdir -p /etc/apt/keyrings
  # używamy wget jak w twoim przykładzie, ale bez -qO - ponieważ chcemy przekierować do gpg --dearmor
  wget -qO - https://dl.xanmod.org/archive.key | sudo gpg --dearmor -o /etc/apt/keyrings/xanmod-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/xanmod-release.list > /dev/null
  sudo apt update
}

remove_old_image() {
  # Usunięcie konkretnego obrazu (zgodnie z twoim przykładem)
  echo "${LOGPREFIX} Usuwam linux-image-6.19.9+deb14-amd64 (jeśli zainstalowany)..."
  if dpkg -l | awk '{print $2}' | grep -q "^linux-image-6.19.9+deb14-amd64$"; then
    sudo apt remove --purge -y linux-image-6.19.9+deb14-amd64 || true
  else
    echo "${LOGPREFIX} Brak pakietu linux-image-6.19.9+deb14-amd64."
  fi
  echo "${LOGPREFIX} Aktualizuję GRUB..."
  sudo update-grub || true
}

install_xanmod_pkg() {
  local pkg="$1"
  echo "${LOGPREFIX} Instaluję: ${pkg}"
  sudo apt install -y "${pkg}"
}

case "${XANMOD_VARIANT}" in
  x64v3)
    add_xanmod_repo
    install_xanmod_pkg "linux-xanmod-lts-x64v3"
    remove_old_image
    ;;
  x64v2)
    add_xanmod_repo
    install_xanmod_pkg "linux-xanmod-lts-x64v2"
    remove_old_image
    ;;
  x64v1)
    add_xanmod_repo
    install_xanmod_pkg "linux-xanmod-lts-x64v1"
    remove_old_image
    ;;
  *)
    echo "${LOGPREFIX} Nieznany wariant ${XANMOD_VARIANT}. Kończę."
    exit 1
    ;;
esac

# 7) Wykryj GPU NVIDIA (przez lspci). Jeśli jest, zainstaluj pakiety NVIDIA
echo "${LOGPREFIX} Sprawdzam obecność GPU NVIDIA..."
HAS_NVIDIA=0
if command -v lspci >/dev/null 2>&1; then
  if lspci -nnk | grep -i -E "nvidia|nvidia corporation" >/dev/null 2>&1; then
    HAS_NVIDIA=1
  fi
else
  echo "${LOGPREFIX} lspci nie jest dostępne. Instaluję pciutils..."
  sudo apt update
  sudo apt install -y pciutils
  if lspci -nnk | grep -i -E "nvidia|nvidia corporation" >/dev/null 2>&1; then
    HAS_NVIDIA=1
  fi
fi

if [ "${HAS_NVIDIA}" -eq 1 ]; then
  echo "${LOGPREFIX} Wykryto GPU NVIDIA — instaluję sterowniki."
  sudo apt update
  sudo apt install -y nvidia-driver nvidia-kernel-dkms nvidia-smi libnvidia-ml1 nvidia-settings nvidia-cuda-mps || {
    echo "${LOGPREFIX} Instalacja pakietów NVIDIA napotkała problem."
  }
else
  echo "${LOGPREFIX} Nie wykryto GPU NVIDIA."
fi

echo "${LOGPREFIX} Gotowe. Zrestartuj system aby użyć nowego jądra (jeśli zainstalowano)."
