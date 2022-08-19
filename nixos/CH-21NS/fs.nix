# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  boot.initrd.luks.devices.crypt.device = "/dev/disk/by-uuid/cffd7df6-2638-4aab-977c-99f4ee097312";

  fileSystems =
    let
      btrfsFs = subvol: {
        device  = "/dev/mapper/data-root";
        fsType  = "btrfs";
        options = [
          ("subvol=" + subvol)
          "ssd" "noatime" "space_cache=v2" "commit=120" "compress=zstd"
        ];
      };

    in {
      "/"        = btrfsFs "root";
      "/nix"     = btrfsFs "nix";
      "/persist" = btrfsFs "persist";
      "/var/log" = btrfsFs "log";
      "/home"    = btrfsFs "home";

      "/boot" = {
        device = "/dev/disk/by-uuid/5A43-4598";
        fsType = "vfat";
      };
    };
}
