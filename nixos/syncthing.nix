# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ ... }:

let
  # We can't use config.users.users.user due to the Syncthing module trying to
  # set config.users.users as well, leading to infinite recursion.
  user = { name = "sgepk"; group = "users"; home = "/home/sgepk"; };
  port = 59142;

in {
  services.syncthing = {
    enable = true;
    user = user.name;
    group = user.group;
    configDir = "${user.home}/.config/syncthing";
    dataDir = "${user.home}/.local/share/syncthing";

    # Declarative devices/folders.
    overrideDevices = true;
    overrideFolders = true;
    devices.vps = {
      id = "GB64E5G-KBHSVWG-YZN3S35-OTPQUDC-FE2BJCP-RQ66O2X-6AT72C2-BDZEDAW";
      addresses = [ "tcp://10.3.0.1:59143" ];
    };
    folders = {
      "Documents" = {
        path = "${user.home}/doc";
        devices = [ "vps" ];
      };
    };

    # Options using REST API.
    extraOptions = {
      options = {
        listenAddresses = [ "tcp://10.3.0.31:${toString port}" ];
        startBrowser = false;
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
      };
      defaults.folder = {
        versioning = {
          type = "staggered";
          params.maxAge = "0"; cleanupIntervalS = 0; # Keep forever.
        };
      };
    };

  };

  # Open firewall for the relevant port only through WireGuard (set up through
  # NetworkManager.
  networking.firewall.interfaces."wg-vps".allowedTCPPorts = [ port ];
}
