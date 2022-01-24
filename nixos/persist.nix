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
      ];
    in builtins.foldl' (x: y: x // y) {} (builtins.map link paths);
  systemd.tmpfiles.rules =
    let
      mkRule = path: "L /${path} - - - - /persist/${path}";
      paths = [
        "var/lib/alsa"
        "var/lib/bluetooth"
        "var/lib/cups"
      ];
    in builtins.map mkRule paths;
  security.sudo.extraConfig = "Defaults lecture = never";

  boot.initrd.postDeviceCommands = lib.mkBefore ''
    # Make root blank on boot.
    mkdir -p /mnt
    mount /dev/mapper/data-root /mnt
    btrfs sub list -o /mnt/root | awk '{print $NF}' |
      while read sub; do
        btrfs sub del /mnt/$sub
      done && btrfs sub del /mnt/root
    btrfs sub snap /mnt/root-blank /mnt/root

    # Make /etc/machine-id available early enough for logs to persist.
    mkdir -p /mnt/root/etc
    ln -s /persist/etc/machine-id /mnt/root/etc/machine-id
    umount /mnt
  '';

  # Mark /persist and /var/log needed for boot for logs to persist correctly.
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

  # make /bin/bash after boot
  boot.postBootCommands = ''
    cat > /bin/bash << EOF
        #!/bin/sh
        /usr/bin/env bash \$@
    EOF
    chmod +x /bin/bash
  '';
}
