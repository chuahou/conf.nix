#!/usr/bin/env bash
#
# Toggles whether dunst notifications are enabled.
#
# Also see https://github.com/dunst-project/dunst/issues/77.

set -e

# path to work in
DNDPATH=$HOME/.local/share/dndenable

get_status () {
	if [ -f "$DNDPATH" ]; then
		echo "do not disturb"
	else
		echo "notif on"
	fi
}

dnd_on () {
	killall -SIGUSR1 dunst && touch $DNDPATH
	polybar-msg hook dnd_ipc 1
}

dnd_off () {
	killall -SIGUSR2 dunst && rm $DNDPATH
	polybar-msg hook dnd_ipc 1
}

toggle () {
	if [ -f "$DNDPATH" ]; then
		dnd_off
	else
		dnd_on
	fi
}

if [ "$#" -lt 1 ]; then
	get_status
else
	case "$1" in
		toggle) toggle     ;;
		on)     dnd_on     ;;
		off)     dnd_off   ;;
		*)      get_status ;;
	esac
fi
