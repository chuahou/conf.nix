# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

let inherit (import ../../lib {}) me;
in {
  programs.git = {
    enable    = true;
    userName  = me.name;
    userEmail = me.github.email;
    signing = {
      key           = me.github.gpgKey;
      signByDefault = true;
    };
    extraConfig = {
      pull.ff            = "only";
      init.defaultBranch = "master";
      # Avoid using script described in $VISUAL, as then it has issues telling
      # when editing is complete.
      core.editor = "nvim";
    };
  };
}
