# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, lib, ... }:

{
  # opt in persistence
  environment.etc =
    let
      link = path: { "${path}".source = "/persist/etc/${path}"; };
      paths = [
        "NetworkManager/system-connections"
        "adjtime"
        "machine-id"
      ];
    in builtins.foldl' (x: y: x // y) {} (builtins.map link paths);
  systemd.tmpfiles.rules =
    let
      mkRule = path: "L /${path} - - - - /persist/${path}";
      paths = [
        "var/lib/alsa"
        "var/lib/bluetooth"
        "var/lib/cups"
        "var/lib/docker"
      ];
    in builtins.map mkRule paths;
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

  # make /bin/bash after boot
  boot.postBootCommands = ''
    cat > /bin/bash << EOF
        #!/bin/sh
        /usr/bin/env bash \$@
    EOF
    chmod +x /bin/bash
  '';
}
