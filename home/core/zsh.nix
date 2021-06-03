# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, lib, pkgs, ... }:

let
  p10k-config      = "p10k.zsh";
  p10k-config-path = "${config.xdg.configHome}/${p10k-config}";
in {
  xdg.configFile.${p10k-config}.source = ../res/p10k.zsh;

  programs.zsh = {
    enable   = true;
    envExtra = import ../lib/shell { inherit config lib; };

    # import them again as plugins will overwrite some of them
    shellAliases =
      # alias 0 to 9 to cd +0 to cd +9
      let dirStackAliases =
        (builtins.foldl'
          (x: y: x // y)
          {}
          (builtins.genList
            (x: { "${toString x}" = "cd +${toString x}"; })
            10));
      in import ../lib/shell/aliases.nix // dirStackAliases;

    sessionVariables = {
      # prevent less paging from disappearing
      LESS = "-Xr";

      # faster key timeout for snappier vim mode
      KEYTIMEOUT = 1;

      # only consider _ and . as part of a word
      WORDCHARS = "_.";
    };

    localVariables = {
      ZSH_AUTOSUGGEST_STRATEGY          = [ "history" "completion" ];
      ZSH_AUTOSUGGEST_COMPLETION_IGNORE = "gpg*";
      ZSH_AUTOSUGGEST_HISTORY_IGNORE    = "gpg*";
      ZSH_AUTOSUGGEST_USE_ASYNC         = "yes";
    };

    autocd = true;

    initExtra = ''
      [[ ! -f ${p10k-config-path} ]] || source ${p10k-config-path}

      # vi mode config
      bindkey -rpM viins '^[^['
      vim-mode-bindkey viins vicmd -- up-line-or-history   Up
      vim-mode-bindkey viins vicmd -- down-line-or-history Down

      # zsh-autosuggestions config
      bindkey '^ ' autosuggest-accept
      bindkey '^N' autosuggest-accept

      # enable dir stack
      setopt autopushd

      # disable <C-s> <C-q> on interactive shells
      [[ $- != *i* ]] || stty -ixon -ixoff

      # source new nix completion script
      # temporary fix until local.mk merge propagates to release branches on
      # nixpkgs
      source ${pkgs.nixFlakes.src}/misc/zsh/completion.zsh
    '';

    # plugins
    enableAutosuggestions = true;
    enableCompletion      = true;
    plugins = [
      pkgs.zsh-vim-mode
      {
        name = "powerlevel10k";
        src  = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];
  };
}
