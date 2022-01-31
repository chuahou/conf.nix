# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Add cachix cache.

{ lib, ... }:

{
  nix.settings = {
    substituters = lib.mkAfter [ "https://chuahou.cachix.org" ];
    trusted-public-keys = lib.mkAfter [
      "chuahou.cachix.org-1:YOUI9Bctw2ErS0Pao4DTLPO2wCsPSsYMUIjtF6P0P3Q="
    ];
  };
}
