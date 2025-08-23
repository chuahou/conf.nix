# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Chua Hou

{ ... }:

{
  programs.mpv = {
    enable = true;
    bindings = {
      "LEFT" = "seek -1";
      "RIGHT" = "seek 5";
      "UP" = "seek 10";
      "DOWN" = "seek -5";
      "/" = "cycle-values play-dir - +";
    };
    config = {
      "fullscreen" = "yes";
    };
  };
}
