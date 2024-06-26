# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022, 2023 Chua Hou

# disable mouse acceleration
xset mouse 0 0
# Logitech G304 does not have "mouse" in its name, and presents both a keyboard
# and a pointer device, so we select by name + pointer.
for mouse in $(xinput --list | sed -n 's/^.*\([Mm]ouse\|Logitech G304\).*id=\([0-9]\+\).*pointer.*$/\2/p')
do
	if [ $(xinput list-props $mouse | \
		grep -c "libinput Accel Profile Enabled") -ge 1 ]; then
		xinput set-prop $mouse "libinput Accel Profile Enabled" 0 1
	fi
done

# disable X power saving
xset s off -dpms

# disable stream restore module if loaded
[ $(pactl list short modules | grep module-stream-restore -c || true) -gt 0 ] &&
	pactl unload-module module-stream-restore

# Prevent suspending on idle, which causes noise for some connected 3.5mm
# speakers.
[ $(pactl list short modules | grep module-suspend-on-idle -c || true) -gt 0 ] &&
	pactl unload-module module-suspend-on-idle
