# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];
  users.users.user.extraGroups = [ "libvirtd" ];
}
