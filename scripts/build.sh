#!/bin/sh
# build.sh — construye w3m-pi (Buildroot external tree para Pi Zero W)
# Uso: ./scripts/build.sh [ruta-a-buildroot]

set -e
cd "$(dirname "$0")/.."
W3MPI_TREE="$PWD"

BR2_DIR="${1:-${BR2_DIR:-../buildroot}}"
if [ ! -f "$BR2_DIR/Makefile" ]; then
    echo "Buildroot no encontrado en: $BR2_DIR"
    echo "Obténlo:  git clone --depth 1 --branch 2024.02 https://gitlab.com/buildroot/buildroot.git"
    exit 1
fi

cd "$BR2_DIR"
make BR2_EXTERNAL="$W3MPI_TREE" w3m_pi_defconfig
make BR2_EXTERNAL="$W3MPI_TREE" -j"$(nproc)"

echo
echo "== Listo: $BR2_DIR/output/images/"
ls -lh output/images/ || true
echo
echo "Graba la SD:  dd if=output/images/sdcard.img of=/dev/sdX bs=4M status=progress"
