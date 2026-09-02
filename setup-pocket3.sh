#!/usr/bin/env bash
# setup-pocket3.sh - turn a fresh Ubuntu 24.04 install on a GPD Pocket 3
# into a copy of the Precision 5520 daily driver.
#
# Run AFTER Ubuntu is installed and you have booted into it with network.
#   ./setup-pocket3.sh          run every phase, in order
#   ./setup-pocket3.sh 3 4 7    run only those phases
#   ./setup-pocket3.sh --list   show the phases and stop
#
# Every phase is idempotent: re-running is safe and is the intended way to
# recover from a phase that failed halfway.

set -uo pipefail
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a
# NONINTERACTIVE=1 is set by autoinstall/firstboot.sh; apt/snap get no prompts either way.
PAYLOAD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$HOME/setup-pocket3.log"
FAILED=()

c_step=$'\e[1;33m'; c_ok=$'\e[1;32m'; c_err=$'\e[1;31m'; c_dim=$'\e[2m'; c_off=$'\e[0m'
step() { printf '\n%s==> %s%s\n' "$c_step" "$*" "$c_off" | tee -a "$LOG"; }
ok()   { printf '%s  ok%s %s\n' "$c_ok" "$c_off" "$*" | tee -a "$LOG"; }
warn() { printf '%s  !!%s %s\n' "$c_err" "$c_off" "$*" | tee -a "$LOG"; }
note() { printf '%s     %s%s\n' "$c_dim" "$*" "$c_off" | tee -a "$LOG"; }

[ "$(id -u)" -eq 0 ] && { echo "Run as your normal user, not root. It sudos when it needs to."; exit 1; }

# --------------------------------------------------------------------------
# preflight
# --------------------------------------------------------------------------
phase_0_preflight() {
    step "Phase 0 - preflight"
    . /etc/os-release
    [ "${VERSION_ID:-}" = "24.04" ] || warn "This is Ubuntu ${VERSION_ID:-?}, the payload was built for 24.04. Package names may not resolve."
    ping -c1 -W3 archive.ubuntu.com >/dev/null 2>&1 && ok "network up" || { warn "no network - almost nothing below will work"; return 1; }

    # Which Pocket 3 is this? It decides the audio fix, and nothing else.
    CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ *//')
    note "CPU: $CPU"
    if grep -qiE 'N6000|N5100|Jasper' /proc/cpuinfo; then
        POCKET3_CPU=jasperlake
    elif grep -qiE '1195G7|1165G7|Tiger' /proc/cpuinfo; then
        POCKET3_CPU=tigerlake
    else
        POCKET3_CPU=unknown
    fi
    echo "$POCKET3_CPU" > /tmp/.pocket3-cpu
    ok "detected variant: $POCKET3_CPU"
    sudo -v || return 1
    ok "sudo cached"
}

