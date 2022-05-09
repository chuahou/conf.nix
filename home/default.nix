# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ overlays ? [], host }: { config, pkgs, ... }:

{
  imports = builtins.concatMap (import ../lib {}).importFolder [
    ./core
    ./gui
    ./misc
  ] ++ [ ./${host} ];

  # basic settings
  programs.home-manager.enable = true;
  home.sessionVariables = import ./lib/shell/vars.nix { inherit pkgs; };

  # import overlays from flakes
  nixpkgs.overlays = overlays;

  # allow unfree
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true); # temp workaround, HM#2942
}
