# Keybindings Reference

## Sway Window Manager

**Modifier Key**: `Mod4` (Super/Windows key)

### Application Launch

| Key | Action |
|-----|--------|
| `Mod+Return` | Open foot terminal |
| `Mod+d` | Wofi application launcher |
| `Mod+Shift+s` | bdmenu_ada (custom categorized launcher) |

### Window Management

| Key | Action |
|-----|--------|
| `Mod+Shift+q` | Kill focused window |
| `Mod+h/j/k/l` | Focus left/down/up/right (vim-style) |
| `Mod+Arrow` | Focus direction (arrow keys) |
| `Mod+Shift+h/j/k/l` | Move window left/down/up/right |
| `Mod+Shift+Arrow` | Move window (arrow keys) |
| `Mod+f` | Toggle fullscreen |
| `Mod+Shift+Space` | Toggle floating |
| `Mod+Space` | Toggle focus between tiling/floating |
| `Mod+a` | Focus parent container |

### Layout

| Key | Action |
|-----|--------|
| `Mod+b` | Split horizontal |
| `Mod+v` | Split vertical |
| `Mod+s` | Stacking layout |
| `Mod+w` | Tabbed layout |
| `Mod+e` | Toggle split layout |

### Workspaces

| Key | Action |
|-----|--------|
| `Mod+1-0` | Switch to workspace 1-10 |
| `Mod+Shift+1-0` | Move container to workspace 1-10 |

### Scratchpad

| Key | Action |
|-----|--------|
| `Mod+Shift+minus` | Move to scratchpad |
| `Mod+minus` | Show/cycle scratchpad |

### Resize Mode

| Key | Action |
|-----|--------|
| `Mod+r` | Enter resize mode |
| `h/Left` | Shrink width |
| `l/Right` | Grow width |
| `k/Up` | Shrink height |
| `j/Down` | Grow height |
| `Return/Escape` | Exit resize mode |

### System

| Key | Action |
|-----|--------|
| `Mod+Shift+c` | Reload Sway config |
| `Mod+Shift+e` | Exit Sway (with confirmation) |

### Media Keys

| Key | Action | Platform |
|-----|--------|----------|
| `XF86AudioMute` | Toggle mute | All |
| `XF86AudioLowerVolume` | Volume down 5% | All |
| `XF86AudioRaiseVolume` | Volume up 5% | All |
| `XF86AudioMicMute` | Toggle mic mute | All |
| `F1` | Brightness down 5% | MacBook |
| `F2` | Brightness up 5% | MacBook |
| `XF86MonBrightnessDown` | Brightness down 5% | ThinkPad/Generic |
| `XF86MonBrightnessUp` | Brightness up 5% | ThinkPad/Generic |
| `F5` | Kbd backlight down | MacBook |
| `F6` | Kbd backlight up | MacBook |
| `XF86KbdBrightnessDown` | Kbd backlight down | ThinkPad |
| `XF86KbdBrightnessUp` | Kbd backlight up | ThinkPad |

### Input Devices (ThinkPad)

| Device | Feature | Setting |
|--------|---------|---------|
| TrackPoint | Middle-button scroll | Hold middle button + move TrackPoint |
| Touchpad | Tap to click | Single tap = left click |
| Touchpad | Natural scroll | Two-finger scroll, content follows fingers |
| Touchpad | Disable while typing | dwt enabled |

---

## Doom Emacs

**Leader Key**: `SPC` (Space)

### General

| Key | Action |
|-----|--------|
| `SPC` | Leader key (opens command palette) |
| `SPC :` | Execute command (M-x) |
| `SPC q q` | Quit Emacs |
| `SPC h` | Help menu |

### Files

| Key | Action |
|-----|--------|
| `SPC f f` | Find file |
| `SPC f r` | Recent files |
| `SPC f s` | Save file |
| `SPC f S` | Save all files |

### Buffers

| Key | Action |
|-----|--------|
| `SPC b b` | Switch buffer |
| `SPC b k` | Kill buffer |
| `SPC b n` | Next buffer |
| `SPC b p` | Previous buffer |

### Windows

| Key | Action |
|-----|--------|
| `SPC w v` | Split vertical |
| `SPC w s` | Split horizontal |
| `SPC w d` | Delete window |
| `SPC w h/j/k/l` | Navigate windows |

### Projects

| Key | Action |
|-----|--------|
| `SPC p p` | Switch project |
| `SPC p f` | Find file in project |
| `SPC p s` | Search in project |

### Search

| Key | Action |
|-----|--------|
| `SPC s s` | Search buffer |
| `SPC s p` | Search project |
| `SPC s d` | Search directory |

### Git (Magit)

| Key | Action |
|-----|--------|
| `SPC g g` | Magit status |
| `SPC g b` | Git blame |
| `SPC g l` | Git log |

### Org Mode

| Key | Action |
|-----|--------|
| `SPC m` | Org mode menu |
| `SPC m p` | Start Pomodoro |
| `SPC n a` | Org agenda |
| `SPC n c` | Org capture |

### Treemacs

| Key | Action |
|-----|--------|
| `SPC o p` | Toggle Treemacs |
| `SPC o P` | Treemacs find file |

### Email (mu4e)

| Key | Action |
|-----|--------|
| `SPC o e` | Open email |

### Misc

| Key | Action |
|-----|--------|
| `SPC t z` | Toggle zen mode (writeroom) |
| `SPC t l` | Toggle line numbers |
| `SPC t t` | Toggle theme |
