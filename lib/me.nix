# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  name = "Chua Hou";

  home = rec {
    username      = "sgepk";
    homeDirectory = "/home/" + username;
    devDirectory  = homeDirectory + "/dev";
    confDirectory = homeDirectory + "/dev/conf.nix";
  };
  github = {
    username = "chuahou";
    email    = "human+github@chuahou.dev";
    gpgKey   = "314311D4CE92CC07DD5BDDC8A7F9181F143648FD";
  };
}
