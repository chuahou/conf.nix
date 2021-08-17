# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ appimage-run
, makeDesktopItem
, symlinkJoin
, writeShellScriptBin
}:

let
  version = "0.31.5";
  appimage = builtins.fetchTarball {
    url    = "https://github.com/ahrm/sioyek/releases/download/v${version}/sioyek-release-linux.zip";
    sha256 = "sha256-f4dHvxwRl5kIFU9xNqhYtXBnJLNR4MRGuiI5bGpZP7U=";
  };
  script = writeShellScriptBin "sioyek" ''
    ${appimage-run}/bin/appimage-run ${appimage}
  '';
  desktop = makeDesktopItem rec {
    name        = "sioyek";
    exec        = "${script}/bin/sioyek";
    desktopName = "Sioyek";
  };

in
  symlinkJoin {
    name  = "sioyek-joined";
    paths = [ script desktop ];
  }
