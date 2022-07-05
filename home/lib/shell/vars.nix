# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou

{ pkgs }:

# Environment variables to set wherever needed
rec {
  EDITOR = "${pkgs.writeShellScript "nvim-nvr-wrapped" ''
    [ -z "$NVIM" ] \
        && exec nvim "$@" \
        || exec ${pkgs.neovim-remote}/bin/nvr "$@"
  ''}";
  VISUAL = EDITOR;
}
