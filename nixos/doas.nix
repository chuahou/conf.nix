# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Use doas instead of sudo.

{ pkgs, ... }:

{
  security = {
    sudo.enable = false;

    doas = {
      enable = true;
      extraRules = [

        # Persist password for some time.
        { groups = [ "wheel" ]; noPass = false; persist = true; }

        # Allow passwordless cpufreq-plugin for polybar module to work.
        {
          groups = [ "wheel" ];
          cmd = "${pkgs.cpufreq-plugin-wrapped}/bin/cpufreq-plugin";
          noPass = true;
        }
      ];
    };
  };

  # Make sudo call doas transparently. We use security.wrappers for the sake of
  # setuid, see https://github.com/NixOS/nixpkgs/issues/99101.
  security.wrappers.sudo.source = "${pkgs.doas}/bin/doas";
}
