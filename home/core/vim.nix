{ config, pkgs, ... }:

let
  configDir = "${config.xdg.configHome}/nvim";
in
  {
    # copy entire nvim configuration directory
    xdg.configFile.nvim.source = ../res/nvim;

    programs.neovim = {
      enable = true;

      configure = {
        customRC = ''
          " we use the full configuration copied
          set runtimepath^=${configDir} runtimepath+=${configDir}/after
          source ${configDir}/init.vim
        '';
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [];
          opt = [];
        };
      };

      viAlias      = true;
      vimAlias     = true;
      vimdiffAlias = true;
    };
  }
