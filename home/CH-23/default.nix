# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ pkgs, lib, ... }:

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

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";
}
