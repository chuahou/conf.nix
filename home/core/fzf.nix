# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ fzf ];

  programs.zsh.initContent = lib.mkAfter ''
    source $(fzf-share)/completion.zsh
    source $(fzf-share)/key-bindings.zsh

    # fzf options.
    export FZF_DEFAULT_OPTS='--border --info=inline'

    # Use fd instead of find, don't show hidden files.
    _fzf_compgen_path() {
      echo "$1"
      ${pkgs.fd}/bin/fd --follow . "$1" 2> /dev/null
    }
    _fzf_compgen_dir() {
      echo "$1"
      ${pkgs.fd}/bin/fd --type d --follow . "$1" 2> /dev/null
    }
  '';
}
