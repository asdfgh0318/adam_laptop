#!/bin/bash
# Sway status bar script with btop-style colors
# Volume updates every 0.1s, other stats every 1s

counter=0

# Initialize slow-updating values
wifi_ssid="..."
bat_cap="..."
bat_icon=""
disk="..."
mem="..."
load="..."

while true; do
    # Volume (updates every cycle - 0.1s) - LC_ALL=C fixes decimal separator
    vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | LC_ALL=C awk '{printf "%.0f%%", $2*100}')
    muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -q MUTED && echo " [MUTED]")

    # Brightness (updates every cycle - 0.1s)
    bright=$(brightnessctl -m 2>/dev/null | cut -d',' -f4 | tr -d '%')%

    # Date/time (updates every cycle)
    datetime=$(date +'%Y-%m-%d %H:%M:%S')

    # Other stats update every 10 cycles (1 second)
    if [ $counter -eq 0 ]; then
        # WiFi
        wifi_ssid=$(iwgetid -r 2>/dev/null || echo "down")
        [ -z "$wifi_ssid" ] && wifi_ssid="down"

        # Battery
        bat_cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "N/A")
        bat_volt=$(LC_ALL=C awk '{printf "%.2f", $1/1000000}' /sys/class/power_supply/BAT0/voltage_now 2>/dev/null || echo "N/A")
        bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        [ "$bat_status" = "Charging" ] && bat_icon="+" || bat_icon=""

        # Disk
        disk=$(df -h / | awk 'NR==2 {print $4}')

        # Memory
        mem=$(free -h | awk 'NR==2 {print $3"/"$2}')

        # CPU load
        load=$(cut -d' ' -f1 /proc/loadavg)
    fi

    # Output with btop-style colors
    echo "<span color='#00ffff'>VOL: $vol$muted</span> | <span color='#ffaa00'>BRI: $bright</span> | <span color='#00ff00'>W: $wifi_ssid</span> | <span color='#ffff00'>BAT: $bat_icon$bat_cap% ${bat_volt}V</span> | <span color='#ff00ff'>DISK: $disk</span> | <span color='#33aaff'>MEM: $mem</span> | <span color='#ff5555'>CPU: $load</span> | <span color='#ffffff'>$datetime</span>"

    sleep 0.1
    counter=$(( (counter + 1) % 10 ))
done
