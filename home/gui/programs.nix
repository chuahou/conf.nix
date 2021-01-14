# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [

    # development
    gitg
    meld

    # productivity
    gnome3.simple-scan
    pandoc
    pdftk

    # media
    gimp
    minecraft
    obs-studio
    spotify
    vlc

    # communications
    discord
    tdesktop

    # system utilities
    arandr
    baobab
    font-manager

  ];

  services.dropbox.enable   = true;
  services.syncthing.enable = true;
}
