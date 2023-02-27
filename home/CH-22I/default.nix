# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, lib, config, ... }:

{
  # Load tabs on demand for Firefox due to slower CPU.
  programs.firefox.profiles.${(import ../../lib {}).me.home.username}.settings = {
    "browser.sessionstore.restore_on_demand" = lib.mkForce true;
    "browser.sessionstore.restore_pinned_tabs_on_demand" = lib.mkForce true;
  };

  # Smaller gaps on smaller screen.
  xsession.windowManager.i3.config.gaps = {
    inner = lib.mkForce 4;
    outer = lib.mkForce 4;
  };

  # Battery only reaches 98% sometimes.
  services.polybar.config."module/battery".full-at = 98;

  # Separate Alacritty configuration with light theme.
  programs.alacritty = {
    settings = rec {
      font = {
        size = lib.mkForce 11;
        offset.y = lib.mkForce 3;
      };
      import =
        let
          alacritty-theme = pkgs.fetchFromGitHub {
            owner = "eendroroy";
            repo = "alacritty-theme";
            rev = "1615f87d85ec9e58bfd44078b461d5e281c051a2";
            sha256 = "sha256-LVWo7ALlbgpbxoqOOdjIYYO9txwJVwY+F0yA1gTJ+co=";
          };
        in [ "${alacritty-theme}/themes/papercolor_light.yaml" ];
      colors = lib.mkForce {
        normal = {
          black = "#222222";
          white = "#888888";
        };
        bright = {
          black = "#BBBBBB";
          white = "#DDDDDD";
        };
      };
    };
  };
  programs.neovim.plugins = with pkgs.vimPlugins; [ papercolor-theme ];
  xdg.configFile."nvim/after/plugin/appearance.vim".text = /* vim */ ''
    colorscheme PaperColor
    set background=light
    AirlineTheme minimalist
    highlight LineNr ctermfg=Brown
    highlight ColorColumn ctermbg=15
    highlight SpecialKey ctermfg=darkgrey
    highlight Whitespace ctermfg=251
    highlight VertSplit ctermfg=8 ctermbg=8

    " Make background transparent.
    highlight Normal ctermbg=NONE
    highlight EndOfBuffer ctermbg=NONE
    highlight LineNr ctermbg=NONE
    highlight SignColumn ctermbg=NONE
    highlight FoldColumn ctermbg=None
  '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";
}
