# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ konsole ];

  xdg.dataFile = {
    # Colourscheme.
    "konsole/hm.colorscheme".text =
      let
        inherit ((import pkgs.flakeInputs.nix-rice { inherit pkgs; }).color)
          hexToRgba darken brighten;

        toKonsoleColor = rgba: let format = f: toString (builtins.floor f); in
          with rgba; "Color=${format r},${format g},${format b}";

        makeEntry = name: color: let rgba = hexToRgba color; in ''
          [${name}]
          ${toKonsoleColor rgba}
          [${name}Faint]
          ${toKonsoleColor (darken 10.0 rgba)}
          [${name}Intense]
          ${toKonsoleColor (brighten 10.0 rgba)}
        '';

        mappings = with import ../lib/gui/colours.nix; {
          "Background" = term.bg;
          "Foreground" = term.fg;
          "Color0" = black;
          "Color1" = red;
          "Color2" = green;
          "Color3" = yellow;
          "Color4" = blue;
          "Color5" = magenta;
          "Color6" = cyan;
          "Color7" = white;
        };
        opacity = 0.91;

      in ''
        ${builtins.concatStringsSep "\n"
          (lib.mapAttrsToList makeEntry mappings)}
        [General]
        Blur=false
        ColorRandomization=false
        Description=Home Manager Colorscheme
        Opacity=${toString opacity}
        Wallpaper=
      '';
  };
}
