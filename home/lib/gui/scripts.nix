# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Common scripts for GUI actions

{ config, pkgs }:

rec {
  xconfigScript =
    let
      xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
      xset   = "${pkgs.xorg.xset}/bin/xset";
      xinput = "${pkgs.xorg.xinput}/bin/xinput";
    in
      pkgs.writeShellScriptBin "xconfig.sh" ''
        # force full composition pipeline for nvidia to prevent tearing
        nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"

        # check if external monitor connected to HDMI-0
        if [ $(${xrandr} -q | grep -c "HDMI-0 connected") -gt 0 ]; then
          # turn off eDP-1-1 and connect only to HDMI-0
          ${xrandr} --output HDMI-0 --auto --primary --output eDP-1-1 --off
        else
          ${xrandr} --output eDP-1-1 --auto --primary --output HDMI-0 --off
        fi

        # disable mouse acceleration
        ${xset} mouse 0 0
        for mouse in $(${xinput} --list | sed -n 's/^.*[Mm]ouse.*id=\([0-9]\+\).*$/\1/p')
        do
          if [ $(${xinput} list-props $mouse | \
            grep -c "libinput Accel Profile Enabled") -ge 1 ]; then
            ${xinput} set-prop $mouse "libinput Accel Profile Enabled" 0 1
          fi
        done

        # disable X power saving
        ${xset} s off -dpms

        # disable stream restore module if loaded
        [ $(pactl list short modules | grep module-stream-restore -c || true) -gt 0 ] &&
          pactl unload-module module-stream-restore
      '';

  lockScript =
    let
      picPath      = "${config.xdg.dataHome}/lock.sh";
      scrot        = "${pkgs.scrot}/bin/scrot";
      convert      = "${pkgs.imagemagick7}/bin/convert";
      i3lock       = "${pkgs.i3lock}/bin/i3lock";
      dndScriptBin = "${dndScript ""}/bin/donotdisturb.sh";
    in
      pkgs.writeShellScriptBin "lock.sh" ''
        set -e
        mkdir -p ${picPath}
        ${scrot} ${picPath}/screen.png
        ${convert} ${picPath}/screen.png -blur 0x15 ${picPath}/blur.png
        ${dndScriptBin} on
        ${i3lock} --nofork -i ${picPath}/blur.png "$@"
        ${dndScriptBin} off
        rm ${picPath}/{screen,blur}.png || true
      '';

  volumeScript = pkgs.writeShellScriptBin "volume.sh" ''
    export PATH=${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:${pkgs.gnused}/bin:$PATH
    export PATH=${pkgs.pulseaudio}/bin:$PATH
    ${builtins.readFile ../../res/volume.sh}
  '';

  dndScript =
    let
      killall   = "${pkgs.psmisc}/bin/killall";
      touch     = "${pkgs.coreutils}/bin/touch";
      rm        = "${pkgs.coreutils}/bin/rm";
      stateFile = "${config.xdg.dataHome}/dndenable";
    in
      hook: pkgs.writeShellScriptBin "donotdisturb.sh" ''
        get_status () {
          if [ -f "${stateFile}" ]; then
            echo "do not disturb"
          else
            echo "notif on"
          fi
        }

        dnd_on () {
          ${killall} -SIGUSR1 -r '.*dunst' && ${touch} ${stateFile}
          ${hook}
        }

        dnd_off () {
          ${killall} -SIGUSR2 -r '.*dunst' && ${rm} ${stateFile}
          ${hook}
        }

        toggle () {
          [ -f "${stateFile}" ] && dnd_off || dnd_on
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
      '';
}
