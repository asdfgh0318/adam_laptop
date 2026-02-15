<p align="center">
  <img src="banner.svg" alt="adam_laptop banner" width="100%">
</p>

# adam_laptop

Complete backup and replication system for **MacBook 10,1** running **Ubuntu 24.04** with **Sway** window manager.

This is a **living backup system** that automatically syncs daily to keep your cloud backup current as the setup evolves.

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Installation Options](#installation-options)
- [Update System](#update-system)
- [Auto-Update (Daily Sync)](#auto-update-daily-sync)
- [Desktop Environment](#desktop-environment)
- [Custom Tools](#custom-tools)
- [Doom Emacs](#doom-emacs)
- [Claude Code Integration](#claude-code-integration)
- [Hardware Support](#hardware-support)
- [File Structure](#file-structure)
- [Keybindings](#keybindings)
- [Troubleshooting](#troubleshooting)

---

## Features

### Core Features
- **One-command installation** - Full system setup with `./install.sh`
- **Living backup** - Configs sync bidirectionally with `./update.sh`
- **Daily auto-sync** - Cron job pushes changes to GitHub every day at 8 PM
- **Hardware detection** - Automatically detects MacBook vs generic hardware
- **Modular scripts** - Install only what you need

### What's Backed Up
- Sway window manager configuration (safety yellow theme)
- Custom status bar with system metrics
- Doom Emacs configuration (email, pomodoro, git, PDF)
- Claude Code hooks and session logging
- GTK theme settings
- WiFi driver configuration (Broadcom)
- Full package list snapshot

### Custom Tools Included
- `bdmenu_ada` - Categorized application launcher
- `settings-tools` - TUI settings suite
- `session-logger.sh` - Claude Code session tracking

---

## Quick Start

### Fresh Install (Same MacBook Hardware)

```bash
# Clone the repository
git clone https://github.com/asdfgh0318/adam_laptop ~/ŻYCIE/VIBECODING/adam_laptop
cd ~/ŻYCIE/VIBECODING/adam_laptop

# Make scripts executable
chmod +x install.sh update.sh scripts/*.sh

# Run full installation
./install.sh
# Select: 1) Full install
```

### Fresh Install (Different Hardware)

```bash
git clone https://github.com/asdfgh0318/adam_laptop ~/ŻYCIE/VIBECODING/adam_laptop
cd ~/ŻYCIE/VIBECODING/adam_laptop
chmod +x install.sh update.sh scripts/*.sh

./install.sh
# Select: 5) Custom
# Say "n" to MacBook drivers question
```

### Restore Configs Only (Sway Already Installed)

```bash
git clone https://github.com/asdfgh0318/adam_laptop ~/ŻYCIE/VIBECODING/adam_laptop
cd ~/ŻYCIE/VIBECODING/adam_laptop
chmod +x install.sh update.sh scripts/*.sh

./install.sh
# Select: 4) Dotfiles only
```

---

## Installation Options

Run `./install.sh` and choose:

| Option | Description | Installs |
|--------|-------------|----------|
| **1) Full install** | Everything | Base + Sway + Drivers + Tools + Doom + Claude |
| **2) Desktop only** | No Doom/Claude | Base + Sway + Drivers + Tools |
| **3) Minimal** | Just the essentials | Base + Sway |
| **4) Dotfiles only** | Config restore | Copies config files to home |
| **5) Custom** | Pick components | Interactive selection |

### Individual Scripts

You can also run scripts directly:

```bash
# Base packages (git, curl, btop, ripgrep, etc.)
./scripts/00-base.sh

# Sway + Wayland stack
./scripts/01-sway.sh

# MacBook drivers (Broadcom WiFi, Intel graphics)
./scripts/02-drivers-macbook.sh

# Generic drivers (Intel/AMD/NVIDIA)
./scripts/03-drivers-generic.sh

# VIBECODING custom tools
./scripts/04-tools.sh

# Doom Emacs (full installation)
./scripts/05-doom-emacs.sh

# Claude Code configuration
./scripts/06-claude-code.sh

# Restore dotfiles to home directory
./scripts/restore-dotfiles.sh

# Backup current configs to repo
./scripts/backup-dotfiles.sh
```

---

## Update System

The `./update.sh` script is the core of the living backup system.

### Options

```bash
./update.sh
```

| Option | Description | Use Case |
|--------|-------------|----------|
| **1) Backup dotfiles** | Copy configs to repo | Capture current state |
| **2) Sync tools** | Update git submodules | Get latest tool versions |
| **3) Full update** | Backup + commit + push | Save changes to GitHub |
| **4) Show diff** | Preview changes | See what changed |
| **5) Pull updates** | Get from remote | Sync from another machine |
| **6) Apply configs** | Restore dotfiles | Apply pulled changes |

### Workflow Examples

**After modifying your Sway config:**
```bash
cd ~/ŻYCIE/VIBECODING/adam_laptop
./update.sh   # Choose 3) Full update
```

