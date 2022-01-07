# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    font = {
      package = pkgs.fira-code;
      name = "Fira Code";
    };

    environment = {};

    settings =
      let colours = import ../lib/gui/colours.nix;
      in {
        # Font offsets.
        font_size = "11.5";
        adjust_line_height = 7;
        adjust_baseline = -2;

        # Disable ligatures when in cursor.
        disable_ligatures = "cursor";

        # Cursor settings.
        cursor = colours.term.fg; # FG colour.
        cursor_text_color = "background"; # Render text as BG colour.
        cursor_shape = "block";

        # Increase scrollback size.
        scrollback_lines = 10000;

        # Don't make noise with \a.
        enable_audio_bell = false;
        visual_bell_duration = "0.1";

        # Don't remember previous window size.
        remember_window_size = false;

        # Window padding.
        window_padding_width = 30;

        # Colour settings.
        foreground = colours.term.fg;
        background = colours.term.bg;
        background_opacity = "0.92";
        selection_foreground = "none";
        color0 = colours.black;
        color1 = colours.red;
        color2 = colours.green;
        color3 = colours.yellow;
        color4 = colours.blue;
        color5 = colours.magenta;
        color6 = colours.cyan;
        color7 = colours.white;
        color8 = colours.bright.black;
        color9 = colours.bright.red;
        color10 = colours.bright.green;
        color11 = colours.bright.yellow;
        color12 = colours.bright.blue;
        color13 = colours.bright.magenta;
        color14 = colours.bright.cyan;
        color15 = colours.bright.white;
      };
  };
}
