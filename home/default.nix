# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ overlays ? [] }: { config, pkgs, ... }:

{
  imports = builtins.concatMap (import ../lib).importFolder [
    ./core
    ./gui
    ./misc
  ];

  # basic settings
  programs.home-manager.enable = true;
  home = {
    sessionVariables = import ./lib/shell/vars.nix;
  };

  # import overlays from flakes
  nixpkgs.overlays = overlays;

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
