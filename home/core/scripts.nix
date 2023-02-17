# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, lib, ... }:

let
  # import helper functions and data
  inherit (import ../../lib { inherit pkgs lib; })
    mkPath mkScriptWithDeps me;
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
        '')
      (pkgs.writeShellScriptBin "prepend-date" ''
        ${mkPath [ pkgs.coreutils ]}
        for x in "''${@}"; do
          mv "''${x}" "$(date -I)-''${x}"
        done
      '')

      # renames a problem sheet with name, course and number
      (pkgs.writeShellScriptBin "rename-ps" ''
        DIR=$(realpath $(dirname $1))
        COURSE=$(basename $(realpath ''${DIR}/../..))
        NUM=$(basename $DIR)
        cp $1 $DIR/chua_''${COURSE}_ps''${NUM}.pdf
      '')

      # simple CLI pomodoro timer
      (mkScriptWithDeps {
        deps = with pkgs; [ coreutils libnotify ncurses ] ++
          [ (import ../lib/gui/scripts.nix {
            inherit config pkgs lib;
          }).dndScript ];
        infile = ../res/scripts/pomodoro.sh;
      })
    ];
  }
