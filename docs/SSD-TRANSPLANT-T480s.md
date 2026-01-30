# SSD Transplant: Ubuntu SSD into ThinkPad T480s

## What You Need
- ThinkPad T480s
- M.2 2280 SSD from another Ubuntu machine
- Phillips #0 screwdriver

## Step 1: BIOS Configuration (Before SSD Install)

Power on the T480s, press **F1** to enter BIOS Setup.

1. **Security > Secure Boot** -- set to **Disabled**
2. **Config > Thunderbolt 3** -- set Security to **User Authorization**
3. **Config > Thunderbolt 3** -- set BIOS Assist to **Disabled**
4. **Config > Keyboard/Mouse** -- set Fn and Ctrl swap to your preference
5. **Config > Keyboard/Mouse** -- set F1-F12 as Primary to **Enabled** (FnLock)
6. **Config > Power** -- Intel SpeedStep **Enabled**, Speed Shift **Enabled**
7. **Startup > Boot** -- UEFI Only, USB Boot **Enabled**
8. **F10** to save and exit

## Step 2: Physical SSD Installation

1. Power off completely, disconnect charger
2. Flip laptop over, remove 5x Phillips screws from bottom cover
3. Pry off bottom cover starting from rear edge (use spudger if needed)
4. Locate M.2 slot (near center of board)
5. Remove existing SSD if present (unscrew, pull out at angle)
6. Insert your SSD at ~30 degree angle into M.2 slot
7. Press down flat, secure with the screw
8. Replace bottom cover and all screws

## Step 3: First Boot

Power on. The existing Ubuntu should boot. You may see:
- Different screen resolution (will normalize after driver setup)
- WiFi should work immediately (Intel 8265 uses iwlwifi, included in kernel)

**If Ubuntu does not boot:**
1. Press **F12** during boot for one-time boot menu
2. Select your SSD from the list
3. If GRUB appears but fails, boot into recovery mode and run:
   ```bash
   sudo update-grub
   sudo update-initramfs -u
   ```

## Step 4: Connect to WiFi

Intel WiFi 8265 works out of the box:
```bash
# Check adapter is recognized
lspci -k | grep -A3 "Network"
# Should show: Intel Corporation Wireless 8265

# Connect via NetworkManager
nmcli device wifi list
nmcli device wifi connect "YOUR_SSID" --ask
```

## Step 5: Run adam_laptop Installer

```bash
cd ~/ŻYCIE/VIBECODING/adam_laptop
git pull  # get T480s support

./install.sh
# Select: 1) Full install
```

The installer will:
- Auto-detect ThinkPad hardware
- Install T480s drivers (Intel microcode, TLP, thermald, bolt, fprintd)
- Restore sway config with ThinkPad keybindings
- Set up TrackPoint middle-button scrolling
- Enable touchpad tap-to-click
- Configure battery charge thresholds (75%-80%)

## Step 6: Reboot

```bash
sudo reboot
```

Start Sway from TTY:
```bash
sway
```

## Step 7: Post-Install Verification

```bash
# ThinkPad power management
sudo tlp-stat -b

# Battery thresholds
cat /sys/class/power_supply/BAT0/charge_start_threshold
cat /sys/class/power_supply/BAT0/charge_stop_threshold

# Thermal management
systemctl status thermald

# Thunderbolt devices
boltctl list

# Keyboard backlight
brightnessctl -d tpacpi::kbd_backlight info

# Fingerprint (if reader present)
fprintd-enroll
```

## Troubleshooting

### WiFi not working
```bash
dmesg | grep iwlwifi
sudo modprobe iwlwifi
# If firmware missing:
sudo apt install linux-firmware
```

### Screen brightness keys not responding
```bash
# Install wev to check key events
sudo apt install wev
wev
# Press brightness keys - look for XF86MonBrightnessUp/Down
# If keys send wrong codes, check FnLock setting in BIOS (F1)
```

### TrackPoint scroll not working
```bash
# Check sway sees the TrackPoint
swaymsg -t get_inputs | grep -i track
# Reload sway config
# Press Mod+Shift+c
```

### No fingerprint reader detected
```bash
lsusb | grep -i finger
# If empty, the reader model may not be supported by fprintd
```

### Old laptop drivers conflicting
```bash
# Remove Broadcom WiFi driver if it was installed
sudo apt remove bcmwl-kernel-source
sudo update-initramfs -u
sudo reboot
```
