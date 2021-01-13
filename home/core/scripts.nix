# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, lib, ... }:

let
  # import helper functions and data
  inherit (import ../../lib { inherit pkgs lib; })
    mkPath me;
in
  {
    home.packages = [
      (let
        dir = me.home.devDirectory;
      in
        pkgs.writeShellScriptBin "cgit" ''
          ${mkPath (with pkgs; [ git findutils gnugrep ncurses ])}
          git_dir=${dir}
          ${builtins.readFile ../res/scripts/check-git.sh}
        ''
      )
    ];
  }
