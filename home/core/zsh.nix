{ config, lib, pkgs, ... }:

let
  p10k-config      = "p10k.zsh";
  p10k-config-path = "${config.xdg.configHome}/${p10k-config}";
in
  {
    xdg.configFile."${p10k-config}".source = ../res/p10k.zsh;

    programs.zsh = {
      enable   = true;
      envExtra = import ../lib/shell { inherit config lib; };

      # import them again as plugins will overwrite some of them
      shellAliases = import ../lib/shell/aliases.nix;

      sessionVariables = {
        # prevent less paging from disappearing
        LESS = "-Xr";

        # faster key timeout for snappier vim mode
        KEYTIMEOUT = 1;
      };

      localVariables = {
        ZSH_AUTOSUGGEST_STRATEGY          = [ "history" "completion" ];
        ZSH_AUTOSUGGEST_COMPLETION_IGNORE = "gpg*";
        ZSH_AUTOSUGGEST_HISTORY_IGNORE    = "gpg*";
        ZSH_AUTOSUGGEST_USE_ASYNC         = "yes";
      };

      initExtra = ''
        [[ ! -f ${p10k-config-path} ]] || source ${p10k-config-path}

        # vi mode config
        bindkey -rpM viins '^[^['

        # zsh-autosuggestions config
        bindkey '^ ' autosuggest-accept
        bindkey '^N' autosuggest-accept
      '';

      # plugins
      enableAutosuggestions = true;
      enableCompletion      = true;
      plugins = [
        (rec {
          name = "zsh-vim-mode";
          src  = builtins.fetchGit {
            inherit name;
            url = "https://github.com/softmoth/zsh-vim-mode.git";
            ref = "refs/heads/master";
            rev = "e6e6b718437e6b29499ac5264f489dabab998579";
          };
        })
        {
          name = "powerlevel10k";
          src  = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];
    };
  }
