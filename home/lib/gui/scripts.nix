# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Common scripts for GUI actions

{ config, pkgs, lib }:

rec {
  xconfigScript = pkgs.ch.mkScriptWithDeps {
    deps = with pkgs; [
      xorg.xrandr xorg.xset xorg.xinput xorg.xmodmap
      gnugrep gnused pulseaudio nix
    ];
    infile = ../../res/scripts/xconfig.sh;
  };

  lockScript =
    let picPath = "${config.xdg.dataHome}/lock.sh";
    in pkgs.writeShellScriptBin "lock.sh" ''
      set -e
      mkdir -p ${picPath}
      ${pkgs.ch.addToPath (with pkgs; [ scrot imagemagick i3lock dndScript ])}
      scrot ${picPath}/screen.png
      convert ${picPath}/screen.png -blur 0x15 ${picPath}/blur.png
      donotdisturb.sh on
      i3lock --nofork -i ${picPath}/blur.png "$@"
      donotdisturb.sh off
      rm ${picPath}/{screen,blur}.png || true
    '';

  volumeScript = pkgs.ch.mkScriptWithDeps {
    deps   = with pkgs; [ gnugrep gawk gnused pulseaudio ];
    infile = ../../res/scripts/volume.sh;
  };

  dndScript =
    let
      stateFile = "${config.xdg.dataHome}/dndenable";
      cfg       = config.services.polybar;
    in pkgs.writeShellScriptBin "donotdisturb.sh" ''
      set -eu

      ${pkgs.ch.addToPath (with pkgs; [ coreutils libnotify psmisc ])}

      state_file=${stateFile}
      hook () {
        ${if builtins.hasAttr "module/dnd_ipc" cfg.config
          then
            ''
              ${cfg.package}/bin/polybar-msg action dnd_ipc hook.0
            ''
          else ""}
      }

      ${builtins.readFile ../../res/scripts/donotdisturb.sh}
    '';

  powerScript = pkgs.writeShellScriptBin "power.sh" ''
    ${pkgs.ch.mkPath (with pkgs; [
      coreutils gnugrep gnused libnotify pulseaudio upower systemd
    ])}
    AUDIO_FILE=${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/phone-incoming-call.oga
    ${builtins.readFile ../../res/scripts/power.sh}
  '';
}
