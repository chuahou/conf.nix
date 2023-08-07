# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ inputs, pkgs, modulesPath, ... }:

{
  # Generated configuration.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    # Surface things.
    inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
  ];
  boot.initrd.availableKernelModules = [
    "xhci_pci" "nvme" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules        = [ "kvm-intel" ];
  boot.extraModulePackages  = [ ];

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
  hardware.cpu.intel.updateMicrocode = true;

  # Enable zram swap.
  zramSwap.enable = true;
}
