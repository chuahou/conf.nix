# SPDX-License-Identifier: MIT
# Copyright (c) 2020, 2021 Chua Hou
#
# Volume manager for pulseaudio.

set -e

# get sink name of sink #$1
get_sink_name () {
	pactl list sinks | grep "Sink #$1$" -A 3 | \
		sed -n 's/^.*Description: \([^ ]\+\).*$/\1/p'
}

# get sink volume of sink #$1
get_sink_vol () {
	pactl list sinks | grep "Sink #$1$" -A 10 | \
		sed -n 's/^.*Volume:.*\s\([0-9]\+\)%.*$/\1/p'
}

# get mute status of sink #$1
get_sink_mute () {
	pactl list sinks | grep "Sink #$1$" -A 9 | \
		sed -n 's/^.*Mute: \(yes\|no\).*$/\1/p'
}

# set default sink to sink #$1 and move existing sink inputs
set_sink () {
	local input
	pactl set-default-sink $1
	for input in $(pactl list short sink-inputs | awk '{print $1}'); do
		pactl move-sink-input $input $1
	done
}

# returns currently chosen sink
current_sink () {
	local sinkname=$(pacmd stat | awk -F': ' '/^Default sink name/{print $2}')
	pactl list short sinks | awk "/$sinkname/{print \$1}"
}

# get current sink
SINK=$(current_sink)

# if no args, just print status
if [ $# -eq 0 ]; then
	echo -n $(get_sink_name $SINK) | awk -v ORS= '{print tolower($0)}'
	case $(get_sink_mute $SINK) in
		yes) echo " [MUTE]" ;;
		*)   echo " $(get_sink_vol $SINK)%" ;;
	esac
	exit
fi

# if args, process them
case $1 in
	sink) # change sink
		# convert SINKS to array
		SINKS=$(pactl list short sinks | awk '{print $1}')
		IFS=$'\n' SINKS=($SINKS)

		# get index of current SINK
		for i in "${!SINKS[@]}"; do
			if [[ "${SINKS[$i]}" = "${SINK}" ]]; then
				CURR_IDX="${i}"
				break
			fi
		done

		# rotate SINKS array
		SINKS+=("${SINKS[0]}")
		SINKS=("${SINKS[@]:1}")

		# change sink
		SINK="${SINKS[$i]}"
		set_sink $SINK
		;;
	volup) # volume up
		pactl set-sink-volume $SINK +5%
		;;
	voldn) # volume down
		pactl set-sink-volume $SINK -5%
		;;
	mute) # mute toggle
		pactl set-sink-mute $SINK toggle
		;;
esac
