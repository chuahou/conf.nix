# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  services.ratbagd.enable    = true;
  environment.systemPackages = [ pkgs.piper ];
}
