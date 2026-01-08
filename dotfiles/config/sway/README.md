# Sway Configuration

**Sway** is a tiling Wayland compositor and a drop-in replacement for the i3 window manager.

## Files

- `config` - Main Sway configuration file
- `status.sh` - Custom status bar script (btop-style colors)

## Key Features

### Theme
- **Safety yellow** focused window borders (#FFE600)
- Dark status bar with JetBrains Mono font
- Ubuntu Bold font for title bars

### Keybindings
- `Mod4` (Super/Windows key) as modifier
- `Mod+Return` - Open foot terminal
- `Mod+d` - Wofi application launcher
- `Mod+Shift+s` - bdmenu_ada custom launcher
- `Mod+hjkl` - Vim-style navigation
- `F1/F2` - Brightness control
- `XF86Audio*` - Volume control (PipeWire)

### Status Bar
Custom script showing:
- Volume level (cyan)
- Brightness (orange)
- WiFi SSID (green)
- Battery % + voltage (yellow)
- Disk space (magenta)
- Memory usage (light blue)
- CPU load (red)
- Date/time (white)

## Installation

```bash
cp config ~/.config/sway/config
cp status.sh ~/.config/sway/status.sh
chmod +x ~/.config/sway/status.sh
```

## Dependencies

- sway, swaybg, swaylock, swayidle
- foot (terminal)
- wofi, bemenu (launchers)
- wpctl (PipeWire volume)
- brightnessctl
- iwgetid (WiFi)
