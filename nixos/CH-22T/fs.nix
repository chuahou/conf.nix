# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ ... }:

{
  boot.initrd.luks.devices.crypt.device =
    "/dev/disk/by-uuid/e038ea8f-2a40-46b5-a812-94144c1fd089";

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
        device = "/dev/disk/by-uuid/1838-9F62";
        fsType = "vfat";
      };
    };

  swapDevices = [ { device = "/dev/mapper/data-swap"; } ];
}
