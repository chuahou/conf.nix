# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [ wezterm ];

  # Copy main config file.
  xdg.configFile."wezterm/wezterm.lua".source = ../res/wezterm.lua;

  # Generate colourscheme.
  xdg.configFile."wezterm/colors/hm-colourscheme.toml".source =
    (pkgs.formats.toml {}).generate "hm-colourscheme.toml"
      (with (import ../lib/gui/colours.nix); {
        colors = rec {
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
      });
}
