# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou

{ config, pkgs, osConfig, ... }:

let
  # Import entire folder's expressions.
  importFolder = folder:
    builtins.map (file: folder + "/${file}")
      (builtins.attrNames (builtins.readDir folder));

in {
  imports = builtins.concatMap importFolder [
    ./core
    ./gui
    ./misc
  ] ++ [ ./${osConfig.networking.hostName} ];

  # basic settings
  home.sessionVariables = import ./lib/shell/vars.nix { inherit pkgs; };
}
