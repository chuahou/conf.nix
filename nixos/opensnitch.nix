# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ config, pkgs, lib, ... }:

let
  user = {
    name = "opensnitch";
    uid = 3000;
  };

in {
  services.opensnitch = {
    enable = true;
    settings = {
      InterceptUnknown = true;
      Firewall = "iptables";

      # Only allow separate user to access socket.
      Server.Address = "unix:///${config.users.users.${user.name}.home}/osui.sock";

      # Default actions when UI not connected.
      DefaultDuration = "30s";
      DefaultAction = "deny";
    };

    # Custom rules that should apply to every host that has this configuration
    # applied. Many paths are hardcoded using ${pkgs.[...]}/bin/[...], which
    # means that it does take into account overlays but not cases where the
    # installed package is different from what's available in overlayed ${pkgs}.
    # This is fine as any such discrepancies will be flagged as disallowed
    # behaviour by OpenSnitch, and we can deal with that then. Likewise for user
    # IDs.
    rules =
      let

        # Default configuration for each rule, to be recursively overridden.
        defaultConfig = {
          created = "1970-01-01T00:00:00.000000000+00:00";
          updated = "1970-01-01T00:00:00.000000000+00:00";
          enabled = true;
          description = "";
          precedence = false;
          nolog = false;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            list = [];
          };
        };

        # Function that labels and adds default config below each rule.
        mkRule = n: v: let name = "(nix) ${n}"; in {
          ${name} = lib.recursiveUpdate defaultConfig v
              // { inherit name; };
        };

        # Function that creates list type operator, filling in both the
        # operator.data and operator.list fields, as well as including default
        # operand element rules.
        mkListOperator = operandList: rec {
          type = "list";
          operand = "list";
          sensitive = false;
          list = map
            (x: { type = "simple"; sensitive = false; list = null; } // x)
            operandList;
          data = builtins.toJSON list;
        };

      in lib.concatMapAttrs mkRule {
        "DNS".operator = mkListOperator [
          { operand = "protocol"; data = "udp"; }
          { operand = "dest.port"; data = "53"; }
          {
            operand = "dest.ip"; type = "regexp";
            data = "^(10\\.3\\.0\\.1|10\\.64\\.0\\.1)$";
          }
        ];
        "[ DENY ] ICMP" = {
          action = "deny";
          operator = {
            operand = "protocol";
            data = "icmp";
          };
        };
        "Loopback".operator = {
          operand = "iface.out";
          data = "lo";
        };
        "NTP (systemd-timesync)".operator = mkListOperator [
          {
            operand = "process.path";
            data = "${config.systemd.package}/lib/systemd/systemd-timesyncd";
          }
          {
            operand = "process.command";
            data = "${config.systemd.package}/lib/systemd/systemd-timesyncd";
          }
          { operand = "dest.port"; data = "123"; }
          { operand = "protocol"; data = "udp"; }
          { operand = "user.id"; data = "154"; } # systemd-timesync
        ];
        "Nix (root, caches)".operator = mkListOperator [
          { operand = "process.path"; data = "${config.nix.package}/bin/nix"; }
          {
            operand = "dest.host"; type = "regexp";
            data = "^(cache\\.nixos\\.org|chuahou\\.cachix\\.org)$";
          }
          { operand = "dest.port"; data = "443"; }
          { operand = "protocol"; data = "tcp"; }
          { operand = "user.id"; data = "0"; }
        ];
        "Nix (user, GitHub)".operator = mkListOperator [
          { operand = "process.path"; data = "${config.nix.package}/bin/nix"; }
          {
            operand = "dest.host"; type = "regexp";
            data = "^.*github\\.com$";
          }
          { operand = "dest.port"; data = "443"; }
          { operand = "protocol"; data = "tcp"; }
          {
            operand = "user.id";
            data = "${toString config.users.users.user.uid}";
          }
        ];
        "Firefox (HTTP, HTTPS, QUIC)".operator = mkListOperator [
          {
            operand = "process.path";
            data = "${pkgs.firefox}/lib/firefox/firefox";
          }
          {
            operand = "process.command";
            data = "${pkgs.firefox}/bin/.firefox-wrapped";
          }
          {
            operand = "dest.port"; type = "regexp";
            data = "^(80|443)$";
          }
          { operand = "user.id"; data = "2000"; } # firefox
        ];
        "NetworkManager DHCPv6".operator = mkListOperator [
          {
            operand = "process.path";
            data = "${pkgs.networkmanager}/bin/NetworkManager";
          }
          {
            operand = "process.command";
            data = "${pkgs.networkmanager}/sbin/NetworkManager --no-daemon";
          }
          { operand = "dest.port"; data = "547"; }
          { operand = "dest.ip"; data = "ff02::1:2"; }
          { operand = "protocol"; data = "udp6"; }
          { operand = "user.id"; data = "0"; }
        ];
        "Syncthing".operator = mkListOperator [
          {
            operand = "process.path";
            data = "${pkgs.syncthing}/bin/syncthing";
          }
          {
            operand = "user.id";
            data = "${toString config.users.users.user.uid}";
          }
          { operand = "dest.ip"; data = "10.3.0.1"; }
          { operand = "dest.port"; data = "59143"; }
          { operand = "protocol"; data = "tcp"; }
        ];
        "[ DENY ] Syncthing (data.syncthing.net)" = {
          action = "deny";
          operator = mkListOperator [
            {
              operand = "process.path";
              data = "${pkgs.syncthing}/bin/syncthing";
            }
            { operand = "dest.host"; data = "data.syncthing.net"; }
            # Don't need to filter so stringently, as it is a deny after all.
          ];
        };
        "Git-over-SSH (GitHub)".operator = mkListOperator [
          { operand = "process.path"; data = "${pkgs.openssh}/bin/ssh"; }
          {
            operand = "process.command"; type = "regexp";
            data = "^/run/current-system/sw/bin/ssh( -o sendenv=git_protocol|) [^ ]+ git-(receive|upload)-pack '[^ ']+'$";
          }
          { operand = "dest.port"; data = "22"; }
          { operand = "dest.host"; data = "github.com"; }
          { operand = "protocol"; data = "tcp"; }
          {
            operand = "user.id";
            data = "${toString config.users.users.user.uid}";
          }
        ];
        "Telegram (HTTP, HTTPS)".operator = mkListOperator [
          # Telegram connects to too many different domains and IPs (instead of
          # domains) to keep track practically... So we let it access all of
          # port 443.
          {
            operand = "process.path";
            data = "${pkgs.telegram-desktop}/bin/.telegram-desktop-wrapped";
          }
          { # Regex since can't access wrapped binary path easily.
            operand = "process.command"; type = "regexp";
            data = "^/nix/store/[a-z0-9]+-telegram-desktop-[0-9\\.]+-uid-isolated/bin/.uid-isolation-unwrapped( --|)$";
          }
          { operand = "dest.port"; type = "regexp"; data = "^(80|443)$"; }
          { operand = "user.id"; data = "2001"; } # telegram
        ];
        "Discord (HTTPS)". operator = mkListOperator [
          # Discord connects to too many different domains and IPs (instead of
          # domains) to keep track practically... So we let it access all of
          # port 443.
          {
            operand = "process.path";
            data = "${pkgs.discord}/opt/Discord/.Discord-wrapped";
          }
          { operand = "dest.port"; data = "443"; }
          { operand = "user.id"; data = "2002"; } # discord
        ];
      };
  };

  # Run opensnitch-ui as a separate user, so that other programs running as the
  # default user cannot access opensnitch and modify/bypass it.
  security.uid-isolation.programs = [ {
    inputDerivation = pkgs.opensnitch-ui;
    binaryName = "opensnitch-ui";
    inherit user;
  } ];
}
