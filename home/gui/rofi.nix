# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, lib, config, ... }:

{
  services.picom.opacityRule = [ "90:class_g *?= 'rofi'" ];

  programs.rofi = {
    enable = true;

    theme =
      let
        # Used to prevent literals from being quoted.
        inherit (config.lib.formats.rasi) mkLiteral;

        colours = import ../lib/gui/colours.nix;
        grays = lib.attrsets.mapAttrs' (name: value: {
          name  = "cgray${name}";
          value = mkLiteral value;
        }) colours.gray;
        base = lib.attrsets.mapAttrs' (name: value: {
          name  = "c${name}";
          value = mkLiteral value;
        }) (lib.attrsets.filterAttrs (_: value: builtins.isString value) colours);

      in {
        "*" = grays // base // {
          cbg      = mkLiteral "@cgray0";
          cbg-alt  = mkLiteral "@cgray1";
          cbg-alt2 = mkLiteral "@cgray2";
          cfg      = mkLiteral "@cgray5";

          font    = "Iosevka 15";
          padding = 2;

          background-color = mkLiteral "@cbg";
          color            = mkLiteral "@cfg";
        };

        "#window" = {
          # Geometry
          width      = mkLiteral "40%";
          padding    = 30;
          position   = "centre";
          fullscreen = false;

          # Border
          border       = 2;
          border-color = mkLiteral "@cgray7";
        };

        "#inputbar" = {
          background-color = mkLiteral "@cgrayblue";
          border           = mkLiteral "0 solid 0 solid 2 solid";
          border-color     = mkLiteral "@cblue";
          padding          = mkLiteral "6 2 4 2";
          margin           = mkLiteral "0 0 2";
        };

        "#prompt, entry, case-indicator".background-color = mkLiteral "inherit";
        "#prompt".margin = mkLiteral "0 2 0 1ch";
        "#entry".font    = "Iosevka Light 14";

        "#listview" = {
          # Geometry
          lines        = 8;
          columns      = 1;
          fixed-height = true;
          padding      = 10;
          spacing      = 0;

          # Behaviour
          layout    = mkLiteral "vertical";
          dynamic   = false;
          cycle     = true;
          scrollbar = true;
        };

        "#scrollbar" = {
          background-color = mkLiteral "@cbg-alt";
          handle-color     = mkLiteral "@cfg";
          handle-width     = 10;
        };

        "#element" = {
          padding = mkLiteral "7 5 7 8";
          font    = "Iosevka 14";
          border  = mkLiteral "0 solid 0 solid 0 solid 3 solid";
        };
        "#element normal" = rec {
          background-color = mkLiteral "@cbg-alt";
          border-color     = background-color;
        };
        "#element alternate" = rec {
          background-color = mkLiteral "@cbg-alt2";
          border-color     = background-color;
        };
        "#element selected" = {
          background-color = mkLiteral "@cgrayyellow";
          border           = mkLiteral "0 solid 0 solid 0 solid 3 solid";
          border-color     = mkLiteral "@cyellow";
        };
        "#element-text normal" = rec {
          background-color = mkLiteral "@cbg-alt";
        };
        "#element-text alternate" = rec {
          background-color = mkLiteral "@cbg-alt2";
        };
        "#element-text selected" = {
          background-color = mkLiteral "@cgrayyellow";
        };
      };

    extraConfig = {
      # General
      modi = "drun,run,window";
      m    = "-4"; # On monitor with focused window.

      # drun
      drun-display-format = "<span weight='500'>{name}</span> [<span weight='300' size=\"small\">(<i>{generic}</i>)</span>]";
      drun-match-fields   = "name,generic,exec,categories";
      display-drun        = "RUN λ>";

      # run
      run-command       = "{cmd}";
      run-shell-command = "{terminal} -e {cmd}";
      display-run       = "RUN $>";

      # window
      window-format       = "{c}   {t}";
      window-command      = "wmctrl -i -R {window}";
      window-match-fields = "all";
      display-window      = "WIN ?>";

      # behaviour
      disable-history = false;
      sort            = false;
      case-sensitive  = false;
      cycle           = true;
      sidebar-mode    = false;
      matching        = "normal";
      tokenize        = true;
      threads         = 0;
      scroll-method   = 1;
      click-to-exit   = true;
      show-match      = true;

      # appearance
      show-icons      = false;
      separator-style = "dash";
    };
  };
}
