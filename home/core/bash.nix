{ config, ... }:

{
  programs.bash = {
    enable           = true;
    sessionVariables = import ../lib/envvars.nix;
    shellAliases     = import ../lib/aliases.nix;
  };
}
