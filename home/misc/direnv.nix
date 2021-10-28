# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# direnv integration for nix-shells

{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable       = true;
      enableFlakes = true;
    };
  };
}
