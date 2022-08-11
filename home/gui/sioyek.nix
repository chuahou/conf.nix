# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  programs.sioyek = {
    enable = true;
    config = {
      background_color = "0.1 0.1 0.1"; # Black background.
      link_highlight_color = "0.8 0.0 0.0"; # Red highlight for links.
    };
    bindings = {
      # Vim-style movement.
      move_right = "h";
      move_down = "j";
      move_up = "k";
      move_left = "l";
      screen_down = "<C-d>";
      screen_up = "<C-u>";
      next_page = "<S-j>";
      previous_page = "<S-k>";

      # Use = to reset zoom.
      fit_to_page_width = "=";

      # Jump through states.
      next_state = "<C-i>";
      prev_state = "<C-o>";
    };
  };
}
