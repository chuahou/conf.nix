# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  users.users.user.extraGroups = [ "libvirtd" ];
  programs.virt-manager.enable = true;

  virtualisation.podman.enable = true;
}
