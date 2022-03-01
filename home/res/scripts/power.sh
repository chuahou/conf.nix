# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Chua Hou
#
# Alerts when battery at critical level, and executes shutdown at even lower
# level.

# levels at which to notify, and shutdown
NOTIFY_LEVEL=10
SHUTDOWN_LEVEL=5

# delay in seconds before shutting down
SHUTDOWN_DELAY=30

# interval to check in seconds
LOOP_INTERVAL=60

while true; do

	sleep $LOOP_INTERVAL

	# if charging, skip
	[ ! $(cat /sys/class/power_supply/BAT*/status) = "Discharging" ] && \
		continue

	# get battery level
	CURRENT_LEVEL=$(upower -i $(upower -e | grep battery) | \
		sed -n 's/.*percentage:\s*\([0-9]\+\)%/\1/p')

	# ensure is integer, otherwise notify
	[[ $CURRENT_LEVEL =~ ^[0-9]+$ ]] || \
		notify-send -u critical -a $(basename $0) \
			"Invalid battery level $CURRENT_LEVEL%!"

	# notify if lower than NOTIFY_LEVEL
	[ "$CURRENT_LEVEL" -lt "$NOTIFY_LEVEL" ] && \
		notify-send -u critical -a $(basename $0) \
			"Battery level critical at $CURRENT_LEVEL%!"

	# notify and shutdown in SHUTDOWN_DELAY seconds if lower than SHUTDOWN_LEVEL
	[ "$CURRENT_LEVEL" -lt "$SHUTDOWN_LEVEL" ] && \
		notify-send -u critical -a $(basename $0) \
			"Shutting down in $SHUTDOWN_DELAY seconds!" && \
		paplay $AUDIO_FILE && \
		sleep $SHUTDOWN_DELAY && \
		[ $(cat /sys/class/power_supply/BAT*/status) = "Discharging" ] && \
		systemctl poweroff

done
