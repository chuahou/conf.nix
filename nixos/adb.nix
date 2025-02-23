# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Chua Hou

{ pkgs, ... }:

{
  imports = [ ../modules/uid-isolation.nix ];

  programs.adb.enable = true;
  users.users.dev.extraGroups = [ "adbusers" ];
  security.uid-isolation.programs = [
    {
      inputDerivation = pkgs.android-studio;
      binaryName = "android-studio";
      user = { name = "dev"; uid = 2005; };
    }
  ];
}
