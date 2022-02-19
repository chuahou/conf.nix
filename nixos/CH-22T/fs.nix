# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ ... }:

{
  boot.initrd.luks.devices.crypt.device =
    "/dev/disk/by-uuid/fc5767d6-0635-4e4b-a5b7-7a760737a6e3";

  fileSystems =
    let btrfsFs = subvol: {
      device = "/dev/mapper/data-root";
      fsType = "btrfs";
      options = [
        ("subvol=" + subvol)
        "noatime" "ssd" "space_cache=v2" "commit=120" "compress=zstd"
      ];
    };
    in {
      "/" = btrfsFs "root";
      "/home" = btrfsFs "home";
      "/nix" = btrfsFs "nix";
      "/persist" = btrfsFs "persist";
      "/var/log" = btrfsFs "log";

      "/boot" = {
        device = "/dev/disk/by-uuid/B752-510A";
        fsType = "vfat";
      };
    };

  swapDevices = [ { device = "/dev/mapper/data-swap"; } ];
}
