# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ overlays ? [], host, home }: { config, pkgs, ... }:

{
  imports = builtins.concatMap (import ../lib {}).importFolder [
    ./core
    ./gui
    ./misc
  ] ++ [ ./${host} ];

  # basic settings
  programs.home-manager.enable = true;
  home = {
    sessionVariables = import ./lib/shell/vars.nix { inherit pkgs; };
    inherit (home) username homeDirectory;
  };

  # import overlays from flakes
  nixpkgs.overlays = overlays;

  # allow unfree
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true); # temp workaround, HM#2942
}
