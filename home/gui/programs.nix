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
    galculator
    joplin-desktop
    libreoffice
    pandoc
    pdfgrep
    pdftk
    rclone
    ripgrep

    # media
    feh
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
    arandr
    font-manager
    ncdu
    steam-run

  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http"    = "firefox.desktop";
      "x-scheme-handler/https"   = "firefox.desktop";
      "text/html"                = "firefox.desktop";
      "application/pdf"          = "org.pwmt.zathura.desktop";
    };
  };
}
