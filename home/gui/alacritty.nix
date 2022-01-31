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

      window = {
        padding = rec { x = 30; y = x; };
        opacity = 0.92;
      };
      scrolling.history  = 10000;
      draw_bold_text_with_bright_colors = false;

      font = {
        normal.family = "Fira Code";
        size          = 13.0;
        offset = {
          x = -1.0;
          y = 6.0;
        };
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
