# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ ... }:

{
  boot.initrd.luks.devices.crypt.device = "/dev/disk/by-uuid/3f9e29d8-3c31-446e-958f-5337c99d0c1b";

  fileSystems =
    let
      btrfsFs = subvol: {
        device  = "/dev/mapper/data-root";
        fsType  = "btrfs";
        options = [
          ("subvol=" + subvol)
          "ssd" "noatime" "space_cache=v2" "commit=120" "compress-force=zstd"
        ];
      };

    in {
      "/"        = btrfsFs "root";
      "/nix"     = btrfsFs "nix";
      "/persist" = btrfsFs "persist";
      "/var/log" = btrfsFs "log";
      "/home"    = btrfsFs "home";

      "/boot" = {
        device = "/dev/disk/by-uuid/4B8D-3445";
        fsType = "vfat";
      };
    };

  swapDevices = [ { device = "/dev/mapper/data-swap"; } ];
}
