# SPDX-License-Identifier: MIT
# Copyright (c) 2023, 2026 Chua Hou

{ pkgs, ... }:

{
  # opt in persistence
  environment.persistence."/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/secureboot"
      "/etc/vmware"
      "/var/lib/AccountsService"
      "/var/lib/alsa"
      "/var/lib/bluetooth"
      "/var/lib/cups"
      "/var/lib/nixos"
      "/var/lib/opensnitch"
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
    ];
  };

  boot.initrd.systemd.services.impermanence-btrfs = rec {
    serviceConfig.Type = "oneshot";
    requiredBy = [ "initrd.target" ];
    before = [ "sysroot.mount" ];
    requires = [ "dev-data-root.device" ];
    after = requires;
    script = /* sh */ ''
      mkdir -p /mnt
      mount /dev/mapper/data-root /mnt
      btrfs sub list -o /mnt/root | gawk '{print $NF}' |
        while read sub; do
          btrfs sub del /mnt/$sub
        done && btrfs sub del /mnt/root
      btrfs sub snap /mnt/root-blank /mnt/root
    '';
  };
  boot.initrd.systemd.extraBin = {
    "mkdir" = "${pkgs.coreutils}/bin/mkdir";
    "btrfs" = "${pkgs.btrfs-progs}/bin/btrfs";
    "gawk" = "${pkgs.gawk}/bin/gawk";
  };

  # Mark /persist and /var/log needed for boot for logs to persist correctly.
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
