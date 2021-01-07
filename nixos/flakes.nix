# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  # enable nix flakes
  nix = {
    package      = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };
}
