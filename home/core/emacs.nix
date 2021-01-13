# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  programs.emacs = {
    enable        = true;
    package       = pkgs.emacs-nox;
    extraPackages = epkgs: with epkgs; [ evil evil-org ];
  };

  home.file.".emacs".source = ../res/emacs.el;
}
