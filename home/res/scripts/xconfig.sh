# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

# check if external monitor connected
if [ $(hostname) = "CH-21N" ]; then
	if [ $(xrandr -q | grep -c "HDMI-0 connected") -gt 0 ]; then
		# turn off eDP-1-1 and connect only to HDMI-0
		xrandr --output HDMI-0 --auto --primary --output eDP-1-1 --off
	else
		xrandr --output eDP-1-1 --auto --primary --output HDMI-0 --off
	fi
fi

# set DPI
echo "Xft.dpi: 96" | xrdb -merge

# disable mouse acceleration
xset mouse 0 0
for mouse in $(xinput --list | sed -n 's/^.*[Mm]ouse.*id=\([0-9]\+\).*$/\1/p')
do
	if [ $(xinput list-props $mouse | \
		grep -c "libinput Accel Profile Enabled") -ge 1 ]; then
		xinput set-prop $mouse "libinput Accel Profile Enabled" 0 1
	fi
done

# disable touchpad
if [ $(hostname) = "CH-21N" ]; then
	xinput set-prop "DELL08EC:00 06CB:CCA8 Touchpad" "Device Enabled" 0
fi

# disable X power saving
xset s off -dpms

# disable stream restore module if loaded
[ $(pactl list short modules | grep module-stream-restore -c || true) -gt 0 ] &&
	pactl unload-module module-stream-restore
