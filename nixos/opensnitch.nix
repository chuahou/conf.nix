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
          nolog = false;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            list = [];
          };

          # OpenSnitch iterates rules until a Deny or a Priority rule is
          # matched. Since we do not have any Denys that overlap with Allows, we
          # can simply set all Allows as Priority rules to stop on first match,
          # for better efficiency.
          precedence = true;
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

        asUser = user: {
          operand = "user.id";
          data = toString config.users.users.${user}.uid;
        };
        asRoot = asUser "root";

      in lib.concatMapAttrs mkRule {
        "DNS".operator = mkListOperator [
          { operand = "protocol"; data = "udp"; }
          { operand = "dest.port"; data = "53"; }
          { operand = "dest.ip"; data = "100.64.0.7"; }
        ];
        "[ DENY ] ICMP" = {
          action = "deny";
          operator = { operand = "protocol"; data = "icmp"; };
        };
        "[ DENY ] ICMP6" = {
          action = "deny";
          operator = { operand = "protocol"; data = "icmp6"; };
        };
        "Loopback".operator = { operand = "iface.out"; data = "lo"; };
        "NTP (systemd-timesync)".operator = mkListOperator [
          {
            operand = "process.command";
            data = "${config.systemd.package}/lib/systemd/systemd-timesyncd";
          }
          { operand = "dest.port"; data = "123"; }
          { operand = "protocol"; data = "udp"; }
          (asUser "systemd-timesync")
        ];
        "Nix (root, caches)".operator = mkListOperator [
          { operand = "process.path"; data = "${config.nix.package}/bin/nix"; }
          {
            operand = "dest.host"; type = "regexp";
            data = "^(cache\\.nixos\\.org|chuahou\\.cachix\\.org)$";
          }
          { operand = "dest.port"; data = "443"; }
          { operand = "protocol"; data = "tcp"; }
          asRoot
        ];
        "Nix (user, GitHub)".operator = mkListOperator [
          { operand = "process.path"; data = "${config.nix.package}/bin/nix"; }
          {
            operand = "dest.host"; type = "regexp";
            data = "^.*github\\.com$";
          }
          { operand = "dest.port"; data = "443"; }
          { operand = "protocol"; data = "tcp"; }
          (asUser "user")
        ];
        "Firefox (HTTP, HTTPS, QUIC)".operator = mkListOperator [
          {
            operand = "process.command";
            data = "${pkgs.firefox}/bin/.firefox-wrapped";
          }
          {
            operand = "dest.port"; type = "regexp";
            data = "^(80|443)$";
          }
          (asUser "firefox")
        ];
        "NetworkManager DHCPv6".operator = mkListOperator [
          {
            operand = "process.command";
            data = "${pkgs.networkmanager}/sbin/NetworkManager --no-daemon";
          }
          { operand = "dest.port"; data = "547"; }
          { operand = "dest.ip"; data = "ff02::1:2"; }
          { operand = "protocol"; data = "udp6"; }
          asRoot
        ];
        "Syncthing".operator = mkListOperator [
          {
            operand = "process.path";
            data = "${pkgs.syncthing}/bin/syncthing";
          }
          { operand = "dest.ip"; data = "10.3.0.1"; }
          { operand = "dest.port"; data = "59143"; }
          { operand = "protocol"; data = "tcp"; }
          (asUser "user")
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
          {
            operand = "process.command"; type = "regexp";
            data = "^/run/current-system/sw/bin/ssh( -o sendenv=git_protocol|) [^ ]+ git-(receive|upload)-pack '[^ ']+'$";
          }
          { operand = "dest.port"; data = "22"; }
          { operand = "dest.host"; data = "github.com"; }
          { operand = "protocol"; data = "tcp"; }
          (asUser "user")
        ];
        "Telegram (HTTP, HTTPS)".operator = mkListOperator [
          # Telegram connects to too many different domains and IPs (instead of
          # domains) to keep track practically... So we let it access all of
          # port 443.
          {
            operand = "process.path";
            data = "${pkgs.telegram-desktop}/bin/.telegram-desktop-wrapped";
          }
          { operand = "dest.port"; type = "regexp"; data = "^(80|443)$"; }
          (asUser "telegram")
        ];
        "Discord (HTTPS)".operator = mkListOperator [
          # Discord connects to too many different domains and IPs (instead of
          # domains) to keep track practically... So we let it access all of
          # port 443.
          {
            operand = "process.path";
            data = "${pkgs.discord}/opt/Discord/.Discord-wrapped";
          }
          { operand = "dest.port"; data = "443"; }
          (asUser "discord")
        ];
        "Google Chrome".operator = mkListOperator [
          {
            operand = "process.path";
            data = "${pkgs.google-chrome}/share/google/chrome/chrome";
          }
          (asUser "chrome")
        ];
        "Anki".operator = mkListOperator [
          {
            operand = "process.path"; type = "regexp";
            data = "^/nix/store/[a-z0-9]+-anki-bin-[0-9\\.]+/share/anki/anki$";
          }
          {
            operand = "dest.host"; type = "regexp";
            data = "^(|.*\\.)ankiweb\\.net";
          }
          { operand = "dest.port"; data = "443"; }
          { operand = "protocol"; data = "tcp"; }
          (asUser "user")
        ];
        "Joplin".operator = mkListOperator [
          {
            operand = "process.path"; type = "regexp";
            data = "/nix/store/[^ ]+/@joplinapp-desktop";
          }
          { operand = "dest.host"; data = "api.joplincloud.com"; }
          { operand = "dest.port"; data = "443"; }
          { operand = "protocol"; data = "tcp"; }
          (asUser "joplin")
        ];
        "Bitwarden".operator = mkListOperator [
          {
            operand = "dest.host"; type = "regexp";
            data = "^(.*)\\.bitwarden\\.(com|net)$";
          }
          (asUser "bitwarden")
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
