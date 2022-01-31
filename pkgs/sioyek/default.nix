# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ appimage-run
, makeDesktopItem
, symlinkJoin
, writeShellScriptBin
}:

let
  version = "1.0.0";
  appimage = builtins.fetchTarball {
    url    = "https://github.com/ahrm/sioyek/releases/download/v${version}/sioyek-release-linux-gcc8.zip";
    sha256 = "sha256-j6uRwbNGGaT9wirMx06eQhsCd3ZVEL9yzP8oHUrzRfc=";
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
