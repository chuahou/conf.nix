# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Default file manager.

{ pkgs, ... }:

let
  desktopName = "wezterm-browse";

in {
  xdg.mimeApps.defaultApplications."inode/directory" = "${desktopName}.desktop";
  xdg.desktopEntries.${desktopName} = {
    name = "Go to directory in Wezterm";
    genericName = "File Manager";
    exec = "sh -c \"${pkgs.wezterm}/bin/wezterm start --cwd %f\"";
    categories = [ "Application" ];
    mimeType = [ "inode/directory" ];
  };
}
