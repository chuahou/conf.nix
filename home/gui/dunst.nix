# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou

{ pkgs, config, lib, ... }:

{
  services.dunst = {
    enable = true;

    settings =
      let colours = import ../lib/gui/colours.nix;
      in rec {
        global = {
          follow             = "keyboard";
          width              = 400;
          origin             = "top-right";
          offset             = "18x45";
          notification_limit = 5;
          max_icon_size      = 96;
          transparency       = 15;
          separator_height   = 2;
          padding            = 8;
          horizontal_padding = 8;
          frame_width        = 2;
          frame_color        = colours.gray."7";
          separator_color    = "frame";
          sort               = "yes";
          idle_threshold     = 300;
          font               = "Iosevka Regular 12";
          markup             = "full";
          format             = "<u><i>%a</i></u>\\n<b>%s</b>\\n%b";
          show_age_threshold = 60;
          word_wrap          = true;
        };
        urgency_low = {
          background = colours.gray."1";
          foreground = colours.gray."7";
          timeout    = 10;
        };
        urgency_normal = {
          inherit (urgency_low) background foreground timeout;
        };
        urgency_critical = {
          inherit (urgency_low) background foreground;
          frame_color = "#FF0000";
          timeout     = 0;
        };
      };
  };

  # Enable use of notify-send.
  home.packages = with pkgs; [ libnotify ];
}
