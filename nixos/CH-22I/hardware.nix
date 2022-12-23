# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, lib, inputs, modulesPath, ... }:

{
  # Generated configuration.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    # nixos-hardware tweaks
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  boot.initrd.availableKernelModules = [
    "ahci" "xhci_pci" "nvme" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Basic hardware services.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.xserver.libinput.enable = true; # Touchpad support.
  hardware.bluetooth.enable = true;

  # Default CPU power management.
  powerManagement = {
    cpuFreqGovernor = "performance";
    cpufreq.max     = 1800000;
  };

  # Update CPU microcode.
  hardware.cpu.amd.updateMicrocode = true;

  # Enable TLP.
  services.tlp.enable = true;

  # Enable zram swap.
  zramSwap.enable = true;
}
