# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# Runs clamav scans regularly.

{ config, lib, pkgs, ... }:

{
  options.services.clamav-regular-scan = {
    enable = lib.mkEnableOption "clamav-regular-scan";
    targetFolder = lib.mkOption {
      description = "Folder to scan regularly.";
      type = lib.types.path;
      default = "/";
    };
    onCalendar = lib.mkOption {
      description = "OnCalendar systemd setting for how often/when to scan.";
      type = lib.types.str;
      default = "hourly";
      example = "daily";
    };
    clamscanOptions = lib.mkOption {
      description = "Options for clamscan.";
      type = lib.types.str;
      default = "-ri --exclude-dir=/proc --exclude-dir=/sys --exclude-dir=/dev";
      example = "-ri";
    };
    alertCommand = lib.mkOption {
      description = "Command to run when infected file is detected.";
      type = lib.types.str;
      # Taken from
      # https://discourse.nixos.org/t/clamav-setup-onaccessscan/29682.
      default = "${pkgs.writeShellScript "clamav-notify-alert" /* sh */ ''
        for ADDRESS in /run/user/*; do
            USERID=''${ADDRESS#/run/user/}
            /run/wrappers/bin/sudo -u "#$USERID" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS/bus" \
                ${pkgs.libnotify}/bin/notify-send -i dialog-warning \
                    'clamav-regular-scan' 'Infected file(s) located!'
        done
      ''}";
    };
    unalertCommand = lib.mkOption {
      description = "Command to run when no infected files are detected.";
      type = lib.types.str;
      default = "/bin/sh -c :";
    };
    preCommand = lib.mkOption {
      description = "Command to run before starting scan.";
      type = lib.types.str;
      default = "/bin/sh -c :";
    };
  };

  config = let cfg = config.services.clamav-regular-scan; in lib.mkIf cfg.enable {
    services.clamav.updater.enable = true; # freshclam.

    # Service that runs the regular clamav scan, and notifies all logged-in
    # users via notify-send if an infected file is detected or some error
    # occurs.
    systemd = {
      services.clamav-regular-scan = {
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = cfg.preCommand;
          ExecStart = pkgs.writeShellScript "clamav-regular-scan" /* sh */ ''
          ${pkgs.clamav}/bin/clamscan ${cfg.clamscanOptions} ${cfg.targetFolder} \
              && ${cfg.unalertCommand} || ${cfg.alertCommand}
          '';
        };
        wants = [ "clamav-freshclam.service" ];
        after = [ "clamav-freshclam.service" ];
      };
      timers.clamav-regular-scan = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.onCalendar;
          Unit = "clamav-regular-scan.service";
        };
      };
    };
  };
}
