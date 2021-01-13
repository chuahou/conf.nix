# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [

    # development
    gitg
    meld

    # productivity
    pandoc
    pdftk

    # media
    gimp
    minecraft
    obs-studio
    vlc

    # communications
    discord
    tdesktop

    # system utilities
    arandr

  ];
}