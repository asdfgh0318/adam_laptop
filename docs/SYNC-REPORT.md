# Multi-Machine Sync Report

## Supported Machines

| Machine | Hardware | Hostname |
|---|---|---|
| MacBook 10,1 | Intel i5, Intel Iris Plus 640, Broadcom WiFi | macbook |
| ThinkPad T480s | Intel i5-8250U, Intel UHD 620, Intel WiFi 8265 | thinkpad |

## Tracked Repositories

### VIBECODING (10 repos)

| Repo | GitHub Remote | Default Branch |
|---|---|---|
| adam_laptop | asdfgh0318/adam_laptop | main |
| ars_noise_measurement | asdfgh0318/ars_noise_measurement | master |
| bangle | asdfgh0318/bangle | master |
| bdmenu_ada | asdfgh0318/bdmenu_ada | master |
| doom_emacs_setup | asdfgh0318/doom-emacs-setup | master |
| settings-tools | asdfgh0318/settings-tools | master |
| space-station | asdfgh0318/space-station | main |
| stasia-woda | asdfgh0318/stasia-woda | master |
| symulator_fpv | asdfgh0318/fpv_simulator | master |
| vibecoding-logger | asdfgh0318/vibecoding-logger | master |

### PRACA (3 repos)

| Repo | GitHub Remote | Default Branch | Visibility |
|---|---|---|---|
| aruco_drone_nav | asdfgh0318/aruco_drone_nav | main | public |
| BRIK_PDB | asdfgh0318/BRIK_PDB | master | public |
| brik_fail_analysis | asdfgh0318/brik_fail_analysis | master | private |

## Sync Checker

Use `scripts/sync-check.sh` to compare repo states between machines:

```bash
./scripts/sync-check.sh <remote-host>
# Example:
./scripts/sync-check.sh adam@10.77.96.106
```

## Notes

- Local artifacts (`.venv/`, `node_modules/`, `buildroot/build/`, `__pycache__/`) are machine-specific and not synced
- The ŻYCIE parent repo tracks personal files (PRACA tracked content, documents, etc.)
- Each VIBECODING/PRACA sub-repo is an independent git repository
