# GPD Pocket 3 — Ubuntu 24.04 + sway, cloned from the Precision 5520

This stick is a Ventoy drive. It boots the Ubuntu installer **and** carries
everything needed to turn the result into a copy of the daily driver.

## Use it — unattended (default)

1. **Boot the Pocket 3 from this stick**, pick `ubuntu-24.04.4-desktop-amd64.iso`.
   Ventoy then asks *"Boot with auto-install template?"* — choose the
   `pocket3-autoinstall-user-data` entry. **This wipes the Pocket 3's largest disk
   without asking again.** (Choose *no template* for a normal, interactive install.)
2. Ubuntu installs itself: user `adam`, hostname `pocket3`, Polish keyboard, Warsaw
   timezone, temporary password **`pocket3`**. The payload is copied to
   `~/pocket3-payload` and a one-shot service is armed. Reboot when it says so.
3. **Log in to GNOME and connect to wifi.** That is the only thing you do. The
   service is waiting for internet; the moment it has it, `setup-pocket3.sh` runs
   in the background (30–60 min). Watch it: `tail -f ~/setup-pocket3-firstboot.log`.
   It announces on every terminal when it finishes.
4. **Reboot**, pick the *Sway* session at the login screen, run `passwd`.
5. Read `MANUAL-CHECKLIST.md` — the ~20 minutes of secrets and logins no script
   should do for you.

The passwordless-sudo rule the service needs deletes itself when the run ends.
If the service never fires, or dies: everything is already in `~/pocket3-payload`,
so fall back to the manual path below — the script is idempotent.

Caveat, honestly: Ventoy documents its auto-install plugin for Ubuntu *Server*.
The 24.04 *desktop* installer uses the same subiquity autoinstall machinery and is
reported to work, but I could not test this without the device. If Ventoy boots
the ISO but the installer asks questions anyway, the plugin did not engage — just
install by hand and continue from step 3 of the manual path.

## Use it — by hand (fallback)

1. **Boot the Pocket 3 from this stick.** Ventoy shows a menu; pick
   `ubuntu-24.04.4-desktop-amd64.iso`, and *no template* when asked.
   - The installer will appear **rotated 90°** — this is expected and normal.
     Tilt your head or the machine; it is only the installer.
   - Install Ubuntu normally. Connect to wifi during install.
2. **Boot into the new install**, open a terminal, and:

   ```bash
   sudo apt install -y git          # the only thing needed up front
   cp -r /media/*/Ventoy/PAYLOAD ~/pocket3-payload   # or wherever it mounts
   cd ~/pocket3-payload
   chmod +x setup-pocket3.sh        # exFAT loses the exec bit
   ./setup-pocket3.sh
   ```

   > Copy it off the stick first — do not run it in place. The scripts need to
   > `chmod` and `git` inside their own directory, and exFAT supports neither
   > exec bits nor symlinks, so a git repo used in place will misbehave.

3. **Reboot** when it finishes. Then log in and start sway from a TTY (`sway`)
   or pick the Sway session at the login screen.
4. Read `MANUAL-CHECKLIST.md` — the ~20 minutes of secrets and logins no script
   should do for you.

Phases can be run individually if something fails:
`./setup-pocket3.sh --list`, then e.g. `./setup-pocket3.sh 2 7`.
Every phase is idempotent; re-running is the intended recovery.

## What is here

| Path | What |
|---|---|
| `setup-pocket3.sh` | the installer, 12 idempotent phases |
| `MANUAL-CHECKLIST.md` | secrets, logins, big files — the parts a script must not do |
| `manifests/apt-packages.txt` | 412 packages, from `apt-mark showmanual` on the 5520 |
| `manifests/apt-sources/` + `keyrings/` | the 10 third-party repos and their signing keys |
| `manifests/snaps.txt` | 16 apps (base/runtime snaps excluded — they come as deps) |
| `manifests/flatpaks.txt` | 4 apps |
| `manifests/pip-user.txt` | 32 user-site python packages |
| `dotfiles/` | sway config + status bar, foot colours, doom, gitconfig, bashrc additions |
| `pocket3/` | the five hardware quirk files, see below |
| `wallpaper/wallpaper.jpg` | the actual wallpaper |
| `zycie/` | ŻYCIE tracked content + the four standalone tool repos |
| `adam_laptop/` | the existing repo, with the broken `/home/adam-koszalka` paths fixed |

## The Pocket 3 hardware, honestly

The panel is a portrait 1200×1920 mounted sideways. Under Xorg this needs
transformation matrices in four places. **Under sway it is one line**, which is
why your setup is the easy case here:

```
output DSI-1 transform 90 scale 1.5
```

`transform 90` matches upstream's `xrandr --rotate right`. `scale 1.5` gives an
effective 1280×800, which is what Ubuntu MATE's official Pocket 3 image uses.
**If the screen comes up upside down, change 90 to 270.** That is the only value
here that should ever need adjusting, and I could not test it without the device.

The other four files:

- `grub-gpd-pocket3.cfg` — rotates the boot console, sets the DRM panel
  orientation, and forces `mem_sleep_default=s2idle` (the only suspend mode that
  works on this machine).
- `99-gpd-pocket3-touch.rules` — rotates touch and stylus via libinput, so they
  follow the screen. Without it every tap lands in the wrong place.
- `61-gpd-pocket3-sensor-local.hwdb` — accelerometer mount matrix, for auto-rotate.
- `alsa-gpd-pocket3.conf` — **audio, and it is variant-specific.** The i7-1195G7
  has no working SOF topology and needs `dsp_driver=1` to fall back to legacy HDA.
  The N6000 works with SOF on kernel ≥ 6.1 and must *not* get this file. Phase 7
  reads `/proc/cpuinfo` and applies it only to the 1195G7.

Values taken from [wimpysworld/umpc-ubuntu](https://github.com/wimpysworld/umpc-ubuntu)'s
`data/` directory, which is the reference implementation Ubuntu MATE's official
Pocket 3 images are built from. That project is Xorg-first — its own README says
"if you use Wayland your mileage may vary" — so the quirks were cherry-picked
into sway-native form rather than running its script.

## Known weak spots on this hardware

Not solved by anything here, because nobody has solved them cleanly:

- **Webcam** — reported choppy; video capture may fail.
- **Fan control** — no good userspace control; it runs on BIOS curves.
- **Suspend** — `s2idle` is set, which is the working mode, but deep sleep is not
  available and battery drain in suspend is higher than you'd like.

## Deliberately left out

Steam, VirtualBox, QEMU/virt-manager, anbox, the duplicate WhatsApp snaps, and
the liquorix kernel headers — none of which belong on an 8-inch handheld. The
full unfiltered list is still in `adam_laptop/package-list.txt` if you want them.

Large data (Papers, Zotero, ardupilot, org-mode, Sync — about 46 GB) is not on
the stick and cannot be; see `MANUAL-CHECKLIST.md` §3 for pulling it over the network.
