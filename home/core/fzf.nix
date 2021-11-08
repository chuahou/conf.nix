# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [ fd fzf ];

  programs.zsh.initExtra = ''
    source $(fzf-share)/completion.zsh
    source $(fzf-share)/key-bindings.zsh
  '';
}
