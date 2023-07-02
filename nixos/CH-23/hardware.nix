# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ inputs, pkgs, modulesPath, ... }:

{
  # Generated configuration.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules        = [ "kvm-amd" ];
  boot.extraModulePackages  = [ ];
  boot.kernelPackages = pkgs.linuxPackages_6_3;

  # Basic hardware services.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  # Default CPU power management.
  powerManagement = {
    cpuFreqGovernor = "performance";
    cpufreq.max     = 4500000;
  };

  # Update CPU microcode.
  hardware.cpu.amd.updateMicrocode = true;

  # Enable zram swap.
  zramSwap.enable = true;
}
