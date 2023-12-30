# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ lib, ... }:

{
  imports = [
    ./fs.nix
    ./hardware.nix
    ./persist.nix
  ];

  networking.hostName = "CH-23MS";

  # Limit journald space usage.
  services.journald.extraConfig = ''
    SystemMaxUse=512M
    MaxRetentionSec=1week
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
