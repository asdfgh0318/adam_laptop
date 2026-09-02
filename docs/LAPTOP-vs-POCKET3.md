---
title: "Precision 5520 → GPD Pocket 3"
subtitle: "What is on the daily driver, and what the stick puts on the Pocket 3"
date: 2026-09-02
geometry: margin=1.8cm
mainfont: DejaVu Sans
monofont: DejaVu Sans Mono
fontsize: 9pt
colorlinks: true
header-includes:
  - \usepackage{longtable,booktabs,array}
  - \usepackage{xcolor}
  - \definecolor{keep}{HTML}{1B7F3B}
  - \definecolor{drop}{HTML}{B22222}
  - \definecolor{hand}{HTML}{B8860B}
  - \newcommand{\Y}{\textcolor{keep}{\textbf{yes}}}
  - \newcommand{\N}{\textcolor{drop}{\textbf{no}}}
  - \newcommand{\M}{\textcolor{hand}{\textbf{by hand}}}
---

**Legend:** \Y{} = the setup script installs or restores it, unchanged.
\N{} = deliberately left off the Pocket 3. \M{} = cannot be scripted; see the manual checklist.

Everything in the *Laptop* column was read from the live Precision 5520 on 2026-09-02.
Everything in the *Pocket 3* column describes what `setup-pocket3.sh` on the Ventoy stick does.

# 0. Distro verdict for the GPD Pocket 3

**Verdict: Ubuntu 24.04 LTS, with the umpc-ubuntu quirks applied sway-native.** Not because Ubuntu has
the best Pocket 3 support in the abstract — Arch arguably does — but because on this device the support
is *the same five kernel/udev quirks on every distro*, and only one choice also makes the machine a copy
of the daily driver.

| Distro | Pocket 3 support | Drawbacks | Copy fit |
|:------------------|:------------------------------------|:------------------------------------|:--------------|
| **Ubuntu 24.04** (any flavour) | `wimpysworld/umpc-ubuntu` is *the* reference tweak set; Ubuntu MATE built its official Pocket 3 image from it. Kernel 6.8 covers both CPU variants. | No official Pocket 3 image since **Ubuntu MATE 21.10** — you apply the script (or these five files) yourself. Script is Xorg-first; its README says Wayland "mileage may vary". | \Y{} identical packages, PPAs, scripts |
| Ubuntu MATE 21.10 image | Only true out-of-the-box image ever shipped. | 21.10 is EOL since 2022. Kernel 5.13: audio broken on the N6000, needs the HDA override on the 1195G7. | \N{} dead release |
| Arch | Best-written wiki page for this device; rolling kernel gets fixes first (N6000 audio landed in 6.1). | You maintain it. Not what the 5520 runs. ArchWiki was unreachable for this research (Anubis bot-wall) — its claims here are from search snippets, not read at source. | \N{} package drift |
| Fedora | Tested alongside Ubuntu 21.10 by Liliputing (2022): wifi, touch, pen, rotation fine; audio needed the same driver-config workaround; webcam choppy. | Same quirks, different package names — nothing from `manifests/` transfers. | \N{} |
| NixOS | `nixos-hardware` has GPD Pocket profiles (Pocket 1/2; Pocket 3 via community). | Entire config model differs from the 5520. | \N{} |
| Kali (defencore repo) | Working rotation/touch/TLP configs for 2021.4. | Its own ToDo lists sound, stylus, multi-touch and sleep as unsolved. | \N{} |

**Why sway makes Ubuntu the easy case.** The only place the distros genuinely differ is how much
display-server glue they need. Under Xorg the portrait panel needs a monitor section, a touch
transformation matrix, an accelerometer daemon and a display-scaler script. Under sway it is
`output DSI-1 transform 90 scale 1.5` plus `map_to_output` for touch — the Wayland caveat in
umpc-ubuntu's README is about their Xorg tooling, not about the hardware.

**What no distro fixes (as of this research, 2026-09-02):**

- **Audio depends on which Pocket 3 you have.** i7-1195G7: SOF has no topology, needs `dsp_driver=1`.
  N6000: SOF works from kernel 6.1 — with reports of popping and volume resetting on reboot.
