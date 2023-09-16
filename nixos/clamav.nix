# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# Regularly update the signature database and make clamav available for
# on-demand scanning.

{ pkgs, ... }:

{
  services.clamav.updater = {
    enable = true;
    interval = "daily";
    frequency = 1;
  };
  environment.systemPackages = with pkgs; [ clamav ];
}
