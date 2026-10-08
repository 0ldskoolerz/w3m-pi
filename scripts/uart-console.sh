#!/bin/sh
# uart-console.sh — conecta a la consola serie de la Pi Zero W
# Requiere adaptador USB-TTL (GPIO14=TXD, GPIO15=RXD, GND)
# Uso: ./scripts/uart-console.sh [dispositivo] [baudios]

set -e
DEV="${1:-/dev/ttyUSB0}"
SPEED="${2:-115200}"

if [ ! -e "$DEV" ]; then
    echo "No existe $DEV — conecta el adaptador USB-TTL:"
    echo "  Pi GPIO4 (pin 7, TXD)  -> RX del adaptador"
    echo "  Pi GPIO5 (pin 27 no, usar pin fisico 8 = GPIO14/TXD)"
    echo "  Pin fisico 8  = GPIO14 TXD -> adaptador RX"
    echo "  Pin fisico 10 = GPIO15 RXD -> adaptador TX"
    echo "  Pin fisico 6  = GND       -> adaptador GND"
    exit 1
fi

exec screen "$DEV" "$SPEED" 2>/dev/null || exec picocom -b "$SPEED" "$DEV"
