# adam_laptop

Complete backup and replication system for **MacBook 10,1** running **Ubuntu 24.04** with **Sway** window manager.

This is a **living backup system** - configs can be updated and synced as the setup evolves.

## Quick Start

### Same Hardware (MacBook 10,1)

```bash
git clone https://github.com/asdfgh0318/adam_laptop ~/ŻYCIE/VIBECODING/adam_laptop
cd ~/ŻYCIE/VIBECODING/adam_laptop
chmod +x install.sh update.sh scripts/*.sh
./install.sh
# Select option 1 for full install
```

### Different Hardware

```bash
git clone https://github.com/asdfgh0318/adam_laptop ~/ŻYCIE/VIBECODING/adam_laptop
cd ~/ŻYCIE/VIBECODING/adam_laptop
chmod +x install.sh update.sh scripts/*.sh
./install.sh
# Select option 5 (Custom), skip MacBook drivers
```

## What's Included

### Desktop Environment
- **Sway 1.9** - Tiling Wayland compositor (i3-compatible)
- **Waybar** - Status bar
- **Wofi / Bemenu** - Application launchers
- **Foot** - Fast Wayland terminal
- **Safety yellow** window theme

### Custom Tools (VIBECODING)
- `bdmenu_ada` - Categorized bemenu app launcher
- `settings-tools` - TUI settings suite (settings, settings-hub)
- `symulator_fpv` - FPV drone simulator
- `zegarek_google` - Doom Emacs setup scripts

### Doom Emacs
Full configuration with:
- mu4e email client (Gmail)
- Org mode + Pomodoro timer
- PDF tools
- Magit (Git integration)
- Treemacs sidebar
- Zen mode (writeroom)

### Claude Code
- Session logging hook
- Pre-approved global permissions

## Update Workflow

This setup is designed to evolve. Use `update.sh` to keep it current:

```bash
# After making changes to configs:
./update.sh
# Choose 3) Full update - backs up configs, commits, and pushes

# On another machine (or after fresh install):
./update.sh
# Choose 5) Pull updates - gets latest from remote
./install.sh
# Choose 4) Dotfiles only - applies configs
```

## File Structure

```
adam_laptop/
├── install.sh              # Master installer
├── update.sh               # Sync/update tool
├── session-logger.sh       # Claude Code hook script
│
├── scripts/
│   ├── common.sh           # Shared functions
│   ├── 00-base.sh          # Base packages
│   ├── 01-sway.sh          # Sway + Wayland
│   ├── 02-drivers-macbook.sh  # MacBook drivers
│   ├── 03-drivers-generic.sh  # Generic drivers
│   ├── 04-tools.sh         # VIBECODING tools
│   ├── 05-doom-emacs.sh    # Doom Emacs
│   ├── 06-claude-code.sh   # Claude Code config
│   ├── restore-dotfiles.sh # Apply configs
│   └── backup-dotfiles.sh  # Capture configs
│
├── dotfiles/
│   ├── config/sway/        # Sway config + status bar
│   ├── config/doom/        # Doom Emacs config
│   ├── config/gtk-3.0/     # GTK settings
│   ├── claude/             # Claude Code settings
│   └── etc/modprobe.d/     # Driver configs
│
└── docs/
    ├── HARDWARE.md         # MacBook specs
    ├── WIFI_TROUBLESHOOTING.md
    └── KEYBINDINGS.md
```

## Hardware Support

### MacBook 10,1 (2017)
- Intel 7th Gen Core i5/i7
- Intel HD Graphics 615 (i915 driver)
- Broadcom BCM4350 WiFi (wl driver)
- Intel Sunrise Point-LP Audio (PipeWire)
- Apple NVMe SSD

### Generic Hardware
- Intel/AMD/NVIDIA graphics (with appropriate drivers)
- Most WiFi chipsets via NetworkManager
- Standard audio via PipeWire

## Sway Keybindings

| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminal (foot) |
| `Mod+d` | Wofi launcher |
| `Mod+Shift+s` | bdmenu_ada launcher |
| `Mod+Shift+q` | Kill window |
| `Mod+hjkl` | Navigate windows (vim-style) |
| `Mod+1-0` | Switch workspace |
| `Mod+Shift+c` | Reload config |
| `Mod+Shift+e` | Exit Sway |
| `F1/F2` | Brightness down/up |
| `XF86Audio*` | Volume controls |

## Contributing

This is a personal backup system, but the structure can be adapted for your own setup. Feel free to fork and customize.

## License

MIT
