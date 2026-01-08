# WiFi Troubleshooting

## Broadcom BCM4350 on MacBook 10,1

The MacBook 10,1 uses a Broadcom BCM4350 802.11ac WiFi chip. This requires the proprietary `wl` driver for reliable operation.

## Installation

### Step 1: Install the Driver

```bash
sudo apt update
sudo apt install bcmwl-kernel-source
```

This installs the Broadcom STA driver (wl) and builds it with DKMS.

### Step 2: Configure Driver Blacklist

The wl driver conflicts with open-source Broadcom drivers. Create or verify this file:

**`/etc/modprobe.d/broadcom-sta-dkms.conf`**:
```
# wl module from Broadcom conflicts with the following modules:
blacklist b43
blacklist b43legacy
blacklist b44
blacklist bcma
blacklist brcm80211
blacklist brcmsmac
blacklist ssb
```

### Step 3: Update Initramfs

```bash
sudo update-initramfs -u
```

### Step 4: Reboot

```bash
sudo reboot
```

## Verification

### Check Driver is Loaded

```bash
lsmod | grep wl
# Should show: wl  <size>  0

lspci -k | grep -A3 "Network controller"
# Should show:
#   Kernel driver in use: wl
#   Kernel modules: bcma, wl
```

### Check Interface Exists

```bash
ip link show
# Look for wlan0 or similar

iwconfig
# Should show wireless extensions for your interface
```

### Check NetworkManager

```bash
nmcli device status
# wlan0 should show as "wifi" type

nmcli device wifi list
# Should show available networks
```

## Common Issues

### WiFi Not Working After Install

1. **Driver not loaded**:
   ```bash
   sudo modprobe wl
   ```

2. **Conflicting drivers loaded**:
   ```bash
   sudo rmmod b43 brcmfmac brcmsmac 2>/dev/null
   sudo modprobe wl
   ```

3. **DKMS build failed** (after kernel update):
   ```bash
   sudo apt install --reinstall bcmwl-kernel-source
   sudo update-initramfs -u
   sudo reboot
   ```

### WiFi Stops After Suspend

Create a systemd sleep hook:

**`/usr/lib/systemd/system-sleep/wifi-resume.sh`**:
```bash
#!/bin/bash
case $1 in
    post)
        modprobe -r wl
        modprobe wl
        ;;
esac
```

```bash
sudo chmod +x /usr/lib/systemd/system-sleep/wifi-resume.sh
```

### Slow WiFi or Disconnects

Try disabling power saving:

```bash
sudo iwconfig wlan0 power off
```

To make permanent, add to `/etc/NetworkManager/conf.d/wifi-powersave.conf`:
```
[connection]
wifi.powersave = 2
```

### Cannot See 5GHz Networks

Ensure regulatory domain is set:

```bash
sudo iw reg set US  # Or your country code
```

## Logs and Debugging

### Check dmesg

```bash
dmesg | grep -i broadcom
dmesg | grep -i wl
dmesg | grep -i wlan
```

### Check NetworkManager logs

```bash
journalctl -u NetworkManager -f
```

### Full wireless info

```bash
sudo lshw -C network
```

## Alternative: Use brcmfmac (Not Recommended)

The open-source `brcmfmac` driver sometimes works but is less reliable:

```bash
# Remove wl driver
sudo apt remove bcmwl-kernel-source

# Remove blacklist
sudo rm /etc/modprobe.d/broadcom-sta-dkms.conf

# Install firmware
sudo apt install linux-firmware

# Reboot
sudo reboot
```

If this doesn't work, reinstall bcmwl-kernel-source.
