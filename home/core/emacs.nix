# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable        = true;
    package       = pkgs.emacs-nox;
    extraPackages = epkgs: with epkgs; [ evil evil-org ];
  };

  home.file.".emacs".source = ../res/emacs.el;

  # systemd timer unit to run gcal script every 5 minutes
  systemd.user =
    let name = "org-gcal";
    in {
      services.${name} = {
        Service = {
          Type      = "oneshot";
          ExecStart = "${pkgs.writeShellScript "org-gcal-systemd" ''
            ${(import ../../lib { inherit lib; }).mkPath (with pkgs; [
              bash curl gawk
            ])}
            ${config.home.homeDirectory}/org/gcal/gcal.sh
          ''}";
        };
      };
      timers.${name} = {
        Timer = {
          OnUnitActiveSec = 5 * 60;
          OnBootSec       = 0;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
}
