{ config, pkgs, ... }:

{
  imports = builtins.concatMap (import ./lib/lib.nix).importFolder [
    ./core
  ];

  # basic settings
  programs.home-manager.enable = true;
  home = {
    inherit ((import ./lib/me.nix).home) username homeDirectory;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
