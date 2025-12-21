# SPDX-License-Identifier: MIT
# Copyright (c) 2022, 2025 Chua Hou

{ ... }:

{
  virtualisation.libvirtd.enable = true;
  users.users.user.extraGroups = [ "libvirtd" ];
  programs.virt-manager.enable = true;

  virtualisation.podman.enable = true;

  services.flatpak.enable = true;
}
