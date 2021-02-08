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
    drivers = [ pkgs.hplipWithPlugin ];
  };
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
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

  environment.systemPackages = [
    # script to rebuild image
    (pkgs.writeShellScriptBin "rebuild-printers" ''
      if [ "$EUID" -ne 0 ]; then echo "Run as root"; exit 1; fi
      ${pkgs.podman}/bin/podman build -t printing \
          --build-arg BRPRINTER_IP=${brPrinterIp} \
          --build-arg HPPRINTER_IP=${hpPrinterIp} \
          ${(import ../../lib {}).me.home.confDirectory + "/nixos/printing"}
    '')

    # scripts to switch CUPS server and setup hp-setup if necessary
    # 'scanmode' to switch to localhost:631 for scanning
    # 'printmode' to switch to localhost:${cupsPort} for printing
    (pkgs.writeShellScriptBin "scanmode" ''
      pingcups
      [ -f /var/lib/cups/client.conf ] \
          && sudo mv /var/lib/cups/client.conf{,.tmp} \
          || true
      lpstat -v | grep ${hpPrinterIp} \
          || cat | sudo hp-setup -i ${hpPrinterIp} << EOF
      ${builtins.readFile ./hp-setup.response}
      EOF
    '')
    (pkgs.writeShellScriptBin "printmode" ''
      pingcups
      [ -f /var/lib/cups/client.conf.tmp ] \
          && sudo mv /var/lib/cups/client.conf{.tmp,} \
          || true
    '')

    # initialize cups by pinging server
    # Due to our / erasure, /var/lib/cups/* et al are not initialized before the
    # first request to the server
    (pkgs.writeShellScriptBin "pingcups" ''
      curl localhost:631 > /dev/null
      curl localhost:${toString cupsPort} > /dev/null
    '')
  ];

  # override timeout
  systemd.services.podman-printing.serviceConfig = {
    TimeoutStopSec = lib.mkForce 10;
    ExecStop =
      lib.mkForce "${config.system.path}/bin/podman stop -i -t 5 printing";
  };
}
