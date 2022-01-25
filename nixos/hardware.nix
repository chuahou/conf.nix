# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  services.xserver.dpi = 96;

  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules        = [ "kvm-intel" ];
  boot.extraModulePackages  = [ ];

  # Allow magic SysRq.
  boot.kernel.sysctl."kernel.sysrq" = 1;

  powerManagement = {
    cpuFreqGovernor = "performance";
    cpufreq.max     = 2000000;
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware         = true;

  services.tlp.enable = true;
}
