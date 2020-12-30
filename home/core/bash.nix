{ config, ... }:

{
  programs.bash = {
    enable           = true;
    shellAliases     = import ../lib/aliases.nix;
  };
}
