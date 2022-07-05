# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou

{ pkgs }:

# Environment variables to set wherever needed
rec {
  EDITOR = "${pkgs.writeShellScript "nvim-remote" ''
    [ -z "$NVIM" ] \
        && exec nvim "$@" \
        || exec nvim --server $NVIM --remote "$@"
  ''}";
  VISUAL = EDITOR;
}
