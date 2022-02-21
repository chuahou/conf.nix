# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ inputs, modulesPath, ... }:

{
  # Generated configuration.
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    # nixos-hardware tweaks
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t470s
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci" "nvme" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Basic hardware services.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.xserver.libinput.enable = true; # Touchpad support.
  hardware.bluetooth.enable = true;

  # Default CPU power management.
  powerManagement = {
    cpuFreqGovernor = "performance";
    cpufreq.max     = 3000000;
  };

  # Update CPU microcode.
  hardware.cpu.intel.updateMicrocode = true;

  # Enable TLP.
  services.tlp.enable = true;

  # Thinkfan config.
  boot.extraModprobeConfig = "options thinkpad_acpi fan_control=1";
  services.thinkfan = {
    enable = true;
    sensors = [
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "coretemp";
        indices = [ 1 2 3 ];
      }
      {
        type = "tpacpi";
        query = "/proc/acpi/ibm/thermal";
        indices = [ 0 ];
      }
    ];
    fans = [
      {
       type = "tpacpi";
       query = "/proc/acpi/ibm/fan";
      }
    ];
    levels = [
      [ 0 0 45 ]
      [ "level auto" 45 80 ]
      [ "level full-speed" 75 255 ]
    ];
  };
}
