# w3m-pi

Distro Linux **headless** para **Raspberry Pi Zero W** (y Zero 2 W): sin
entorno gráfico, centrada en herramientas de red y acceso remoto.
Basada en **Buildroot + BusyBox**, portando la filosofía de la suite
[w3m-net](https://github.com/0ldskoolerz/w3m-net) a CLI puro.

## Qué hace el sistema al arrancar

1. **Red automática** (`S20net`): intenta wlan0/eth0 con DHCP (3 reintentos)
2. **Modo AP de respaldo** (`S25apfallback`): si no hay wifi configurada
   o no conecta, se convierte en **punto de acceso** `w3m-pi` —
   conéctate y haz SSH para configurar la red real
3. **SSH desde el primer boot** (`S50dropbear`): root/w3mpi
4. **Consola serie UART** en el GPIO (115200 baud) para acceso sin red
5. Si encontró red, **anuncia su IP por multicast** (`S60announce`)

## Herramientas incluidas (todo CLI)

| Categoría | Herramientas | Uso |
|---|---|---|
| Diagnóstico red | ping, traceroute, netstat, route, arp, dig/nslookup | los equivalentes CLI de w3m-net |
| Escaneo | nmap (con -sn para LAN), tcpdump | inventario de red |
| Wifi | wpa_supplicant + wpa_cli + iw, iwlist | conectar y escanear redes |
| AP mode | hostapd + dnsmasq + udhcpd | el modo rescate |
| Acceso remoto | dropbear (SSH), consola serie UART | las dos vías de entrada |
| Transferencia | busybox wget, ftpget/ftpput, nc | mover archivos |
| Pi específico | raspinfo (vcgencmd si buildroot lo trae), gpio (sysfs), vcgencmd | estado del SoC |
| Sistema | busybox completo: top/ps/free/df, vi, mdev | base |

## Acceso remoto

- **SSH**: `ssh root@<ip-pi>` — contraseña `w3mpi` (cámbiala con `passwd`)
- **IP desconocida**: conéctate al AP `w3m-pi` (IP de la pi: `192.168.4.1`)
- **UART**: GPIO14/15 (TXD/RXD) a 115200 8N1, login root

## Compilar

Requiere Linux x86_64 con internet y ~10 GB libres:

```sh
sudo pacman -S base-devel rsync cpio python unzip wget
git clone --depth 1 --branch 2024.02 https://gitlab.com/buildroot/buildroot.git
git clone https://github.com/0ldskoolerz/w3m-pi.git
cd w3m-pi
./scripts/build.sh ../buildroot
# salida: ../buildroot/output/images/sdcard.img
```

## Instalar en la microSD

```sh
dd if=../buildroot/output/images/sdcard.img of=/dev/sdX bs=4M status=progress
# insertar en la Pi Zero W y alimentar
```

## Configurar la wifi real (tras SSH)

```sh
wpa_passphrase "TuRed" "TuClave" >> /etc/wpa_supplicant.conf
# y en AP mode: edita /etc/wpa_supplicant.conf igual, luego reboot
```

## Estructura

```
configs/w3m_pi_defconfig    Buildroot para BCM2835 (armv6l, Pi Zero W)
board/w3m-pi/
  linux-w3mpi.config         kernel Raspberry Pi (UART, wifi onboard)
  rootfs-overlay/
    etc/inittab              consola serie + tty1
    etc/init.d/S20net        DHCP automatico wlan0/eth0
    etc/init.d/S25apfallback modo AP de rescate
    etc/init.d/S60announce   anuncia IP por multicast
    etc/motd                 ayuda de primer arranque
scripts/build.sh
docs/                        guias
```

## Relación con el ecosistema

- [w3m-net](https://github.com/0ldskoolerz/w3m-net): las mismas 11 áreas
  de red, aquí en CLI puro para el Pi
- [w3m-linux](https://github.com/0ldskoolerz/w3m-linux): la distro con
  escritorio W3M (x86_64); w3m-pi es su hermana headless ARM
- Filosofía: mismo external-tree de Buildroot, busybox everywhere