**On a different machine:**
```bash
cd ~/ŻYCIE/VIBECODING/adam_laptop
./update.sh   # Choose 5) Pull updates
./update.sh   # Choose 6) Apply configs
```

**Quick one-liner for full update:**
```bash
cd ~/ŻYCIE/VIBECODING/adam_laptop && ./update.sh <<< "3"
```

---

## Auto-Update (Daily Sync)

A cron job runs daily at **8 PM** to automatically backup and push changes.

### How It Works

1. `scripts/auto-update.sh` runs via cron
2. Backs up all dotfiles to the repo
3. If changes detected, commits with timestamp
4. Pushes to GitHub
5. Logs activity to `auto-update.log`

### Crontab Entry

```
0 20 * * * /home/adam-koszalka/ŻYCIE/VIBECODING/adam_laptop/scripts/auto-update.sh
```

### Check Logs

```bash
cat ~/ŻYCIE/VIBECODING/adam_laptop/auto-update.log
```

### Manual Run

```bash
~/ŻYCIE/VIBECODING/adam_laptop/scripts/auto-update.sh
```

### Disable Auto-Update

```bash
crontab -e
# Remove or comment out the adam_laptop line
```

---

## Desktop Environment

### Sway Window Manager

A tiling Wayland compositor, drop-in replacement for i3.

