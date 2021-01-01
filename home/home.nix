# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, ... }:

{
  imports = builtins.concatMap (import ./lib/lib.nix).importFolder [
    ./core
    ./gui
    ./misc
  ];

  # basic settings
  programs.home-manager.enable = true;
  home = {
    inherit ((import ./lib/me.nix).home) username homeDirectory;
    sessionVariables = import ./lib/shell/vars.nix;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