- **Webcam** is reported choppy; video recording failed in the Liliputing test. Not re-verified since.
- **Fan** runs on BIOS curves; no userspace control exists.
- **Suspend** is `s2idle` only. Deep sleep is not available; expect drain while "asleep".
- **The installer runs rotated 90°.** Every distro. It is only the live session.
- **Fingerprint reader**: no report of it working on Linux was found.

Evidence quality: web pages and upstream config files, read on 2026-09-02, except ArchWiki (blocked).
The Liliputing test is from 2022 on 21.10/Fedora 35; nothing more recent with the same rigour turned up.

# 1. Hardware

| | Precision 5520 (laptop) | GPD Pocket 3 |
|:-------------|:-------------------------------------|:-----------------------------------------------|
| CPU | Intel i5-8350U, 4c/8t | i7-1195G7 (Tiger Lake) **or** Pentium N6000 (Jasper Lake) — the script detects which |
| RAM | 23 GiB | 16 GB (soldered) |
| Storage | 954 GB NVMe: 192 G `/` + 736 G `/data` | your unit's M.2 |
| Display | eDP-1, landscape | **8" 1200×1920, physically portrait, mounted sideways** |
| Effective desktop | native | 1920×1200 rotated, scaled ×1.5 → **1280×800** |
| Touch / stylus | none | Goodix GXTP7380 touch + pen — needs a rotation matrix |
| Suspend | works | `s2idle` only; deep sleep unavailable |
| Webcam | works | reported choppy on Linux; capture may fail |
| Fan control | BIOS | BIOS only; no userspace control |

# 2. OS and desktop

| | Laptop | Pocket 3 | |
|:---------------|:---------------------------------|:---------------------------------------|:---------|
| Distribution | Ubuntu 24.04.4 LTS (noble) | Ubuntu 24.04.4 LTS — same point release, same ISO era | \Y |
| Kernel | 6.8.0-50-generic | 6.8 generic (stock). Liquorix headers **not** carried over | \N |
| Session | sway 1.9 on Wayland | sway 1.9 on Wayland | \Y |
| Status bar | custom `status.sh` (volume / brightness / wifi / battery / disk / mem / cpu / clock) | identical file | \Y |
| Theme | safety-yellow `#FFE600` focus, `#B8A500` inactive, `#666600` unfocused | identical | \Y |
| Title font | Ubuntu Bold 8 · bar: JetBrains Mono 8 | identical (fonts in the apt list) | \Y |
| Wallpaper | photo PXL\_20220525\_111527965 .MP.jpg (6.5 MB) | same image, path rewritten to `~/.local/share/backgrounds/wallpaper.jpg` | \Y |
| Terminal | foot — black bg, white fg, alpha 0.92 | identical `foot.ini` | \Y |
| Launchers | wofi (`Mod+d`), bemenu `bdmenu_ada` (`Mod+Shift+s`) | identical | \Y |
| Notifications | mako (systemd user unit) | mako installed; unit enabled on first sway start | \Y |
| Audio | PipeWire + wireplumber | PipeWire + wireplumber, **plus** the variant-specific HDA override | \Y |
| Login shell | bash | bash | \Y |
| Display config | none needed | `output DSI-1 transform 90 scale 1.5` + touch/pen `map_to_output` | new |

# 3. Software — the numbers

| Layer | Laptop | Pocket 3 | Left out |
|:-----------------------|---------:|---------:|:---------------------------------------|
| apt, manually installed | **427** | **412** | 15 (listed in §4) |
| snap apps (bases excluded) | **20** | **16** | anbox, whatsapp-4linux, whatsie, prusa-slicer-snap |
| flatpak apps | **4** | **4** | — |
| pip user packages | 34 | 32 | 2 build artefacts |
| third-party apt sources | 17 files (10 live, 7 `.distUpgrade` leftovers) | the 10 live ones | jammy/focal PPAs are tried and dropped if they 404 on noble |
| signing keyrings | 6 | 6 | — |

# 4. What is *not* going on the Pocket 3

