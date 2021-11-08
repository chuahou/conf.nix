# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [

    # development
    cfgeq
    fdr
    (makeDesktopItem {
      name        = fdr.pname or fdr.name;
      exec        = "${fdr}/bin/fdr4";
      desktopName = "FDR4";
    })
    gitg
    isabelle
    meld

    # productivity
    gnome3.simple-scan
    libreoffice
    pandoc
    pdfgrep
    pdftk
    ripgrep

    # media
    (gimp-with-plugins.override {
      plugins = with gimpPlugins; [ resynthesizer ];
    })
    obs-studio
    vlc

    # communications
    discord
    tdesktop
    teams

    # system utilities
    arandr
    baobab
    font-manager

  ];

  services.dropbox.enable   = true;
  services.syncthing.enable = true;

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
