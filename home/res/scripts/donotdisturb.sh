# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

get_status () {
	if [ -f "${state_file}" ]; then
		echo "do not disturb"
	else
		echo "notif on"
	fi
}

dnd_on () {
	killall -SIGUSR1 -r '.*dunst' && touch ${state_file}
	hook
}

dnd_off () {
	killall -SIGUSR2 -r '.*dunst' && rm ${state_file}
	hook
}

toggle () {
	[ -f "${state_file}" ] && dnd_off || dnd_on
}

if [ "$#" -lt 1 ]; then
	get_status
else
	case "$1" in
		toggle) toggle     ;;
		on)     dnd_on     ;;
		off)    dnd_off    ;;
		*)      get_status ;;
	esac
fi
