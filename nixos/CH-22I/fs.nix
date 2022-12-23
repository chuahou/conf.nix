# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ ... }:

{
  boot.initrd.luks.devices.crypt.device =
    "/dev/disk/by-uuid/d6db588b-e012-4cc5-b2c9-9fcf7d7d071e";

  fileSystems =
    let btrfsFs = subvol: {
      device = "/dev/mapper/data-root";
      fsType = "btrfs";
      options = [
        ("subvol=" + subvol)
        "noatime" "ssd" "space_cache=v2" "commit=120" "compress=zstd:1"
      ];
    };
    in {
      "/" = btrfsFs "root";
      "/home" = btrfsFs "home";
      "/nix" = btrfsFs "nix";
      "/persist" = btrfsFs "persist";
      "/var/log" = btrfsFs "log";

      "/boot" = {
        device = "/dev/disk/by-uuid/1AEE-A57B";
        fsType = "vfat";
      };
    };

  swapDevices = [ { device = "/dev/mapper/data-swap"; } ];
}
