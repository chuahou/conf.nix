# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

self: super:
let
  package = super.fdr.overrideAttrs (old: rec {
    pname   = "fdr";
    version = "4.2.7";
    name    = "${pname}-${version}";

    src = builtins.fetchTarball {
      url    = "https://dl.cocotec.io/fdr/fdr-3814-linux-x86_64.tar.gz";
      sha256 = "0vi1mxfzc2q3ww4grknwrzxwmq93vpkl6pp24kjnsx4r8wcza1n3";
    };
  });
in {
  fdr = package;
  fdr-desktop = super.makeDesktopItem {
    name        = package.pname;
    exec        = "${package}/bin/fdr4";
    desktopName = "FDR4";
  };
}
