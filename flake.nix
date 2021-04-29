# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  inputs = {
    nixpkgs        = { url = "nixpkgs/nixos-20.09"; };
    unstable       = { url = "nixpkgs/nixpkgs-unstable"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = { url = "/persist/secrets.nix"; flake = false; };

    # instant RST plugin and pip package
    instantRstPy  = { url = "github:gu-fan/instant-rst.py"; flake = false; };
    instantRstVim = { url = "github:gu-fan/InstantRst";     flake = false; };

    # instant markdown plugin
    vim-instant-markdown = {
      url = "github:instant-markdown/vim-instant-markdown";
      flake = false;
    };
    smdv = { url = "github:flaport/smdv"; flake = false; };

    # zsh-vim-mode plugin
    zsh-vim-mode = { url = "github:softmoth/zsh-vim-mode"; flake = false; };

    # cpufreq-plugin
    cpufreq-plugin = { url = "github:chuahou/cpufreq-plugin"; flake = false; };

    # ioslabka
    ioslabka = { url = "github:chuahou/ioslabka.nix"; };

    # latex.sty styles
    latex-sty = { url = "github:chuahou/latex.sty"; flake = false; };
  };

  outputs =
    inputs@{
      self, nixpkgs, nixos-hardware, home-manager, ...
    }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};

      overlays = with inputs; {
        cpufreq-plugin = import pkgs/cpufreq-plugin/overlay.nix cpufreq-plugin;
        instantRst     = import pkgs/instantRst/overlay.nix instantRstVim instantRstPy;
        vim-instant-md = import pkgs/vim-instant-markdown/overlay.nix vim-instant-markdown smdv;
        ioslabka       = ioslabka.overlay;
        latex-sty      = self: super: { inherit (inputs) latex-sty; };
        secrets        = self: super: { secrets = import secrets; };
        zsh-vim-mode   = self: super: {
          zsh-vim-mode = { name = "zsh-vim-mode"; src = zsh-vim-mode; };
        };

        unstable = self: super:
          let
            pkgs = import unstable { inherit (super) system config; };
          in {
            inherit (pkgs) alacritty discord syncthing tdesktop teams;
            inherit (pkgs.vimPlugins) coc-nvim;
          };
      };

    in {

      testing = (import nixpkgs { overlays = [ overlays.vim-instant-md ];
      inherit system; }).smdv;

      nixosConfigurations.CH-21N = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # enable nix flakes
          ({ pkgs, ... }: {
            nix = {
              package      = pkgs.nixFlakes;
              extraOptions = "experimental-features = nix-command flakes";
            };
          })

          # extra overlays
          ({ ... }: {
            nixpkgs.overlays = with overlays; [
              cpufreq-plugin ioslabka secrets
            ];
          })

          # main NixOS configuration
          (import ./nixos)

          # nixos-hardware tweaks
          nixos-hardware.nixosModules.common-pc-laptop
          nixos-hardware.nixosModules.common-pc-laptop-ssd
        ];
      };

      hmConfigs.${(import ./lib {}).me.home.username} =
        home-manager.lib.homeManagerConfiguration {
          inherit system;
          inherit ((import ./lib {}).me.home) username homeDirectory;
          configuration = import ./home {
            overlays = with overlays; [
              cpufreq-plugin
              instantRst
              latex-sty
              unstable
              vim-instant-md
              secrets
              zsh-vim-mode
            ];
          };
        };
    };
}
