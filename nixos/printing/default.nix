# SPDX-License-Identifier: ???
# Copyright (c) 2021 Chua Hou

{ ... }:

let cupsPort = 65432;
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
  virtualisation.podman.enable = true;
}
