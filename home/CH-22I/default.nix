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

  # Battery only reaches 99%.
  services.polybar.config."module/battery".full-at = 99;

  # Use Alacritty instead of Wezterm.
  # Wezterm has some strange performance issues with integrated graphics. We
  # also use a light theme due to monitor issues.
  xsession.windowManager.i3.config.keybindings."Mod1+Return" = lib.mkForce
    "exec --no-startup-id ${config.programs.alacritty.package}/bin/alacritty";
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color"; # so we do not run into trouble with ssh/emacs
      };
      window.padding = rec { x = 20; y = x; };
      scrolling.history  = 10000;
      draw_bold_text_with_bright_colors = false;
      font = {
        normal.family = "Latin Modern Mono";
        size = 12.5;
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
      colors = {
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
  xdg.configFile."nvim/after/plugin/appearance.vim".text = ''
    colorscheme PaperColor
    set background=light
    AirlineTheme minimalist
    highlight LineNr ctermfg=Brown
    highlight ColorColumn ctermbg=15
    highlight SpecialKey ctermfg=darkgrey
    highlight Whitespace ctermfg=253
    highlight VertSplit ctermfg=8 ctermbg=8
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
