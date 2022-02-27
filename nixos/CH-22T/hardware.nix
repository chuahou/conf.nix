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
  # We manually write YAML file since the generator generates things out of
  # order which seems to create some issues...
  boot.extraModprobeConfig = "options thinkpad_acpi fan_control=1";
  services.thinkfan.enable = true;
  systemd.services.thinkfan.environment.THINKFAN_ARGS = lib.mkForce
    "-b-10 -c ${pkgs.writeTextFile {
      name = "thinkfan.yaml";
      text = ''
        sensors:
          - hwmon: /sys/class/hwmon
            name: coretemp
            indices: [ 1, 2, 3 ]
          - hwmon: /sys/devices/platform/thinkpad_hwmon/hwmon
            indices: [ 1 ]
          - tpacpi: /proc/acpi/ibm/thermal
            indices: [ 0 ]
          - hwmon: /sys/devices/pci0000:00/0000:00:1d.2/0000:3e:00.0/hwmon
            indices: [ 1 ]
        fans:
          - tpacpi: /proc/acpi/ibm/fan
        levels:
          - speed: 0
            upper_limit: [ 65, 65, 65, 65, 65, 30 ]
          - speed: 1
            lower_limit: [ 57, 57, 57, 57, 57, 28 ]
            upper_limit: [ 70, 70, 70, 70, 70, 30 ]
          - speed: 2
            lower_limit: [ 50, 50, 50, 50, 50, 28 ]
            upper_limit: [ 75, 75, 75, 75, 75, 30 ]
          - speed: level auto
            lower_limit: [ 55, 55, 55, 55, 55, 28 ]
            upper_limit: [ 80, 80, 80, 80, 80, 30 ]
          - speed: 7
            lower_limit: [ 75, 75, 75, 75, 75, 28 ]
            upper_limit: [ 255, 255, 255, 255, 255, 255 ]
      '';
    }}";
}
