# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId  = "PCI:0:2:0";
  };

  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules        = [ "kvm-intel" ];
  boot.extraModulePackages  = [ ];

  powerManagement = {
    cpuFreqGovernor = "powersave";
    cpufreq.max     = 2000000;
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableAllFirmware         = true;

  # disable ertm for bluetooth Xbox controller
  boot.extraModprobeConfig = ''
    options bluetooth disable_ertm=1
  '';
}
