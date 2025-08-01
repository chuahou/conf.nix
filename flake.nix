# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022, 2023 Chua Hou

{
  inputs = {
    nixpkgs = { url = "nixpkgs/nixos-25.05"; };
    nixpkgs-prev = { url = "nixpkgs/nixos-24.11"; };
    nixpkgs-unstable = { url = "nixpkgs/nixpkgs-unstable"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    impermanence = { url = "github:nix-community/impermanence"; };

    # zsh-vim-mode plugin
    zsh-vim-mode = { url = "github:softmoth/zsh-vim-mode"; flake = false; };

    # latex.sty styles
    latex-sty = { url = "github:chuahou/latex.sty"; flake = false; };

    # nix-index database
    nix-index-database = { url = "github:Mic92/nix-index-database"; };

    # secure boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      overlays = with inputs; {

        # Nix helper functions.
        helpers = import pkgs/helpers.nix;

        zsh-vim-mode = self: super: {
          zsh-vim-mode = { name = "zsh-vim-mode"; src = zsh-vim-mode; };
        };

        # Enable fenced syntax for vim-nix.
        vim-nix-fenced-syntax = self: super: {
          vimPlugins = super.vimPlugins // {
            vim-nix = super.vimPlugins.vim-nix.overrideAttrs (old: {
              patches = (old.patches or []) ++ [
                ./pkgs/vim-nix.patch # Modified from #28 to resolve conflicts.
              ];
            });
          };
        };

        # Packages to overlay from other branches to avoid bugs and the like.
        nixpkgs-branches = self: super:
          let
            prev = import nixpkgs-prev { inherit (super) config system; };
            unstable = import nixpkgs-unstable { inherit (super) config system; };
          in {
            inherit (unstable) joplin-desktop fzf;
          };
      };

    in {

      # Forward inputs for easier debugging. To access each input simply use
      # .#inputs.[input].
      inherit inputs;

      # Hosts to generate configs over.
      hosts = [ "CH-23" ];

      nixosConfigurations =
        let
          base = {
            inherit system;
            modules = [
              # enable nix flakes
              ({ ... }: {
                nix.extraOptions = "experimental-features = nix-command flakes";
              })

              # nixpkgs configuration
              ({ ... }: {
                nixpkgs = {
                  overlays = builtins.attrValues overlays;
                  config.allowUnfree = true;
                };
              })

              # main NixOS configuration
              (import ./nixos)

              # impermanence opt-in persistence
              inputs.impermanence.nixosModules.impermanence

              # home-manager
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = { inherit inputs; };
                  users.user = import ./home;
                };
              }
            ];
            specialArgs = { inherit inputs; };
          };
        in

          builtins.listToAttrs (builtins.map (host: {
            name = host;
            value = nixpkgs.lib.nixosSystem (base // {
              modules = (base.modules or []) ++ [ (import ./nixos/${host}) ];
            });
          }) self.hosts);

    };
}
