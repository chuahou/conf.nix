# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, lib, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "cgit" ''
      ${pkgs.ch.mkPath (with pkgs; [ git findutils gnugrep ncurses ])}
      git_dir=${config.home.homeDirectory}/dev
      ${builtins.readFile ../res/scripts/check-git.sh}
    '')
    (pkgs.writeShellScriptBin "prepend-date" ''
      ${pkgs.ch.mkPath [ pkgs.coreutils ]}
      for x in "''${@}"; do
        mv "''${x}" "$(date -I)-''${x}"
      done
    '')
  ];
}
