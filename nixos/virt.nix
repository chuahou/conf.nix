# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }: {
  # Enable libvirt with virt-manager.
  virtualisation.libvirtd.enable = true;
  environment.systemPackages     = with pkgs; [ virt-manager ];
  users.users.user.extraGroups   = [ "libvirtd" ];

  # Enable nested virtualization.
  boot.extraModprobeConfig = "options kvm-intel nested=Y";
}
