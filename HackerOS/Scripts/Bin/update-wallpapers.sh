#!/bin/bash

LOCAL_JSON="/usr/share/wallpapers/release-info.json"
REMOTE_VERSION_URL="https://raw.githubusercontent.com/HackerOS-Linux-System/HackerOS-Updates/main/wallpaper-updates/version.hacker"
TMP_DIR="/tmp/HackerOS-Updates"

# --- Odczyt wersji lokalnej ---
if [ ! -f "$LOCAL_JSON" ]; then
    echo "Brak pliku release-info.json!"
    exit 1
fi

LOCAL_VERSION=$(jq -r '.version' "$LOCAL_JSON" | sed 's/ .*//')

# --- Pobranie wersji z GitHuba ---
REMOTE_VERSION=$(curl -fsSL "$REMOTE_VERSION_URL" | tr -d '[]')

if [ -z "$REMOTE_VERSION" ]; then
    echo "Nie udało się pobrać wersji z GitHuba."
    exit 1
fi

# --- Porównanie wersji ---
is_newer=$(printf "%s\n%s" "$LOCAL_VERSION" "$REMOTE_VERSION" | sort -V | head -n1)

if [ "$is_newer" = "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$LOCAL_VERSION" ]; then
    echo "Znaleziono nowszą wersję tapet: $REMOTE_VERSION"
    echo "Aktualna wersja: $LOCAL_VERSION"

    # Usunięcie starego katalogu TMP
    rm -rf "$TMP_DIR"

    # Klonowanie repo
    git clone https://github.com/HackerOS-Linux-System/HackerOS-Updates.git "$TMP_DIR"

    if [ ! -d "$TMP_DIR/wallpaper-updates" ]; then
        echo "Brak katalogu wallpaper-updates w repozytorium!"
        exit 1
    fi

    # Przejście do katalogu
    cd "$TMP_DIR/wallpaper-updates" || exit 1

    # Uruchomienie komendy hacker
    hacker run unpack.hacker

    echo "Aktualizacja tapet zakończona."
else
    echo "Brak nowych wersji tapet. Obecna wersja: $LOCAL_VERSION"
fi
