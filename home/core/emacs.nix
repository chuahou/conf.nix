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
}
