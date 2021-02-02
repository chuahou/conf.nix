# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable        = true;
    package       = pkgs.emacs-nox;
    extraPackages = epkgs: with epkgs; [ evil evil-org org-gcal ];
  };

  home.file.".emacs".text = ''
    ${builtins.readFile ../res/emacs.el}
    (setq org-gcal-client-id     "${pkgs.secrets.org-gcal.clientId}"
          org-gcal-client-secret "${pkgs.secrets.org-gcal.clientSecret}")
  '';
}
