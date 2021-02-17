# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable          = true;
  environment.systemPackages     = [ pkgs.virt-manager ];
  users.users.user.extraGroups   = [ "libvirtd" ];
}
