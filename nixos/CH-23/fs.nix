# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ ... }:

{
  boot.initrd.luks.devices = {
    crypt.device = "/dev/disk/by-uuid/8e64e1d9-8ae7-4c71-b5c7-092a44f3ecab";
    crypt2.device = "/dev/disk/by-uuid/d578d38e-4969-4195-a681-181720b74e90";
  };

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
        device = "/dev/disk/by-uuid/920D-86A4";
        fsType = "vfat";
      };
    };
}
