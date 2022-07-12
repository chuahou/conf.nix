# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  boot.initrd.luks.devices = {
    crypt1.device = "/dev/disk/by-uuid/15c226ae-d5f3-4afd-8b43-1b3578211dd5";
    crypt2.device = "/dev/disk/by-uuid/2f2bd65d-ce32-430f-b3df-8ad2f90f8f77";
    hd.device = "/dev/disk/by-uuid/2c436305-2e18-4df9-903e-4b7fc5211fe7";
  };

  fileSystems =
    let
      commonOpts = [ "noatime" "space_cache" "commit=120" "compress=zstd" ];
      btrfsFs = subvol: {
        device  = "/dev/mapper/data-root";
        fsType  = "btrfs";
        options = [
          "device=/dev/mapper/home-home" # 2nd device.
          "device=/dev/mapper/data-swap" # 3rd device.
          ("subvol=" + subvol)
          "ssd"
        ] ++ commonOpts;
      };
      inherit ((import ../../lib/me.nix).home) homeDirectory devDirectory;
    in {
      "/"        = btrfsFs "root";
      "/nix"     = btrfsFs "nix";
      "/persist" = btrfsFs "persist";
      "/var/log" = btrfsFs "log";
      "/home"    = btrfsFs "home";

      # Hard drive subvolumes. /hd is the main partition.
      "/hd" = {
        device = "/dev/mapper/hd-hd";
        fsType = "btrfs";
        options = commonOpts;
      };
      "${homeDirectory}/.dropbox-hm" = {
        device = "/dev/mapper/hd-hd";
        fsType = "btrfs";
        options = [ "subvol=dropbox-hm" ] ++ commonOpts;
      };
      "${devDirectory}/nixpkgs" = {
        device = "dev/mapper/hd-hd";
        fsType = "btrfs";
        options = [ "subvol=dev-nixpkgs" ] ++ commonOpts;
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/F787-F54F";
        fsType = "vfat";
      };
    };
}
