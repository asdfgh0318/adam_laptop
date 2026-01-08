# Changelog

All notable changes to this setup will be documented in this file.

## [Unreleased]

### Added
- Initial repository structure
- Sway configuration with safety yellow theme
- Custom status bar script (btop-style colors)
- Doom Emacs configuration (email, pomodoro, PDF, magit)
- Claude Code session logging hook
- MacBook 10,1 driver support (Broadcom WiFi)
- Modular installation scripts
- update.sh with bidirectional sync

### Changed
- (none yet)

### Fixed
- (none yet)

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
