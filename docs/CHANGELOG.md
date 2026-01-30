# Changelog

All notable changes to this setup will be documented in this file.

## [Unreleased]

### Added
- ThinkPad T480s hardware support (`scripts/02-drivers-t480s.sh`)
- ThinkPad detection functions in `scripts/common.sh` (is_thinkpad, is_thinkpad_t480s, has_intel_wifi, has_fingerprint_reader)
- Three-way hardware routing in `install.sh` (MacBook / ThinkPad / Generic)
- XF86MonBrightness and XF86KbdBrightness keybindings in sway config
- TrackPoint middle-button scrolling configuration
- Touchpad tap-to-click and natural scroll configuration
- ThinkPad T480s hardware documentation (`docs/HARDWARE-T480s.md`)
- SSD transplant guide (`docs/SSD-TRANSPLANT-T480s.md`)

### Changed
- `install.sh` header now says "Multi-Hardware" instead of "MacBook 10,1"
- Broadcom modprobe config in restore/backup scripts now conditional on MacBook
- Battery detection in status.sh now auto-detects BAT path
- Hardware info display now shows ThinkPad model name

---

## [1.0.0] - 2025-01-08

### Added
- Complete backup and replication system for MacBook 10,1
- **install.sh** - Master installer with options:
  - Full install (all components)
  - Desktop only (no Doom/Claude)
  - Minimal (base + Sway)
  - Dotfiles only
  - Custom selection
- **update.sh** - Living backup system:
  - Backup dotfiles to repo
  - Sync tool submodules
  - Full update (backup + commit + push)
  - Pull updates from remote
  - Apply configs to system
- **Scripts**:
  - `00-base.sh` - Core packages
  - `01-sway.sh` - Sway + Wayland stack
  - `02-drivers-macbook.sh` - MacBook-specific drivers
  - `03-drivers-generic.sh` - Generic hardware
  - `04-tools.sh` - VIBECODING tools
  - `05-doom-emacs.sh` - Full Doom setup
  - `06-claude-code.sh` - Claude Code configuration
  - `restore-dotfiles.sh` - Apply configs
  - `backup-dotfiles.sh` - Capture configs
- **Dotfiles**:
  - Sway config (safety yellow, foot, wofi)
  - Status bar script with system metrics
  - Doom Emacs (email, pomodoro, PDF, magit)
  - Claude Code hooks + permissions
  - GTK settings
  - Broadcom WiFi blacklist
- **Documentation**:
  - HARDWARE.md - MacBook 10,1 specs
  - WIFI_TROUBLESHOOTING.md - Broadcom driver guide
  - KEYBINDINGS.md - Sway + Doom shortcuts
  - README files in each dotfiles directory

### Hardware Support
- MacBook 10,1 (Intel 7th Gen, HD Graphics 615, Broadcom BCM4350)
- Generic Intel/AMD/NVIDIA systems

### Tools Integrated
- bdmenu_ada (app launcher)
- settings-tools (TUI settings)
- session-logger.sh (Claude Code hook)
