# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [ sioyek ];

  xdg.dataFile."Sioyek/prefs_user.config".text = ''
    # Black background.
    background_color 0.1 0.1 0.1

    # Highlink links with red.
    link_highlight_color 0.8 0.0 0.0
  '';

  xdg.dataFile."Sioyek/keys_user.config".text = ''
    # Vim-style movement.
    move_right    h
    move_down     j
    move_up       k
    move_left     l
    screen_down   <C-d>
    screen_up     <C-u>
    next_page     <S-j>
    previous_page <S-k>

    # Use = to reset zoom.
    fit_to_page_width =

    # Jump through states.
    next_state <C-i>
    prev_state <C-o>
  '';
}
