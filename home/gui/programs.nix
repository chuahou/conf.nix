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
    gnome3.simple-scan
    libreoffice
    pandoc
    pdfgrep
    pdftk
    ripgrep

    # media
    feh
    (gimp-with-plugins.override {
      plugins = with gimpPlugins; [ resynthesizer ];
    })
    obs-studio
    spotify
    kdenlive
    vlc

    # communications
    discord
    tdesktop
    teams

    # system utilities
    appimage-run
    arandr
    baobab
    font-manager
    steam-run

  ];

  services.dropbox.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http"    = "firefox.desktop";
      "x-scheme-handler/https"   = "firefox.desktop";
      "x-scheme-handler/msteams" = "teams.desktop";
      "text/html"                = "firefox.desktop";
      "application/pdf"          = "org.pwmt.zathura.desktop";
    };
  };
}
