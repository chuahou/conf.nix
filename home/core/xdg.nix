# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, lib, ... }:

{
  xdg.userDirs =
    let
      home  = "\$HOME";
      other = "${home}/other";
      media = "${home}/media";
    in
      {
        enable = true;

        documents = "${home}/doc";
        download  = "${home}/dl";

        music    = media;
        pictures = media;
        videos   = media;

        desktop     = "${other}/desk";
        templates   = "${other}/tmpl";
        publicShare = "${other}/pub";
      };
  home.activation =
    let
      dirs = config.xdg.userDirs;
    in
      {
        createUserDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # create home directories
          mkdir -p ${dirs.documents} ${dirs.download} ${dirs.music} \
            ${dirs.pictures} ${dirs.videos} ${dirs.desktop} ${dirs.templates} \
            ${dirs.publicShare}
        '';
      };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http"  = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "text/html"              = "firefox.desktop";
    };
  };
}
