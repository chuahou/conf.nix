# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ lib, ... }:

{
  imports = [
    ./fs.nix
    ./hardware.nix
    ./persist.nix
    ./printing.nix
  ];

  networking.hostName = "CH-22I";

  # Read DPI.
  services.xserver.dpi = import ../dpi/CH-22I;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}