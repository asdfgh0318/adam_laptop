# What the script cannot do for you

Everything below is either a secret or an interactive login. No script should
carry these on a USB stick, so they are yours to do by hand. Roughly 20 minutes.

## 1. Secrets — bring these on a separate encrypted stick or re-issue them

| What | Where it lives | Easiest route |
|---|---|---|
| SSH key | `~/.ssh/id_ed25519` + `.pub` | copy both, then `chmod 600 ~/.ssh/id_ed25519` |
| GitHub auth | `~/.config/gh/hosts.yml` | just run `gh auth login` on the Pocket 3 |
| Claude Code login | `~/.claude/.credentials.json` | run `claude` and log in |
| Keyring / saved wifi | gnome-keyring | re-enter as you go |

**Do not copy `~/.claude/.credentials.json` onto the Ventoy stick** — it is an
exFAT partition with no permissions, readable by anything that mounts it.

## 2. Logins to redo

Brave · Spotify · Thunderbird · Discord · Ferdium · Teams · Zotero ·
TeamViewer · RustDesk · Syncthing (needs device re-pairing on both ends)

## 3. Data that was too big for a 30 GB stick

The stick carries the **tracked** ŻYCIE content only. These were left behind
on purpose:

```
Papers/          1.3G      Zotero/       112M
ardupilot/       1.9G      org-mode/     109M
Applications/    1.1G      Sync/         217M
Pulpit/          637M      HUB/          217M
```

Pull them over the network once the Pocket 3 is up:

```bash
rsync -avh --progress adam@<precision-5520>:~/Papers ~/
# or point Syncthing at the folders you actually want on a handheld
```

## 3b. If you used the unattended install

- **Change the password.** It is `pocket3` and it is written in a plaintext file
  on this stick (`autoinstall/user-data`, hashed, but the plaintext is in this
  sentence). `passwd` on first login.
- `sudo` asks for no password until the first-boot service finishes. Check that
  `/etc/sudoers.d/90-pocket3-firstboot` is gone afterwards:
  `ls /etc/sudoers.d/` — if it is still there, `sudo rm` it.
- The whole run is logged in `~/setup-pocket3-firstboot.log`.

## 4. First-boot reality

- Phase 2 downloads **several GB** of packages. Be on wifi you trust and plugged in.
- **Reboot after phase 7.** The grub, audio and udev changes only take effect then.
- Log out fully after phase 11 for the group memberships.

## 5. If the screen is wrong

One line, one value, in `~/.config/sway/config`:

```
output DSI-1 transform 90 scale 1.5
```

Upside down → change `90` to `270`. Text too small → lower `1.5` to `1.25`.
Then `Mod+Shift+c` to reload. Nothing else in the display setup should need touching.

## 6. If there is no sound

The audio fix depends on which Pocket 3 you have, and the script detects it.
If it guessed wrong, or you got the "not recognised" warning:

```bash
sudo cp /path/to/PAYLOAD/pocket3/alsa-gpd-pocket3.conf /etc/modprobe.d/
sudo reboot
```

That forces the legacy HDA driver. It is the right fix for the **i7-1195G7**
and the wrong one for the **N6000**, so if sound was already working, remove it again.