**apt (15):** `grub-pc` `grub-pc-bin` `os-prober` `memtest86+` — BIOS-boot leftovers the Pocket 3 (UEFI) has no use for ·
`linux-headers-6.8.0-50-generic` `linux-headers-liquorix-amd64` — kernel-pinned ·
`steam-launcher` `steam-libs-amd64` `steam-libs-i386` ·
`virtualbox-7.0` `qemu-system-x86` `qemu-utils` `virt-manager` `swtpm` `ovmf`

**snap (4):** `anbox` · `whatsapp-4linux` · `whatsie` (ferdium stays, so you keep one WhatsApp) · `prusa-slicer` snap 2.7.4 (the flatpak 2.9.4 stays)

Everything else — FreeCAD, KiCad, PrusaSlicer, BambuStudio, Betaflight, INAV, ExpressLRS, Arduino, esptool, gpredict, gqrx, noaa-apt, LibreOffice, Thunderbird, Brave, Chromium, Firefox, Chrome, VS Code, Zotero, Spotify, Discord, Teams, Ferdium, Audacity, LMMS, VLC, Wireshark, nmap, TeamViewer, RustDesk, Remmina, Syncthing, Docker, wine-staging, Lutris, TeX Live, pandoc, Doom Emacs, neovim, micro, ranger, btop, tmux, fzf, ripgrep — goes.

# 5. Config and dotfiles — file by file

| File | Laptop | Pocket 3 | |
|:------------------------------------|:------------------------|:---------------------------|:--------|
| `~/.config/sway/config` | 301 lines | same + 20-line Pocket 3 block appended | \Y |
| `~/.config/sway/status.sh` | 63 lines | identical | \Y |
| `~/.config/foot/foot.ini` | colours + alpha | identical | \Y |
| `~/.config/gtk-3.0/settings.ini` | present | identical | \Y |
| `~/.config/doom/{config,init,packages}.el` + cheatsheet | present | identical; `doom sync` rebuilds the 423 MB of packages | \Y |
| `~/.bashrc` additions | PATH, `EDITOR=emacs -nw`, emacsclient alias, nvm hook, opencode PATH, **`go()`** | appended verbatim, `/home/adam` → `$HOME` | \Y |
| `~/.gitconfig` | asdfgh0318 / gh credential helper | identical | \Y |
| `~/.claude/settings.json` + `CLAUDE.md` | present | identical | \Y |
| `~/.claude/.credentials.json` | present | **not copied** — log in again | \M |
| `~/.ssh/id_ed25519` | present | **not copied** — bring on encrypted media | \M |
| `~/.config/gh/hosts.yml` | present | **not copied** — `gh auth login` | \M |
| dconf (1292 keys) | present | not restored — GNOME-only, unused under sway | \N |
| crontab (2 jobs) | adam_laptop auto-update, vibecoding-logger | not installed; paths in adam_laptop are now fixed so you *can* | \N |

# 6. Custom tools

| Tool | Laptop | Pocket 3 | |
|:---------------------|:---------------------------------|:---------------------------------|:---------|
| `go` / `go-layout` | `~/.local/bin/go-layout` → VIBECODING/go-layout | own repo bundled; `install.sh` links it and adds `go()` | \Y |
| `bdmenu_ada` | `~/bin` symlink | bundled + linked | \Y |
| `settings`, `-hub`, `-dmenu`, `-wofi`, `printerctl` | `~/bin` symlinks → settings-tools | bundled + linked | \Y |
| `archangel` | `~/bin` symlink → ŻYCIE/archangel | bundled + linked | \Y |
| `fcmcp` | → VIBECODING/fcmcp (FreeCAD MCP) | inside ŻYCIE tracked content | \Y |
| `research_tree` | → PRACA/Shroud_Comparison/… | inside ŻYCIE tracked content, not linked | partial |
| `litlib` | real file in `~/bin` | not bundled | \N |
| `~/.local/bin` (claude, codex-acp, mmdc, yt-dlp, httpx…) | 24 entries | reinstalled by their package managers where possible | partial |

# 7. Toolchains

