# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, config, lib, ... }:

let
  cupsPort    = 65432;
  brPrinterIp = "192.168.1.138";
  hpPrinterIp = "192.168.1.135";
in {
  # configure to use container's services
  services.printing = {
    enable = true;
    clientConf = ''
      ServerName 127.0.0.1:${toString cupsPort}
    '';
  };
  hardware.sane = {
    enable = true;
  };

  # container configuration
  virtualisation = {
    podman.enable = true;
    oci-containers = {
      backend = "podman";
      containers.printing = {
        image = "localhost/printing";
        ports = [ "${toString cupsPort}:631" ];
      };
    };
  };

  # script to rebuild image
  environment.systemPackages = [ (pkgs.writeShellScriptBin "rebuild-printers" ''
    if [ "$EUID" -ne 0 ]; then echo "Run as root"; exit 1; fi
    ${pkgs.podman}/bin/podman build -t printing \
        --build-arg BRPRINTER_IP=${brPrinterIp} \
        --build-arg HPPRINTER_IP=${hpPrinterIp} \
        ${(import ../../lib {}).me.home.confDirectory + "/nixos/printing"}
  '') ];

  # override timeout
  systemd.services.podman-printing.serviceConfig = {
    TimeoutStopSec = lib.mkForce 10;
    ExecStop =
      lib.mkForce "${config.system.path}/bin/podman stop -i -t 5 printing";
  };
}
