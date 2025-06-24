#!/usr/bin/env bash

# Ustawienia
ANIMATION_SOURCE="/usr/share/HackerOS/Animations/HackerOS.webm"
OVRDIR="$HOME/.local/share/Steam/config/uioverrides/movies"
SKIP_VIDEOS=false

# Sprawdzenie, czy użytkownik chce pominąć animacje
if [ -f "$OVRDIR/HackerOS_novideo" ]; then
    SKIP_VIDEOS=true
fi

if ! $SKIP_VIDEOS; then
    mkdir -p "$OVRDIR"

    STARTUP_LOCATIONS=(
        "bigpicture_startup.webm"
        "deck_startup.webm"
        "oled_startup.webm"
        "steam_os_startup.webm"
    )

    SUSPEND_LOCATIONS=(
        "deck-suspend-animation-from-throbber.webm"
        "oled-suspend-animation-from-throbber.webm"
        "steam_os_suspend_from_throbber.webm"
        "deck-suspend-animation.webm"
        "oled-suspend-animation.webm"
        "steam_os_suspend.webm"
    )

    # Nadpisywanie animacji startowych
    for STARTUP in "${STARTUP_LOCATIONS[@]}"; do
        TARGET="$OVRDIR/$STARTUP"
        if ! cmp --silent "$ANIMATION_SOURCE" "$TARGET"; then
            cp "$ANIMATION_SOURCE" "$TARGET"
        fi
    done

    # Nadpisywanie animacji suspendu
    for SUSPEND in "${SUSPEND_LOCATIONS[@]}"; do
        TARGET="$OVRDIR/$SUSPEND"
        if ! cmp --silent "$ANIMATION_SOURCE" "$TARGET"; then
            cp "$ANIMATION_SOURCE" "$TARGET"
        fi
    done
fi