# --------------------------------------------------------------------------
# apt sources, keys, i386
# --------------------------------------------------------------------------
phase_1_sources() {
    step "Phase 1 - third-party apt sources and signing keys"
    sudo dpkg --add-architecture i386
    sudo install -d /etc/apt/keyrings /usr/share/keyrings
    for k in "$PAYLOAD"/manifests/keyrings/*; do
        [ -e "$k" ] || continue
        sudo install -m644 "$k" /usr/share/keyrings/
        sudo install -m644 "$k" /etc/apt/keyrings/
    done
    ok "installed $(ls "$PAYLOAD"/manifests/keyrings | wc -l) keyrings into both locations"

    # Add sources one at a time so a single dead PPA cannot block the rest.
    for s in "$PAYLOAD"/manifests/apt-sources/*; do
        [ -e "$s" ] || continue
        n=$(basename "$s")
        sudo install -m644 "$s" "/etc/apt/sources.list.d/$n"
        if sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/$n" \
               -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" >/dev/null 2>&1; then
            ok "$n"
        else
            sudo rm -f "/etc/apt/sources.list.d/$n"
            warn "$n failed to refresh - removed. (jammy/focal PPAs often have no noble build.)"
        fi
    done
    sudo apt-get update 2>&1 | tail -3 | tee -a "$LOG"
}

# --------------------------------------------------------------------------
# the packages
# --------------------------------------------------------------------------
phase_2_apt() {
    step "Phase 2 - apt packages ($(wc -l < "$PAYLOAD/manifests/apt-packages.txt") requested)"
    note "Installing in one transaction first; anything that fails is retried one-by-one."
    mapfile -t PKGS < "$PAYLOAD/manifests/apt-packages.txt"
    if sudo apt-get install -y --no-install-recommends "${PKGS[@]}" 2>&1 | tail -20 | tee -a "$LOG"; then
        ok "bulk install succeeded"
        return 0
    fi
    warn "bulk install failed - falling back to per-package so one bad name cannot stop 400 good ones"
    local miss=()
    for p in "${PKGS[@]}"; do
        sudo apt-get install -y --no-install-recommends "$p" >/dev/null 2>&1 || miss+=("$p")
    done
    if [ ${#miss[@]} -gt 0 ]; then
        printf '%s\n' "${miss[@]}" > "$HOME/pocket3-apt-unavailable.txt"
        warn "${#miss[@]} packages could not be installed -> ~/pocket3-apt-unavailable.txt"
    fi
}

phase_3_snaps() {
    step "Phase 3 - snaps"
    command -v snap >/dev/null || sudo apt-get install -y snapd
    while read -r s; do
        [ -n "$s" ] || continue
        if grep -qx "$s" "$PAYLOAD/manifests/snaps-classic.txt" 2>/dev/null; then
            sudo snap install "$s" --classic && ok "$s (classic)" || warn "snap $s failed"
        else
            sudo snap install "$s" && ok "$s" || warn "snap $s failed"
        fi
    done < "$PAYLOAD/manifests/snaps.txt"
}

phase_4_flatpaks() {
    step "Phase 4 - flatpaks"
    sudo apt-get install -y flatpak gnome-software-plugin-flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    while read -r f; do
        [ -n "$f" ] || continue
        sudo flatpak install -y flathub "$f" && ok "$f" || warn "flatpak $f failed"
    done < "$PAYLOAD/manifests/flatpaks.txt"
}

# --------------------------------------------------------------------------
# language toolchains - the layer adam_laptop never covered
# --------------------------------------------------------------------------
phase_5_toolchains() {
    step "Phase 5 - node / nvm / pnpm / uv / python"
    if [ ! -d "$HOME/.nvm" ]; then
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && ok "nvm installed"
    else ok "nvm already present"; fi
    export NVM_DIR="$HOME/.nvm"; [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    nvm install 22 && nvm alias default 22 && ok "node $(node -v)"
    corepack enable 2>/dev/null; corepack prepare pnpm@latest --activate 2>/dev/null && ok "pnpm $(pnpm -v 2>/dev/null)"
    command -v uv >/dev/null || { curl -LsSf https://astral.sh/uv/install.sh | sh && ok "uv installed"; }
    [ -s "$PAYLOAD/manifests/pip-user.txt" ] && pip3 install --user --break-system-packages -r "$PAYLOAD/manifests/pip-user.txt" 2>&1 | tail -3
    ok "toolchains done"
}

# --------------------------------------------------------------------------
# dotfiles - sway, foot colours, bashrc, wallpaper
# --------------------------------------------------------------------------
phase_6_dotfiles() {
    step "Phase 6 - dotfiles, terminal colours, wallpaper"
    mkdir -p "$HOME"/.config/{sway,foot,gtk-3.0,doom} "$HOME/.local/share/backgrounds" "$HOME/bin"

    [ -f "$PAYLOAD/wallpaper/wallpaper.jpg" ] && install -m644 "$PAYLOAD/wallpaper/wallpaper.jpg" "$HOME/.local/share/backgrounds/wallpaper.jpg"
    ok "wallpaper -> ~/.local/share/backgrounds/wallpaper.jpg"

    # sway config, with the daily driver's absolute wallpaper path rewritten
    sed "s|/home/adam/.local/share/backgrounds/[^ ]*\.jpg|$HOME/.local/share/backgrounds/wallpaper.jpg|" \
        "$PAYLOAD/dotfiles/config/sway/config" > "$HOME/.config/sway/config"
    install -m755 "$PAYLOAD/dotfiles/config/sway/status.sh" "$HOME/.config/sway/status.sh"

    # append the Pocket 3 display block, once
    if ! grep -q "GPD Pocket 3" "$HOME/.config/sway/config"; then
        printf '\n' >> "$HOME/.config/sway/config"
        cat "$PAYLOAD/pocket3/sway-gpd-pocket3.conf" >> "$HOME/.config/sway/config"
        ok "appended GPD Pocket 3 display block to sway config"
    fi
    ok "sway config + status bar (safety-yellow #FFE600 theme)"

    install -m644 "$PAYLOAD/dotfiles/config/foot/foot.ini" "$HOME/.config/foot/foot.ini"
    ok "foot colours (black bg, alpha 0.92)"
    [ -f "$PAYLOAD/dotfiles/config/gtk-3.0/settings.ini" ] && install -m644 "$PAYLOAD/dotfiles/config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/"
    cp "$PAYLOAD"/dotfiles/config/doom/* "$HOME/.config/doom/" 2>/dev/null && ok "doom config"
    [ -f "$PAYLOAD/dotfiles/gitconfig" ] && install -m644 "$PAYLOAD/dotfiles/gitconfig" "$HOME/.gitconfig" && ok "gitconfig"

    # bashrc additions - the PATH, EDITOR, nvm hook and the go() function
    if ! grep -q "adam's .bashrc additions" "$HOME/.bashrc" 2>/dev/null; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.bak-$(date +%Y%m%d-%H%M%S)"
        cat "$PAYLOAD/dotfiles/bashrc-additions.sh" >> "$HOME/.bashrc"
        ok "bashrc additions appended (PATH, EDITOR, nvm, go())"
    else ok "bashrc additions already present"; fi

    mkdir -p "$HOME/.claude"
    [ -f "$PAYLOAD/dotfiles/claude/settings.json" ] && install -m644 "$PAYLOAD/dotfiles/claude/settings.json" "$HOME/.claude/settings.json"
    [ -f "$PAYLOAD/dotfiles/claude/CLAUDE.md" ]    && install -m644 "$PAYLOAD/dotfiles/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    ok "claude settings (NOT credentials - see the manual checklist)"
}

# --------------------------------------------------------------------------
# the Pocket 3 hardware itself
# --------------------------------------------------------------------------
phase_7_hardware() {
    step "Phase 7 - GPD Pocket 3 hardware quirks"
    local cpu; cpu=$(cat /tmp/.pocket3-cpu 2>/dev/null || echo unknown)

    sudo install -d /etc/default/grub.d
    sudo install -m644 "$PAYLOAD/pocket3/grub-gpd-pocket3.cfg" /etc/default/grub.d/gpd-pocket3.cfg
    sudo update-grub 2>&1 | tail -2
    ok "grub: fbcon rotation, panel orientation, s2idle suspend"

    sudo install -m644 "$PAYLOAD/pocket3/99-gpd-pocket3-touch.rules" /etc/udev/rules.d/
    sudo install -d /etc/udev/hwdb.d
    sudo install -m644 "$PAYLOAD/pocket3/61-gpd-pocket3-sensor-local.hwdb" /etc/udev/hwdb.d/
    sudo systemd-hwdb update && sudo udevadm control --reload
    ok "touchscreen + stylus rotation, accelerometer mount matrix"

    case "$cpu" in
      tigerlake)
        sudo install -m644 "$PAYLOAD/pocket3/alsa-gpd-pocket3.conf" /etc/modprobe.d/alsa-gpd-pocket3.conf
        ok "audio: forced legacy HDA (dsp_driver=1) - correct for the i7-1195G7" ;;
      jasperlake)
        note "audio: N6000 works with SOF on kernel >= 6.1, so the HDA override is NOT applied."
        note "If you get no sound anyway, run:  sudo cp $PAYLOAD/pocket3/alsa-gpd-pocket3.conf /etc/modprobe.d/" ;;
      *)
        warn "CPU variant not recognised - audio fix skipped."
        note "If there is no sound: sudo cp $PAYLOAD/pocket3/alsa-gpd-pocket3.conf /etc/modprobe.d/ && reboot" ;;
    esac

    # power management, worth having on a handheld
    sudo systemctl enable --now tlp 2>/dev/null && ok "tlp enabled" || true
    sudo systemctl enable --now thermald 2>/dev/null && ok "thermald enabled" || true
}

# --------------------------------------------------------------------------
# custom tools
# --------------------------------------------------------------------------
phase_8_tools() {
    step "Phase 8 - custom tools (go-layout, bdmenu_ada, settings-tools)"
    local V="$HOME/ŻYCIE/VIBECODING"
    mkdir -p "$HOME/bin" "$HOME/.local/bin"

    if [ -d "$V/go-layout" ]; then
        ( cd "$V/go-layout" && ./install.sh ) && ok "go-layout installed (the 'go' command)"
    else
        warn "go-layout not found - run phase 10 (ŻYCIE) first, then re-run this phase"
    fi

    for t in bdmenu_ada/bdmenu_ada settings-tools/settings settings-tools/settings-hub \
             settings-tools/settings-dmenu settings-tools/settings-wofi settings-tools/printerctl; do
        src="$V/$t"
        [ -x "$src" ] && ln -sfn "$src" "$HOME/bin/$(basename "$t")" && ok "linked $(basename "$t")"
    done
    [ -x "$HOME/ŻYCIE/archangel/archangel" ] && ln -sfn "$HOME/ŻYCIE/archangel/archangel" "$HOME/bin/archangel"
}

phase_9_doom() {
    step "Phase 9 - Doom Emacs"
    if [ ! -d "$HOME/.config/emacs" ]; then
        git clone --depth 1 https://github.com/doomemacs/doomemacs "$HOME/.config/emacs" || { warn "clone failed"; return 1; }
    fi
    "$HOME/.config/emacs/bin/doom" install --no-config --force 2>&1 | tail -5
    "$HOME/.config/emacs/bin/doom" sync 2>&1 | tail -5
    ok "doom synced (config.el/init.el/packages.el came from phase 6)"
}

phase_10_zycie() {
    step "Phase 10 - ŻYCIE"
    if [ -d "$HOME/ŻYCIE/.git" ]; then
        ok "ŻYCIE already a git repo - pulling"
        git -C "$HOME/ŻYCIE" pull --ff-only 2>&1 | tail -3
    elif [ -d "$PAYLOAD/zycie" ]; then
        cp -a "$PAYLOAD/zycie" "$HOME/ŻYCIE"
        git -C "$HOME/ŻYCIE" remote set-url origin https://github.com/asdfgh0318/zycie.git 2>/dev/null
        ok "ŻYCIE restored from the stick ($(du -sh "$HOME/ŻYCIE" | cut -f1))"
    else
        warn "no ŻYCIE on the payload - cloning from GitHub (needs 'gh auth login' for the private repo)"
        git clone https://github.com/asdfgh0318/zycie.git "$HOME/ŻYCIE" || warn "clone failed - authenticate and retry"
    fi
    note "This is the TRACKED content only. Papers/, Zotero/, org-mode/ and the other"
    note "large directories were deliberately left off the 30GB stick - sync them separately."
}

phase_11_groups() {
    step "Phase 11 - user groups"
    for g in dialout plugdev video audio render kvm libvirt docker wireshark lpadmin; do
        getent group "$g" >/dev/null || continue
        sudo usermod -aG "$g" "$USER" && ok "added to $g"
    done
    note "Group changes need a full logout to take effect."
}

# --------------------------------------------------------------------------
PHASES=(0_preflight 1_sources 2_apt 3_snaps 4_flatpaks 5_toolchains 6_dotfiles
        7_hardware 8_tools 9_doom 10_zycie 11_groups)

if [ "${1:-}" = "--list" ]; then
    printf 'Phases:\n'; for p in "${PHASES[@]}"; do printf '  %s\n' "${p%%_*}  ${p#*_}"; done; exit 0
fi

WANT=("$@")
for p in "${PHASES[@]}"; do
    n="${p%%_*}"
    if [ ${#WANT[@]} -gt 0 ]; then
        printf '%s\n' "${WANT[@]}" | grep -qx "$n" || continue
    fi
    "phase_$p" || { FAILED+=("$n"); warn "phase $n reported a failure - continuing"; }
done

step "Done"
[ ${#FAILED[@]} -gt 0 ] && warn "phases with failures: ${FAILED[*]} (re-run them: ./setup-pocket3.sh ${FAILED[*]})"
cat "$PAYLOAD/MANUAL-CHECKLIST.md"
