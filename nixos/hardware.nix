{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.crypt = {
    device = "/dev/disk/by-uuid/15c226ae-d5f3-4afd-8b43-1b3578211dd5";
  };

  fileSystems =
    let
      btrfsFs = subvol: {
        device = "/dev/mapper/data-root";
        fsType = "btrfs";
        options = [
          ("subvol=" + subvol)
          "noatime" "ssd" "space_cache" "commit=120" "compress=zstd"
        ];
      };
    in
      {
        "/" = btrfsFs "root";
        "/home" = btrfsFs "home";
        "/nix" = btrfsFs "nix";
        "/persist" = btrfsFs "persist";
        "/var/log" = btrfsFs "log";
        "/boot" = {
          device = "/dev/disk/by-uuid/F787-F54F";
          fsType = "vfat";
        };        
      };

  swapDevices = [ { device = "/dev/mapper/data-swap"; } ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
