# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Default file manager.

{ config, ... }:

let
  desktopName = "alacritty-browse";

in {
  xdg.mimeApps.defaultApplications."inode/directory" = "${desktopName}.desktop";
  xdg.desktopEntries.${desktopName} = {
    name = "Go to directory in Alacritty";
    genericName = "File Manager";
    exec = "sh -c \"${config.programs.alacritty.package
      }/bin/alacritty --working-directory=%f\"";
    categories = [ "Application" ];
    mimeType = [ "inode/directory" ];
  };
}
