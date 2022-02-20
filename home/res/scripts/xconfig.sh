# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou

# have exactly one of internal and external displays connected and primary
if [ $(hostname) = "CH-21N" ]; then
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
# We take advantage of the ccd alias (only present in zsh) to enter the config
# directory to perform nix eval, getting the correct DPI value. (Ew!)
zsh -c '(ccd; echo "Xft.dpi: $(nix eval .\#nixosConfigurations.$(hostname).config.services.xserver.dpi)" | xrdb -merge)'

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

# disable touchscreen
if [ $(hostname) = "CH-22T" ]; then
	xinput set-prop "Raydium Corporation Raydium Touch System" "Device Enabled" 0
fi

# disable X power saving
xset s off -dpms

# disable stream restore module if loaded
[ $(pactl list short modules | grep module-stream-restore -c || true) -gt 0 ] &&
	pactl unload-module module-stream-restore
