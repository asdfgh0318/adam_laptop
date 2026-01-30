# ThinkPad T480s Hardware Specifications

## Overview
- **Model**: Lenovo ThinkPad T480s (Type 20L7/20L8)
- **Year**: 2018
- **Form Factor**: 14" ultrabook, ~1.32kg

## Components

| Component | Hardware | Driver |
|-----------|----------|--------|
| CPU | Intel 8th Gen (Kaby Lake-R) i5-8250U or i7-8550U | intel-microcode |
| GPU | Intel UHD Graphics 620 | i915 (kernel) + Mesa |
| WiFi | Intel Wireless-AC 8265 (802.11ac 2x2) | iwlwifi (linux-firmware) |
| Audio | Intel Sunrise Point-LP (Realtek ALC257) | PipeWire + snd_hda_intel |
| Display | 14" IPS FHD (1920x1080) or WQHD (2560x1440) | intel_backlight |
| Storage | M.2 2280 NVMe/SATA | nvme / ahci (kernel) |
| TrackPoint | Pointing stick + 3 buttons | libinput |
| Touchpad | ELAN/Synaptics clickpad | libinput |
| Fingerprint | Validity/Synaptics (06cb:xxxx) | fprintd |
| Thunderbolt | 2x USB-C (Thunderbolt 3) | bolt |
| USB | 2x USB-A 3.0 | xhci (kernel) |
| HDMI | HDMI 1.4b | i915 |
| Card reader | microSD | kernel |
| Bluetooth | Intel integrated (BT 4.2) | BlueZ + btusb |
| Battery | Internal 57Wh Li-Po | TLP + acpi-call |
| Keyboard | 6-row backlit | tpacpi::kbd_backlight |

## Ports Layout

```
Left side:   USB-C (TB3) | USB-C (TB3) | USB-A 3.0 | HDMI | Headphone
Right side:  USB-A 3.0 | microSD | Kensington lock
```

## Keyboard Backlight
- Device: `tpacpi::kbd_backlight`
- Levels: 0 (off), 1 (dim), 2 (bright)
- Control: `brightnessctl -d tpacpi::kbd_backlight set 1+`

## Battery
- Path: `/sys/class/power_supply/BAT0`
- Charger: USB-C PD (65W recommended)
- TLP thresholds: Start 75%, Stop 80% (configured by install script)

## BIOS (UEFI) Settings

Access: Press **F1** during boot

| Setting | Recommended | Reason |
|---------|-------------|--------|
| Secure Boot | Disabled | DKMS driver compatibility |
| Thunderbolt Security | User Authorization | bolt handles auth in Linux |
| Thunderbolt BIOS Assist | Disabled | Let OS manage Thunderbolt |
| F1-F12 as Primary | Enabled (FnLock) | Standard function keys |
| Intel SpeedStep | Enabled | Power management |
| Intel Speed Shift | Enabled | 8th gen power optimization |
| Wake on LAN | Disabled | Save power |
| Intel VT-x | Enabled | Virtualization support |
| Intel VT-d | Enabled | IOMMU passthrough |
| Boot Mode | UEFI Only | Modern Linux standard |
| USB Boot | Enabled | Recovery access |

## Packages Installed by 02-drivers-t480s.sh

```bash
intel-microcode
libgl1-mesa-dri
mesa-vulkan-drivers
intel-media-va-driver
linux-firmware
thermald
tlp tlp-rdw
acpi-call-dkms
bolt
fprintd libpam-fprintd  # if reader detected
```

## Known Issues

1. **Fingerprint reader** - Some T480s revisions have unsupported Synaptics readers. Check `lsusb | grep -i finger`.
2. **Thunderbolt docks** - First connection requires `boltctl authorize` or will be prompted.
3. **Screen brightness** - If keys don't work, may need kernel param `i915.enable_dpcd_backlight=1`.
4. **Keyboard backlight** - Only 3 states (off/dim/bright), no smooth dimming.
