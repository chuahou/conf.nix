# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ inputs, modulesPath, ... }:

{
  # Generated configuration.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    # nixos-hardware tweaks
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];
  boot.initrd.availableKernelModules = [
    "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules        = [ "kvm-intel" ];
  boot.extraModulePackages  = [ ];

  # Basic hardware services.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.xserver.libinput.enable = true; # Touchpad support.
  hardware.bluetooth.enable = true;

  # Default CPU power management.
  powerManagement = {
    cpuFreqGovernor = "performance";
    cpufreq.max     = 4500000;
  };

  # Update CPU microcode.
  hardware.cpu.intel.updateMicrocode = true;

  # Enable TLP.
  services.tlp.enable = true;

  # Currently X11 coredumps otherwise for some reason. Not the same error logs,
  # but the same fix works.
  # https://github.com/NixOS/nixpkgs/issues/170856
  boot.kernelParams = [ "nouveau.modeset=0" ];

  # NVIDIA setup.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };
}
