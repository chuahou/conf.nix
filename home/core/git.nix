# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

let
  me = import ../lib/me.nix;
in
  {
    programs.git = {
      enable    = true;
      userName  = me.name;
      userEmail = me.github.email;
      signing = {
        key           = me.github.gpgKey;
        signByDefault = true;
      };
    };
  }
