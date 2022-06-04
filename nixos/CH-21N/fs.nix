# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  boot.initrd.luks.devices = {
    crypt.device = "/dev/disk/by-uuid/15c226ae-d5f3-4afd-8b43-1b3578211dd5";
    home.device = "/dev/disk/by-uuid/2f2bd65d-ce32-430f-b3df-8ad2f90f8f77";
  };

  fileSystems =
    let btrfsFs = subvol: {
      device  = "/dev/mapper/data-root";
      fsType  = "btrfs";
      options = [
        ("subvol=" + subvol)
        "noatime" "ssd" "space_cache" "commit=120" "compress=zstd"
      ];
    };
    in {
      "/"        = btrfsFs "root";
      "/nix"     = btrfsFs "nix";
      "/persist" = btrfsFs "persist";
      "/var/log" = btrfsFs "log";

      "/home" = {
        device = "/dev/mapper/home-home";
        fsType = "btrfs";
        options = [
          "subvol=home"
          "noatime" "ssd" "space_cache" "commit=120" "compress=zstd"
        ];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/F787-F54F";
        fsType = "vfat";
      };
    };

  swapDevices = [ { device = "/dev/mapper/data-swap"; } ];
}
