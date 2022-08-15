# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ../res/wezterm.lua;
    colorSchemes.hm-colourscheme = with (import ../lib/gui/colours.nix); rec {
      foreground = term.fg;
      background = term.bg;
      cursor_bg = foreground;
      cursor_fg = background;
      cursor_border = cursor_bg;
      selection_bg = bright.black;
      selection_fg = bright.white;
      ansi = [ black red green yellow blue magenta cyan white ];
      brights = with bright; [
        black red green yellow blue magenta cyan white
      ];
    };
  };
}
