# Doom Emacs Configuration

**Doom Emacs** is a configuration framework for GNU Emacs, designed for speed and productivity.

## Files

- `init.el` - Module configuration (what features to enable)
- `config.el` - Personal configuration and customization
- `packages.el` - Additional packages to install
- `doom-cheatsheet.org` - Quick reference for keybindings

## Features Configured

### Theme & Appearance
- **doom-one** theme (dark)
- Line numbers enabled
- Active window highlighting with blue mode-line border
- Auto-dim inactive buffers

### Email (mu4e)
- Gmail integration with mbsync
- Configured for hamper100@gmail.com
- Auto-check every 5 minutes

### Pomodoro Timer
- 25 min work / 5 min break / 15 min long break
- `SPC m p` to start pomodoro

### PDF Tools
- Fit-width display
- Auto-activate annotations
- Smooth scrolling

### Git (Magit)
- Auto-save buffers
- Same-window display
- 72 char commit message limit

### Treemacs
- 30px width sidebar
- Project follow mode
- File watch enabled

### Zen Mode (writeroom)
- 100 char width
- Mode-line visible

## Installation

```bash
# Install Doom Emacs first
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs

# Copy config files
cp init.el config.el packages.el ~/.config/doom/

# Install and sync
~/.config/emacs/bin/doom install
~/.config/emacs/bin/doom sync
```

## Key Commands

- `SPC f f` - Find file
- `SPC b b` - Switch buffer
- `SPC p p` - Switch project
- `SPC g g` - Magit status
- `SPC o e` - Email (mu4e)
- `SPC t z` - Zen mode
