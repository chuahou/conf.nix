# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color"; # so we do not run into trouble with ssh/emacs
      };

      window.padding     = rec { x = 30; y = x; };
      scrolling.history  = 10000;
      background_opacity = 0.92;
      draw_bold_text_with_bright_colors = false;

      font = {
        normal.family = "Latin Modern Mono";
        size          = 14.0;
      };

      colors =
        let colours = import ../lib/gui/colours.nix;
        in {
          primary = {
            background        = colours.term.bg;
            foreground        = colours.term.fg;
            bright-foreground = colours.term.fg-bright;
          };
          cursor.cursor = colours.term.fg;
          normal = {
            inherit (colours)
              black red green yellow blue magenta cyan white;
          };
          bright = {
            inherit (colours.bright)
              black red green yellow blue magenta cyan white;
          };
        };
    };
  };
}
