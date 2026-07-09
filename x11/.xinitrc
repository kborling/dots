#!/bin/sh

# D-Bus session bus for the whole graphical session. Without this, apps like
# Firefox autolaunch their own private bus over X11 and stall ~20s on startup
# (and daemons like dunst/blueman need a shared bus too).
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
    export DBUS_SESSION_BUS_ADDRESS DBUS_SESSION_BUS_PID
fi
# Share the X environment with dbus-activated services.
dbus-update-activation-environment --all 2>/dev/null || true

# Merge X resources (DPI, Xft rendering, fleury colors)
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources

# Keyboard repeat rate (250ms delay, 30 cps)
xset r rate 250 30

# Normal cursor. (Wallpaper is set from ~/.stumpwmrc AFTER StumpWM grabs the
# root window — setting it here gets clobbered on WM startup, leaving grey.)
xsetroot -cursor_name left_ptr

# GTK font/DPI settings for a bare WM
xsettingsd &

# Start PipeWire audio
pipewire &
wireplumber &
pipewire-pulse &

# Notification daemon
dunst &

# Compositor
picom &

# Touchpad gestures (3/4-finger swipe = workspace switch)
libinput-gestures &

# Network tray (runs in stumpwm stumptray)
# nm-tray &

# Bluetooth tray
blueman-applet &

# Redshift (night light)
#redshift &

# Spotifyd
#spotifyd &

# SSH agent
eval "$(ssh-agent -s)"

# Start StumpWM
# StumpWM is a saved SBCL image; point it at the SBCL contrib dir so libraries
# that (require :sb-cltl2) — e.g. slynk — can load at runtime.
export SBCL_HOME=/usr/lib/sbcl

exec stumpwm

