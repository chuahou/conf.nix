# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou

{ osConfig, ... }:

{
  programs.git = {
    enable = true;
    userName = osConfig.users.users.user.description;
    userEmail = "human+github@chuahou.dev";
    signing = {
      key = "314311D4CE92CC07DD5BDDC8A7F9181F143648FD";
      signByDefault = true;
    };
    extraConfig = {
      pull.ff = "only";
      init.defaultBranch = "master";
      diff.tool = "meld";
      # Avoid using script described in $VISUAL, as then it has issues telling
      # when editing is complete.
      core.editor = "nvim";
    };
  };
}
