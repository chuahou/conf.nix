# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ config, pkgs, ... }:

{
  imports = [ ../modules/uid-isolation.nix ];

  security.uid-isolation = {
    programs = [
      {
        inputDerivation = pkgs.tdesktop;
        binaryName = "telegram-desktop";
        user = { name = "telegram"; uid = 2001; };
      }
      {
        inputDerivation = pkgs.discord;
        binaryName = "Discord";
        user = { name = "discord"; uid = 2002; };
      }
      {
        inputDerivation = pkgs.bitwarden;
        binaryName = "bitwarden";
        user = { name = "bitwarden"; uid = 2003; };
      }
    ];
    normalUser = config.users.users.user.name;
  };
}
