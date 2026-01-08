# Modprobe Configuration

Kernel module configuration for hardware drivers.

## Files

- `broadcom-sta-dkms.conf` - Broadcom WiFi driver blacklist

## Broadcom WiFi (BCM4350)

The MacBook 10,1 uses a Broadcom BCM4350 802.11ac WiFi chip. The proprietary `wl` driver from `bcmwl-kernel-source` provides the best compatibility.

### Why Blacklist?

The `wl` driver conflicts with open-source Broadcom drivers. These must be blacklisted:

- `b43` - Open-source Broadcom driver
- `b43legacy` - Legacy Broadcom driver
- `b44` - Broadcom Ethernet driver
- `bcma` - Broadcom bus driver
- `brcm80211` - Alternative Broadcom driver
- `brcmsmac` - Soft-MAC Broadcom driver
- `ssb` - Silicon Sonics bus driver

### Installation

```bash
sudo cp broadcom-sta-dkms.conf /etc/modprobe.d/
sudo update-initramfs -u
sudo reboot
```

### Troubleshooting

If WiFi doesn't work after reboot:
```bash
# Check if wl module is loaded
lsmod | grep wl

# Check dmesg for errors
dmesg | grep -i broadcom

# Manually load driver
sudo modprobe wl
```

### Dependencies

```bash
sudo apt install bcmwl-kernel-source
```
