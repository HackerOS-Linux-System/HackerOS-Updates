#!/bin/bash

# Funkcja sprawdzająca czy Plasma działa na tty2
is_plasma_running() {
    pgrep -a startplasma-wayland | grep -q "tty2"
}

if is_plasma_running; then
    echo "[INFO] Plasma już działa na tty2 → tylko przełączam."
    sudo chvt 2
else
    echo "[INFO] Plasma nie działa → uruchamiam na tty2."
    # Przełącz na tty2
    sudo chvt 2
    sleep 1
    # Odpal Plasma Wayland w tty2
    sudo openvt -c 2 -s -w -- /usr/bin/startplasma-wayland &
fi
