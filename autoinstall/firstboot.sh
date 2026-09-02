#!/bin/bash
# Runs once as root at first boot. Waits for internet (connect to wifi in GNOME),
# runs setup-pocket3.sh as adam non-interactively, then removes itself and the
# passwordless-sudo drop-in. Progress: tail -f ~/setup-pocket3-firstboot.log
PAYLOAD=/home/adam/pocket3-payload
echo "[$(date)] firstboot: waiting for network"
until ping -c1 -W3 archive.ubuntu.com >/dev/null 2>&1; do sleep 20; done
echo "[$(date)] firstboot: network up, running setup-pocket3.sh"
wall "pocket3 first-boot setup is running in the background (~30-60 min). Log: ~/setup-pocket3-firstboot.log" 2>/dev/null || true
runuser -u adam -- env HOME=/home/adam USER=adam DEBIAN_FRONTEND=noninteractive NONINTERACTIVE=1 \
    bash -c "cd '$PAYLOAD' && ./setup-pocket3.sh"
rc=$?
echo "[$(date)] firstboot: setup-pocket3.sh exited $rc"
rm -f /etc/sudoers.d/90-pocket3-firstboot
systemctl disable pocket3-firstboot.service
wall "pocket3 setup finished (exit $rc). Reboot, then log in to the Sway session. Change your password: passwd" 2>/dev/null || true
exit $rc
