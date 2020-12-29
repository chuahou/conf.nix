{ config, pkgs, ... }:

{
  imports =
    let
      importFolder = folder:
        builtins.map (file: folder + "/${file}")
          (builtins.attrNames (builtins.readDir folder));
    in
      builtins.concatMap importFolder [
        ./core
      ];

  # basic settings
  programs.home-manager.enable = true;
  home.username = "sgepk";
  home.homeDirectory = "/home/sgepk";

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
