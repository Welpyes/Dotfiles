#!/bin/bash

# Options
shutdown="⏻  Shutdown"
reboot="  Reboot"
logout="  Logout"
suspend="  Suspend"
lock="  Lock"

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -theme ~/.config/rofi/themes/powermenu.rasi
}

# Show menu
chosen="$(echo -e "$lock\n$logout\n$suspend\n$reboot\n$shutdown" | rofi_cmd)"

# Execute action
case $chosen in
    $shutdown)
        shutdown
        ;;
    $reboot)
        systemctl reboot
        ;;
    $logout)
        # Adjust for your WM/DE
        hyprctl dispatch exit
        ;;
    $suspend)
        systemctl suspend
        ;;
    $lock)
        swaylock
        ;;
esac
