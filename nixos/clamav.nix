# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ ... }:

{
  imports = [ ../modules/clamav.nix ];
  services.clamav-regular-scan.enable = true;
}
