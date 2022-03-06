# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, lib, inputs, modulesPath, ... }:

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
    extraArgs = [ "-b-10" ];
    sensors = [
      {
        type = "hwmon";
        query = "/sys/class/hwmon";
        name = "coretemp";
        indices = [ 1 2 3 ];
      }
      {
        type = "hwmon";
        query = "/sys/devices/platform/thinkpad_hwmon/hwmon";
        indices = [ 1 ];
      }
      {
        type = "tpacpi";
        query = "/proc/acpi/ibm/thermal";
        indices = [ 0 ];
      }
      { # NVME drive.
        type = "hwmon";
        query = "/sys/devices/pci0000:00/0000:00:1d.2/0000:3e:00.0/nvme/nvme0/hwmon0";
        indices = [ 1 ];
        correction = [ 25 ]; # Generous correction since it does not heat up
                             # much typically.
      }
    ];
    fans = [
      {
        type = "tpacpi";
        query = "/proc/acpi/ibm/fan";
      }
    ];
    levels = let a = "level auto"; in [
      [ 0   0  65 ]
      [ 1  57  70 ]
      [ 2  50  75 ]
      [ a  55  80 ]
      [ 7  75 255 ]
    ];
  };
}
