# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou

{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color"; # so we do not run into trouble with ssh/emacs
      };

      window = {
        padding = rec { x = 20; y = x; };
        opacity = 0.92;
      };
      scrolling.history  = 10000;
      draw_bold_text_with_bright_colors = false;

      font = rec {
        normal.family = "Mplus Code 60";
        size = 12  ;
        offset.y = 6;
        glyph_offset.y = offset.y / 2; # Center glyph vertically.
      };

      colors =
        let colours = import ../lib/gui/colours.nix;
        in with colours; rec {
          primary = {
            background = term.bg;
            foreground = term.fg;
            bright-foreground = term.fg-bright;
          };
          cursor.cursor = primary.foreground;
          normal = {
            inherit black red green yellow blue magenta cyan white;
          };
          bright = {
            inherit (colours.bright)
              black red green yellow blue magenta cyan white;
          };
        };
    };
  };
}
