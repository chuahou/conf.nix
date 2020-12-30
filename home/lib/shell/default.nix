# common shell setup to use for aliases, functions
#
# home-manager's current setup is a bit of a mess, where 'bash' and 'zsh' have
# different behaviour in what goes into profile, zshenv, rc, etc. I want these
# to be in multiple of these, so this text will be added to 'extraConfig' fields
# in the home configuration.

{ config, lib }:

let
  me      = import ../me.nix;
  home    = me.home;
  dev     = me.dev;
  aliases = import ./aliases.nix;
  vars    = import ./vars.nix;
in
  ''
    # environment variables
    ${config.lib.zsh.exportAll vars}

    # aliases
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (k: v: "alias ${k}=${lib.escapeShellArg v}") aliases
    )}

    # additional functions

    # miscellanous shell functions

    # use xdg-open on multiple files at once
    open () {
      for i in "$@"; do xdg-open $i; done
    }
    alias o="open"

    # disown by default when running some applications
    _run_and_disown () {
      $@ & disown
    }
    _disown_progs=( zathura meld gitg thunar xdg-open )
    for prog in "''${_disown_progs[@]}"; do
      alias $prog="_run_and_disown $prog"
    done
  ''
