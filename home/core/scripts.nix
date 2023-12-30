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
      (pkgs.writeShellScriptBin "cgit" ''
        ${mkPath (with pkgs; [ git findutils gnugrep ncurses ])}
        git_dir=${config.home.homeDirectory}/dev
        ${builtins.readFile ../res/scripts/check-git.sh}
      '')
      (pkgs.writeShellScriptBin "prepend-date" ''
        ${mkPath [ pkgs.coreutils ]}
        for x in "''${@}"; do
          mv "''${x}" "$(date -I)-''${x}"
        done
      '')
    ];
  }
