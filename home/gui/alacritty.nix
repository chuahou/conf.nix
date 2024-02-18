# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou

{ config, ... }:

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

      font = {
        normal.family = "Cascadia Code PL SemiLight";
        size = 12.5;
        offset.y = 8;

        # Center glyph vertically.
        glyph_offset.y = config.programs.alacritty.settings.font.offset.y / 2;
      };

      colors =
        let colours = import ../lib/gui/colours.nix;
        in with colours; rec {
          primary = {
            background = term.bg;
            foreground = term.fg;
          };
          cursor.cursor = primary.foreground;
          normal = {
            inherit black red green yellow blue magenta cyan white;
          };
          bright = {
            inherit (colours.bright)
              black red green yellow blue magenta cyan white;
          };
          draw_bold_text_with_bright_colors = false;
        };
    };
  };
}
