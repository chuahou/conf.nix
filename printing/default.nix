# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

let
  cupsPort    = 65432;
  brPrinterIp = "192.168.1.138";
  hpPrinterIp = "192.168.1.135";
in {
  nixosModule = { ... }:
  {
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
    virtualisation.podman.enable = true;
  };

  hmModule = { pkgs, lib, ... }:
  {
    xsession.initExtra = lib.mkAfter ''
      ${pkgs.writeShellScript "podman-printing-init" ''
        PATH=${pkgs.podman}/bin

        # build image if not present
        podman image exists localhost/printing \
            || podman build -t printing \
                --build-arg BRPRINTER_IP=${brPrinterIp} \
                --build-arg HPPRINTER_IP=${hpPrinterIp} \
                --squash \
                ${(import ../lib {}).me.home.confDirectory + "/printing"}

        # remove existing container if present
        podman container exists printing \
            && podman stop printing \
            && podman container rm printing
        podman run --rm=true -it --name printing \
            -p ${toString cupsPort}:631 \
            localhost/printing
      ''} & disown
    '';
  };
}
