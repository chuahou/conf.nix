{ ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window.padding     = rec { x = 40; y = x; };
      scrolling.history  = 10000;
      background_opacity = 0.85;
      draw_bold_text_with_bright_colors = false;

      font = {
        normal.family = "Iosevka"; # other weights will inherit
        size          = 13.0;
        offset.y      = 2;         # increased line spacing
      };

      colors =
        let
          colours = import ../lib/gui/colours.nix;
        in
          {
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
