# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, lib, ... }:

{
  # opt in persistence
  environment.persistence."/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/alsa"
      "/var/lib/bluetooth"
      "/var/lib/cups"
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
    ];
  };
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
