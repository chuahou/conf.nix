# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, lib, ... }:

{
  # opt in persistence
  environment.etc = {
    "NetworkManager/system-connections".source =
      "/persist/etc/NetworkManager/system-connections";
    adjtime.source              = "/persist/etc/adjtime";
  };
  systemd.tmpfiles.rules = [
    "L /var/lib/alsa      - - - - /persist/var/lib/alsa"
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    "L /var/lib/cups      - - - - /persist/var/lib/cups"
  ];
  security.sudo.extraConfig = "Defaults lecture = never";

  # make root blank on boot
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    mkdir -p /mnt
    mount /dev/mapper/data-root /mnt
    btrfs sub list -o /mnt/root | awk '{print $NF}' |
      while read sub; do
        btrfs sub del /mnt/$sub
      done && btrfs sub del /mnt/root
    btrfs sub snap /mnt/root-blank /mnt/root
    umount /mnt
  '';
}