**Theme**: Safety yellow focused windows (#FFE600)

**Components installed:**
- `sway` - Window manager
- `waybar` - Status bar
- `wofi` - Application launcher (GUI)
- `bemenu` - Application launcher (CLI)
- `foot` - Terminal emulator
- `alacritty` - Alternative terminal
- `swaybg` - Wallpaper
- `swaylock` - Screen locker
- `swayidle` - Idle management
- `mako` - Notifications
- `wl-clipboard` - Clipboard
- `grim` + `slurp` - Screenshots

### Custom Status Bar

The status bar (`~/.config/sway/status.sh`) shows:

| Metric | Color | Update Rate |
|--------|-------|-------------|
| Volume | Cyan | 0.1s |
| Brightness | Orange | 0.1s |
| WiFi SSID | Green | 1s |
| Battery % | Yellow | 1s |
| Disk Space | Magenta | 1s |
| Memory | Light Blue | 1s |
| CPU Load | Red | 1s |
| Date/Time | White | 0.1s |

### Audio

Uses **PipeWire** for audio:
- `pipewire` - Core audio server
- `pipewire-pulse` - PulseAudio compatibility
- `wireplumber` - Session manager
- `pavucontrol` - Volume control GUI

---

## Custom Tools

### bdmenu_ada

Categorized application launcher using bemenu.

**Features:**
- 16+ categories (System, Network, Audio, Files, etc.)
- Emoji icons for visual recognition
- Terminal app detection (opens TUI apps in terminal)
- Power controls (Logout, Restart, Shutdown)

**Usage:** `Mod+Shift+s` or run `bdmenu_ada`

### settings-tools

TUI settings suite with whiptail interface.

**Components:**
- `settings` - Quick launcher for installed apps
- `settings-hub` - App store for discovering tools
- `settings-dmenu` - dmenu-based launcher
- `settings-wofi` - Wayland launcher

**Usage:** Run `settings` or `settings-hub`

### session-logger.sh

Claude Code hook that logs sessions to WORK_LOGS.

**Logged data:**
- Timestamp
- Working directory
- Stop reason

**Log location:** `~/ŻYCIE/VIBECODING/WORK_LOGS`

---

## Doom Emacs

Full Doom Emacs configuration with productivity features.

### Installed Modules

| Module | Description |
|--------|-------------|
| **mu4e** | Email client (Gmail) |
| **org** | Notes and task management |
| **org-pomodoro** | Pomodoro timer |
| **magit** | Git integration |
| **treemacs** | File sidebar |
| **pdf-tools** | PDF viewer |
| **writeroom** | Distraction-free writing |

### Email Setup (mu4e)

Pre-configured for Gmail. To activate:

1. Create app password at https://myaccount.google.com/apppasswords
2. Save to `~/.gmail-password`
3. Configure `~/.mbsyncrc` with your email
4. Run: `mbsync -a && mu init --maildir=~/Mail --my-address=YOUR_EMAIL`

### Key Commands

| Key | Action |
|-----|--------|
| `SPC f f` | Find file |
| `SPC b b` | Switch buffer |
| `SPC p p` | Switch project |
| `SPC g g` | Magit (git) |
| `SPC o e` | Email |
| `SPC m p` | Start pomodoro |
| `SPC t z` | Zen mode |

---

## Claude Code Integration

### Session Logging

Every Claude Code session is logged when it ends.

**Hook configuration** (`~/.claude/settings.local.json`):
```json
{
  "hooks": {
    "Stop": [{
      "matcher": {},
      "hooks": [{
        "type": "command",
        "command": "/home/adam-koszalka/ŻYCIE/VIBECODING/session-logger.sh",
        "timeout": 5
      }]
    }]
  }
}
```

**Log format** (`WORK_LOGS`):
```
## 2025-01-08
### Sessions
- **14:30** | `adam_laptop` | end_turn
- **16:45** | `symulator_fpv` | end_turn
```

### Pre-Approved Permissions

Common commands are pre-approved for convenience:
- System info: `lspci`, `lsusb`, `journalctl`
- Package management: `apt install`, etc.
- Audio/display: `wpctl`, `brightnessctl`
- File operations: `mkdir`, `cp`, `chmod`

---

## Hardware Support

### MacBook 10,1 (Primary Target)

| Component | Hardware | Driver |
|-----------|----------|--------|
| CPU | Intel 7th Gen | intel-microcode |
| GPU | Intel HD 615 | i915 (kernel) |
| WiFi | Broadcom BCM4350 | wl (bcmwl-kernel-source) |
| Audio | Intel Sunrise Point | PipeWire |
| Storage | Apple NVMe | nvme (kernel) |

### Generic Hardware

The `03-drivers-generic.sh` script handles:
- Intel graphics (mesa)
- AMD graphics (mesa + amdgpu)
- NVIDIA (suggests proprietary driver)
- Common WiFi (NetworkManager)

---

## File Structure

```
adam_laptop/
├── install.sh                 # Master installer
├── update.sh                  # Sync/backup tool
├── session-logger.sh          # Claude Code hook
├── package-list.txt           # Full dpkg snapshot
├── key-packages.txt           # Important packages
├── auto-update.log            # Daily sync log
│
├── scripts/
│   ├── common.sh              # Shared functions
│   ├── 00-base.sh             # Core packages
│   ├── 01-sway.sh             # Sway + Wayland
│   ├── 02-drivers-macbook.sh  # MacBook drivers
│   ├── 03-drivers-generic.sh  # Generic drivers
│   ├── 04-tools.sh            # Custom tools
│   ├── 05-doom-emacs.sh       # Doom Emacs
│   ├── 06-claude-code.sh      # Claude Code
│   ├── restore-dotfiles.sh    # Apply configs
│   ├── backup-dotfiles.sh     # Capture configs
│   ├── sync-tools.sh          # Update submodules
│   └── auto-update.sh         # Daily cron script
│
├── dotfiles/
│   ├── config/
│   │   ├── sway/              # Sway config + status bar
│   │   ├── doom/              # Doom Emacs config
│   │   └── gtk-3.0/           # GTK settings
│   ├── claude/                # Claude Code settings
│   └── etc/modprobe.d/        # Driver configs
│
└── docs/
    ├── HARDWARE.md            # MacBook specs
    ├── WIFI_TROUBLESHOOTING.md
    ├── KEYBINDINGS.md
    └── CHANGELOG.md
```

---

## Keybindings

### Sway (Window Manager)

| Key | Action |
|-----|--------|
| `Mod+Return` | Open terminal |
| `Mod+d` | Wofi launcher |
| `Mod+Shift+s` | bdmenu_ada |
| `Mod+Shift+q` | Kill window |
| `Mod+h/j/k/l` | Navigate (vim-style) |
| `Mod+Shift+h/j/k/l` | Move window |
| `Mod+1-0` | Switch workspace |
| `Mod+Shift+1-0` | Move to workspace |
| `Mod+f` | Fullscreen |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+b` | Split horizontal |
| `Mod+v` | Split vertical |
| `Mod+r` | Resize mode |
| `Mod+Shift+c` | Reload config |
| `Mod+Shift+e` | Exit Sway |
| `F1/F2` | Brightness -/+ |
| `XF86Audio*` | Volume controls |

### Doom Emacs

| Key | Action |
|-----|--------|
| `SPC` | Leader key |
| `SPC f f` | Find file |
| `SPC f r` | Recent files |
| `SPC b b` | Switch buffer |
| `SPC b k` | Kill buffer |
| `SPC p p` | Switch project |
| `SPC p f` | Find in project |
| `SPC s s` | Search buffer |
| `SPC s p` | Search project |
| `SPC g g` | Magit status |
| `SPC o e` | Email (mu4e) |
| `SPC o p` | Treemacs |
| `SPC m p` | Pomodoro |
| `SPC t z` | Zen mode |
| `SPC q q` | Quit |

---

## Troubleshooting

### WiFi Not Working (MacBook)

See [docs/WIFI_TROUBLESHOOTING.md](docs/WIFI_TROUBLESHOOTING.md)

Quick fix:
```bash
sudo apt install bcmwl-kernel-source
sudo modprobe wl
```

### Sway Won't Start

Check config syntax:
```bash
sway -C
```

### Doom Emacs Issues

Rebuild packages:
```bash
~/.config/emacs/bin/doom sync
~/.config/emacs/bin/doom build
```

### Auto-Update Not Running

Check cron:
```bash
crontab -l | grep adam_laptop
```

Check logs:
```bash
cat ~/ŻYCIE/VIBECODING/adam_laptop/auto-update.log
```

---

## License

MIT

---

## Contributing

This is a personal backup system, but feel free to fork and adapt for your own setup.

**Created with the help of Claude Code (Opus 4.5)**
