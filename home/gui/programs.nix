# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [

    # development
    gitg
    meld

    # productivity
    anki-bin
    libreoffice
    pandoc
    pdfgrep
    pdftk
    qalculate-qt
    rclone
    ripgrep

    # media
    gimp
    spotify

    # video-related
    handbrake
    losslesscut-bin
    obs-studio
    vlc
    yt-dlp

    # system utilities
    appimage-run
    ncdu
    steam-run

  ];
}
