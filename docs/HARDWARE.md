# Hardware Specifications

## MacBook 10,1 (2017 MacBook)

### Overview
- **Model**: Apple MacBook 10,1
- **Year**: 2017
- **Form Factor**: Ultra-thin laptop

### CPU
- **Processor**: Intel 7th Generation Core (Kaby Lake)
- **Chipset**: Sunrise Point-LP
- **Microcode**: `intel-microcode` package

### Graphics
- **GPU**: Intel HD Graphics 615 (integrated)
- **Driver**: i915 (kernel built-in)
- **OpenGL**: Mesa
- **Vulkan**: mesa-vulkan-drivers

### Storage
- **Controller**: Apple S3X NVMe Controller
- **Interface**: PCIe NVMe
- **Driver**: nvme (kernel built-in)

### Network

#### WiFi
- **Chip**: Broadcom BCM4350 802.11ac
- **Driver**: wl (bcmwl-kernel-source)
- **Note**: Requires proprietary driver, open-source alternatives conflict

#### Bluetooth
- **Chip**: Integrated with WiFi
- **Driver**: BlueZ + btusb

### Audio
- **Chip**: Intel Sunrise Point-LP HD Audio
- **Driver**: snd_hda_intel
- **Audio Server**: PipeWire

### Camera
- **Device**: Broadcom 720p FaceTime HD Camera
- **Driver**: uvcvideo (standard UVC)

### Input
- **Keyboard**: Built-in butterfly keyboard
- **Trackpad**: Multi-touch Force Touch trackpad
- **Driver**: applespi (keyboard), libinput (trackpad)

### Power
- **Battery**: Built-in Li-Po
- **Monitoring**: `/sys/class/power_supply/BAT0`
- **Brightness**: brightnessctl

### USB
- **Controller**: Intel Sunrise Point-LP USB 3.0 xHCI
- **Ports**: USB-C (x1) with Thunderbolt 3

## Package Summary

```bash
# Essential packages for MacBook 10,1
sudo apt install \
    intel-microcode \
    bcmwl-kernel-source \
    linux-firmware \
    mesa-vulkan-drivers \
    intel-media-va-driver \
    pipewire \
    pipewire-pulse \
    brightnessctl
```

## Known Issues

1. **WiFi requires proprietary driver** - The open-source brcm80211/b43 drivers don't work well with BCM4350
2. **Suspend/resume WiFi** - May need to reload wl module after suspend
3. **Keyboard backlight** - Limited support, may not work on all models
