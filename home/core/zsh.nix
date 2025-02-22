# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2025 Chua Hou

{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable   = true;
    envExtra = import ../lib/shell { inherit config lib pkgs; };

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
      in import ../lib/shell/aliases.nix { inherit config; } // dirStackAliases;

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

    # Save history in synced folder.
    history = {
      path = "${config.xdg.userDirs.documents}/zsh_history";
      save = 512 * 1024 * 1024; # Save more.
    };

    autocd = true;

    initExtra = /* zsh */ ''
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
      [[ $- != *i* ]] || stty -ixon -ixoff <$TTY >$TTY
    '';

    # plugins
    autosuggestion.enable = true;
    enableCompletion      = true;
    plugins = [
      pkgs.zsh-vim-mode
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      character =
        let
          mainSymbol = ">";
          vimcmdSymbol = "<";
        in rec {
          success_symbol = "[${mainSymbol}](bold green)";
          error_symbol = "[${mainSymbol}](bold red)";
          vimcmd_symbol = "[${vimcmdSymbol}](bold green)";
          vimcmd_replace_symbol = "[${vimcmdSymbol}](bold purple)";
          vimcmd_replace_one_symbol = vimcmd_replace_symbol;
          vimcmd_visual_symbol = "[${vimcmdSymbol}](bold yellow)";
        };
      directory.truncate_to_repo = false;
      git_metrics.disabled = false;
      git_status.deleted = "!";
    };
  };
}
