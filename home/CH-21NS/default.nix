# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, lib, config, ... }:

{
  # Picom blur and shadow only for this computer.
  services.picom = {
    backend = lib.mkForce "glx";

    shadow = lib.mkForce true;
    settings = {
      blur = {
        method = "dual_kawase";
        strength = 3;
      };
    };
  };

  # Enable battery module on polybar and power script.
  services.polybar.config."bar/main".modules-left = lib.mkForce
    "battery fs mem maxtemp cpu";
  xsession.windowManager.i3.config.startup =
    let
      inherit (import ../lib/gui/scripts.nix { inherit config pkgs lib; })
        powerScript;
    in [ {
      command = "${powerScript}/bin/power.sh"; notification = false;
    } ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
}
