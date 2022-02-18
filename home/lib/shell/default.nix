# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Common shell setup to use for aliases, functions
#
# home-manager's current setup is a bit of a mess, where 'bash' and 'zsh' have
# different behaviour in what goes into profile, zshenv, rc, etc. I want these
# to be in multiple of these, so this text will be added to 'extraConfig' fields
# in the home configuration.

{ config, lib }:

let
  aliases = import ./aliases.nix;
  vars    = import ./vars.nix;
in ''
  # environment variables
  ${config.lib.zsh.exportAll vars}

  # aliases
  ${lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "alias ${k}=${lib.escapeShellArg v}") aliases
  )}

  # additional functions

  # miscellanous shell functions

  # disown by default when running some applications
  _run_and_disown () {
    $@ >/dev/null 2>&1 & disown
  }
  _disown_progs=( zathura meld gitg thunar xdg-open )
  for prog in "''${_disown_progs[@]}"; do
    alias $prog="_run_and_disown $prog"
  done

  # use xdg-open on multiple files at once
  open () {
    for i in "$@"; do xdg-open $i; done
  }
  alias o="open"
''
