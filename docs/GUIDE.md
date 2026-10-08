# w3m-pi — Guía completa (Pi Zero W headless)

## 1. Compilar la imagen

Host: Linux x86_64 con `base-devel rsync cpio python unzip wget`, ~10 GB libres.

```sh
git clone --depth 1 --branch 2024.02 https://gitlab.com/buildroot/buildroot.git
git clone https://github.com/0ldskoolerz/w3m-pi.git
cd w3m-pi
./scripts/build.sh ../buildroot     # 45–120 min primera vez (cross-ARM)
```

Salida: `../buildroot/output/images/sdcard.img`

## 2. Grabar la microSD

```sh
lsblk                              # identifica la SD (¡cuidado con el dispositivo!)
dd if=../buildroot/output/images/sdcard.img of=/dev/sdX bs=4M status=progress conv=fsync
```

## 3. Primer arranque

Alimenta la Pi con la SD. Sin pantalla ni teclado, la secuencia es:

1. **S20net**: intenta wifi con `/etc/wpa_supplicant.conf` (vacío de
   fábrica → fallará) y DHCP en eth0 si hay adaptador USB
2. **S25apfallback**: al fallar la wifi, monta el **AP de rescate**:
   - Red WiFi: `w3m-pi`, clave: `w3mpi-ap`
   - La Pi queda en `192.168.4.1`
3. **Conéctate** desde tu PC/telefono a esa red y:
   ```sh
   ssh root@192.168.4.1        # contraseña: w3mpi
   ```

### Configurar la wifi real (una vez dentro)

```sh
wpa_passphrase "TuRed" "TuClave" >> /etc/wpa_supplicant.conf
reboot
# tras el reboot, la Pi conecta sola y el AP de rescate ya no se activa
```

### Si no sabes la IP que tomó

- Mira tu router (clientes DHCP), o
- `nmap -sn 192.168.1.0/24` desde tu PC (aparece como `w3m-pi`), o
- Consola serie (siguiente sección)

## 4. Acceso por consola serie (UART)

Sin red y sin AP útil, el UART siempre funciona — es la vía de rescate
definitiva:

**Cableado** (adaptador USB-TTL a 3.3V, ¡no 5V!):

| Pi Zero W (pin físico) | Señal | Adaptador |
|---|---|---|
| 8 | GPIO14 / TXD | RX |
| 10 | GPIO15 / RXD | TX |
| 6 | GND | GND |

```sh
./scripts/uart-console.sh /dev/ttyUSB0 115200
# login: root / w3mpi
```

## 5. Herramientas de red — chuleta por tarea

| Tarea | Comando |
|---|---|
| ¿Tengo IP? | `ip addr` / `ifconfig` |
| ¿Gateway? | `route -n` |
| ¿Llega internet? | `ping 8.8.8.8` luego `ping google.com` (si IP sí, dominio no → DNS) |
| ¿Qué hay en mi LAN? | `nmap -sn 192.168.1.0/24` |
| ¿Puertos de un host? | `nmap -sV 192.168.1.5` |
| ¿Quién es esta IP? | `dig -x 192.168.1.5` (PTR) |
| Escanear redes wifi | `iwlist wlan0 scan` |
| Capturar tráfico | `tcpdump -i wlan0 not port 22` |
| ¿Está abierto un puerto? | `nc -zv 192.168.1.5 80` |
| Transferir un archivo | `nc -l -p 9999 > archivo` (y del otro lado `nc ip 9999 < archivo`) |
| Tabla ARP (vecinos) | `arp -n` |

La metodología completa de análisis en 5 fases está en
[w3m-net/docs/ANALISIS.md](https://github.com/0ldskoolerz/w3m-net/blob/main/docs/ANALISIS.md)
— aplica igual, solo que con comandos en vez de apps.

## 6. Pi Zero W específico

| Tarea | Comando |
|---|---|
| Temperatura | `cat /sys/class/thermal/thermal_zone0/temp` (miles de °C) |
| Frecuencia actual | `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` |
| Throttling | `vcgencmd get_throttled` (0x0 = sano) |
| Memoria | `free -m` |
| Estado wifi | `iwconfig wlan0` / `iw dev wlan0 link` |
| GPIO | `echo 17 > /sys/class/gpio/export` etc. |

## 7. Endurecimiento básico (recomendado tras instalar)

```sh
passwd                          # cambia la contraseña root
# deshabilita login root directo por SSH si prefieres claves:
# /etc/init.d/S50dropbear añade -w tras "dropbear" si quieres deny root
```

⚠️ El AP de rescate usa una clave fija documentada — si tu Pi va a
convivir en redes ajenas, considera deshabilitarlo (`chmod -x
/etc/init.d/S25apfallback`) tras configurar la wifi real.
