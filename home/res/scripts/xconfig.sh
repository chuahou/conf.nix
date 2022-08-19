# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou

# have exactly one of internal and external displays connected and primary
if [ $(hostname) = "CH-21NS" ]; then
	internal=eDP-1-1
	external=HDMI-0
elif [ $(hostname) = "CH-22T" ]; then
	internal=eDP-1
	external=HDMI-1
fi
if [ $(xrandr -q | grep -c "$external connected") -gt 0 ]; then
	xrandr --output $external --auto --primary --output $internal --off
else
	xrandr --output $internal --auto --primary --output $external --off
fi

# set DPI
(cd $(conf-dir-path); echo "Xft.dpi: $(cat nixos/dpi/$(hostname))" | xrdb -merge)

# disable mouse acceleration
xset mouse 0 0
for mouse in $(xinput --list | sed -n 's/^.*[Mm]ouse.*id=\([0-9]\+\).*$/\1/p')
do
	if [ $(xinput list-props $mouse | \
		grep -c "libinput Accel Profile Enabled") -ge 1 ]; then
		xinput set-prop $mouse "libinput Accel Profile Enabled" 0 1
	fi
done

# disable touchpad, enable natural scrolling
if [ $(hostname) = "CH-21N" ]; then
	xinput set-prop "DELL08EC:00 06CB:CCA8 Touchpad" "libinput Natural Scrolling Enabled" 1
	xinput set-prop "DELL08EC:00 06CB:CCA8 Touchpad" "Device Enabled" 0
fi

# disable touchscreen, enable natural scrolling on touchpad
if [ $(hostname) = "CH-22T" ]; then
	xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Natural Scrolling Enabled" 1
	xinput set-prop "Raydium Corporation Raydium Touch System" "Device Enabled" 0
fi

# disable X power saving
xset s off -dpms

# disable stream restore module if loaded
[ $(pactl list short modules | grep module-stream-restore -c || true) -gt 0 ] &&
	pactl unload-module module-stream-restore

# cope with UK keyboard layout (ew) by mapping the physical \ button to left
# shift
if [ $(hostname) = "CH-22T" ]; then
	xmodmap -e "keycode 94 = Shift_L"
fi
