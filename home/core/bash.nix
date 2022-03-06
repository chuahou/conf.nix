# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, config, lib, ... }:

{
  programs.bash = {
    enable    = true;
    initExtra = import ../lib/shell { inherit config lib pkgs; };
  };
}
