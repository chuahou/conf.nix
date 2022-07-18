# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  services.picom.opacityRules = [ "92:class_g *?= 'zathura'" ];

  programs.zathura = {
    enable  = true;
    options = with (import ../lib/gui/colours.nix); rec {
      # default colours
      default-bg = "#101010";
      default-fg = term.fg;

      # bar colours
      statusbar-bg = term.bg;
      statusbar-fg = default-fg;
      inputbar-bg  = default-bg;
      inputbar-fg  = default-fg;

      # completion colours
      completion-bg           = black;
      completion-fg           = default-fg;
      completion-highlight-bg = highlight-color;
      completion-highlight-fg = black;
      completion-group-bg     = term.bg;
      completion-group-fg     = term.fg-bright;

      # notifications colours
      notification-bg         = default-fg;
      notification-fg         = default-bg;
      notification-error-bg   = bright.red;
      notification-error-fg   = term.bg;
      notification-warning-bg = bright.yellow;
      notification-warning-fg = notification-error-fg;

      # highlighted text colours
      highlight-color        = blue;
      highlight-active-color = magenta;

      # recolor colours
      recolor               = false;
      recolor-darkcolor     = term.fg-bright;
      recolor-lightcolor    = term.bg;
      recolor-keephue       = false;
      recolor-reverse-video = true;

      # search behaviour
      incremental-search = true;

      # scrollbars
      show-scrollbars = true;
      scrollbar-bg    = "#080808";
      scrollbar-fg    = default-fg;

      # padding between pages
      page-padding = 10;

      # use main clipboard
      selection-clipboard = "clipboard";

      # don't show recents
      show-recent = 0;
    };
    extraConfig = ''
      # C-6 to jump back in jump list
      map [normal]     <C-6> jumplist backward
      map [fullscreen] <C-6> jumplist backward
    '';
  };
}
