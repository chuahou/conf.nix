# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  programs.rofi = {
    enable = true;
  };

  xdg.configFile."rofi/config.rasi".source = ../res/rofi/config.rasi;
  xdg.configFile."rofi/theme.rasi".text =
    let
      colours = import ../lib/gui/colours.nix;
    in
      ''
        // we do colours in nix and everything else in original rasi files
        // as home-manager doesn't support the proper rasi configuration format
        * {
          // gray and translucent colours
          ${builtins.concatStringsSep "\n"
            (builtins.attrValues
              (builtins.mapAttrs
                (col: val: "cgray${col}: ${val};") colours.gray))}

          // all base colours
          ${builtins.concatStringsSep "\n"
            (builtins.attrValues
              (builtins.mapAttrs
                (col: val:
                  if builtins.isString val
                  then "c${col}: ${val};"
                  else "") colours))}
        }

        ${builtins.readFile ../res/rofi/theme.rasi.in}
      '';
}
