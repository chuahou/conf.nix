# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [

    # development
    cfgeq
    gitg
    meld

    # productivity
    anki-bin
    galculator
    gnome.simple-scan
    joplin-desktop
    libreoffice
    pandoc
    pdfgrep
    pdftk
    rclone
    ripgrep
    zotero

    # media
    feh
    (gimp-with-plugins.override {
      plugins = with gimpPlugins; [ resynthesizer ];
    })
    obs-studio
    spotify
    kdenlive
    vlc

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
