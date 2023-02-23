# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou

{ pkgs }:

# Environment variables to set wherever needed
rec {
  EDITOR = "${pkgs.writeShellScript "nvim-remote" /* bash */ ''
    # If there's exactly 1 argument (assumed to be a filename), and there's an
    # existing nvim instance, we use --remote to open it in the existing
    # instance.
    if [ $# = 1 ] && [ -n "$NVIM" ]; then
        # We use realpath, as relative paths are interpreted relative to the
        # directory the existing instance was opened in, which is frequently
        # incorrect.
        exec nvim "$@" --server $NVIM --remote $(realpath "$1")
    else
        # Otherwise, execute nvim normally.
        exec nvim "$@"
    fi
  ''}";
  VISUAL = EDITOR;
}