| | Laptop | Pocket 3 | |
|:-------------|:---------------------------------|:-----------------------------------------|:---------|
| node | 22.22.1 via nvm | nvm → node 22 LTS, `default` alias | \Y |
| npm / pnpm | 10.9.4 / 10.29.1 | corepack pnpm@latest | \Y |
| python | 3.12.3 + 34 user pkgs | 3.12 (noble) + pip list | \Y |
| uv | 0.11.17 | astral installer, latest | \Y |
| java | OpenJDK 21.0.12 | from apt list | \Y |
| docker | 29.1.3 + compose v2 | from apt list, user added to `docker` group | \Y |
| emacs / doom | 29.3 | 29.3 + doom clone + sync | \Y |
| nvim | 0.9.5 | 0.9.5 | \Y |
| rust / go / cargo | not installed | not installed | — |

# 8. Data

| | Laptop | On the stick | |
|:-------------------------|---------------:|:-------------------------------------------|:---------|
| ŻYCIE, tracked in `zycie.git` | 990 MB, 800 files | **1.8 GB shallow clone** (working tree + 1-deep history) | \Y |
| ŻYCIE `.git` full history | 5.2 GB | not carried; `git fetch --unshallow` later if you want it | \N |
| ŻYCIE, untracked | ~47 GB | not carried | \M |
| ├ Papers | 1.3 GB | rsync / Syncthing | \M |
| ├ ardupilot | 1.9 GB | re-clone upstream | \M |
| ├ Applications | 1.1 GB | not needed | \N |
| ├ Pulpit | 637 MB | rsync | \M |
| ├ Zotero | 112 MB | Zotero sync | \M |
| ├ org-mode | 109 MB | rsync | \M |
| ├ Sync / HUB | 217 + 217 MB | Syncthing re-pair | \M |
| `~/snap` | 9.9 GB | regenerated by snaps | — |

# 9. What the stick holds

```
/dev/sda  30.6 GB  SanDisk Cruzer, Ventoy 1.1.17, GPT, Secure Boot capable
├── ubuntu-24.04.4-desktop-amd64.iso        ~6 GB   sha256 3a4c9877…99d1e
└── PAYLOAD/                                 1.8 GB  1084 files
    ├── setup-pocket3.sh                     12 idempotent phases
    ├── README.md · MANUAL-CHECKLIST.md · this document
    ├── manifests/    apt 412 · snaps 16 · flatpaks 4 · pip 32 · 10 sources · 6 keys
    ├── dotfiles/     sway · foot · gtk · doom · gitconfig · bashrc additions · claude
    ├── pocket3/      grub · alsa · touch udev · accel hwdb · sway output block
    ├── wallpaper/    the jpg
    ├── zycie/        tracked ŻYCIE + go-layout + bdmenu_ada + settings-tools + archangel
    └── adam_laptop/  existing repo, /home/adam-koszalka paths fixed
```

# 10. Only on the Pocket 3

These five files exist because of the hardware and have no counterpart on the laptop.
Values are from `wimpysworld/umpc-ubuntu`, the reference Ubuntu MATE's official Pocket 3 image is built from.

| File | Does | Note |
|:-----------------------------|:-------------------------------------------|:-------------------------|
| `/etc/default/grub.d/gpd-pocket3.cfg` | `fbcon=rotate:1`, `video=DSI-1:panel_orientation=right_side_up`, `mem_sleep_default=s2idle`, `GFXMODE=1200x1920x32` | boot console, plymouth, suspend |
| `~/.config/sway/config` (appended) | `output DSI-1 transform 90 scale 1.5` + touch/pen `map_to_output DSI-1` | **if upside down: 90 → 270** |
| `/etc/udev/rules.d/99-gpd-pocket3-touch.rules` | libinput matrix `0 1 0 -1 0 1` for touch + stylus | taps land where you touch |
| `/etc/udev/hwdb.d/61-gpd-pocket3-sensor-local.hwdb` | `ACCEL_MOUNT_MATRIX=-1,0,0;0,1,0;1,0,0` | auto-rotate |
| `/etc/modprobe.d/alsa-gpd-pocket3.conf` | `snd-intel-dspcfg dsp_driver=1` | **i7-1195G7 only**; N6000 must not get it |

*The `transform 90` value could not be tested without the device. It is the single most likely thing to need a one-character change.*
