# #!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# Simple CLI pomodoro timer.
# Usage: pomodoro.sh [type] [time in minutes]
# [type] defaults to work (turns on do not disturb).
# [time in minutes] defaults differ depending on [type].

set -euo pipefail

# Adapted from https://superuser.com/a/611582.
# $1 = time in minutes
# $2 = label
countdown_mins () {
    seconds=$((60 * $1))
    start=$(($(date +%s) + $seconds))
    clear
    while [ "$start" -ge `date +%s` ]; do
        time="$(( $start - `date +%s` ))"
        printf '%s\r' "$2 $(date -u -d "@$time" +%M:%S)"
        sleep 1
    done
    printf '\n' # To avoid the 00:00 timer being cleared.
    donotdisturb.sh off >/dev/null # Otherwise the notification may not work.
    notify-send "TIMER UP"
}

case ${1:-work} in
    work)
        donotdisturb.sh on >/dev/null
        countdown_mins ${2:-25} WORK
      ;;
    break)
        countdown_mins ${2:-5} BREAK
      ;;
    *)
        echo "USAGE: pomodoro.sh [type] [duration in minutes]"
      ;;
esac
