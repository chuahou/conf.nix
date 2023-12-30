# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou

{ config, pkgs, osConfig, ... }:

{
  imports = builtins.concatMap (import ../lib {}).importFolder [
    ./core
    ./gui
    ./misc
  ] ++ [ ./${osConfig.networking.hostName} ];

  # basic settings
  home.sessionVariables = import ./lib/shell/vars.nix { inherit pkgs; };
}
