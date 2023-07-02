# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022, 2023 Chua Hou

{
  inputs = {
    nixpkgs        = { url = "nixpkgs/nixos-unstable"; };
    nixpkgs-stable = { url = "nixpkgs/nixos-22.11"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rice = { url = "github:bertof/nix-rice"; flake = false; };
    impermanence = { url = "github:nix-community/impermanence"; };

    # zsh-vim-mode plugin
    zsh-vim-mode = { url = "github:softmoth/zsh-vim-mode"; flake = false; };

    # cpufreq-plugin
    cpufreq-plugin = { url = "github:chuahou/cpufreq-plugin"; flake = false; };

    # latex.sty styles
    latex-sty = { url = "github:chuahou/latex.sty"; flake = false; };

    # cfgeq
    cfgeq = { url = "github:chuahou/cfgeq"; };

    # nix-index database
    nix-index-database = { url = "github:Mic92/nix-index-database"; };
  };

  outputs =
    inputs@{
      self, nixpkgs, nixos-hardware, home-manager, ...
    }:
    let
      system = "x86_64-linux";

      overlays = with inputs; {
        cpufreq-plugin =
          import pkgs/cpufreq-plugin/overlay.nix inputs.cpufreq-plugin;

        cfgeq = self: super: {
          cfgeq = super.haskell.lib.justStaticExecutables
            cfgeq.defaultPackage.${system};
        };

        zsh-vim-mode = self: super: {
          zsh-vim-mode = { name = "zsh-vim-mode"; src = zsh-vim-mode; };
        };

        # Overlay providing Python 2 to packages that need it.
        python2 = import pkgs/python2-overlay.nix;

        # Enable fenced syntax for vim-nix.
        vim-nix-fenced-syntax = self: super: {
          vimPlugins = super.vimPlugins // {
            vim-nix = super.vimPlugins.vim-nix.overrideAttrs (old: {
              patches = (old.patches or []) ++ [
                (super.fetchpatch {
                  url = "https://patch-diff.githubusercontent.com/raw/LnL7/vim-nix/pull/28.patch";
                  sha256 = "sha256-bwEmItIVl7Fkez7A6jfnbaNOVP1gFgdlnAK4QEQ8TOI=";
                })
              ];
            });
          };
        };

        # Packages to overlay from a stable branch to avoid bugs and the like.
        stable = self: super:
          let pkgs = import nixpkgs-stable { inherit (super) config system; };
          in {
            inherit (pkgs) dropbox-cli; # See #17.
          };

        # Use firefox 114.0.1 temporarily as 114.0.2 has weird issues with some
        # animations not working, among other things.
        firefox-114-0-1 = self: super: {
          inherit (import (super.fetchFromGitHub {
            owner = "NixOS";
            repo = "nixpkgs";
            rev = "b87ff9f99721229bb8a883af03259ff3aaae7fad";
            sha256 = "sha256-mH852cR1Wf9d8XoXVEvonsxyzueSzhSQTn3RnMfxJy8=";
          }) { inherit (super) system config; }) firefox;
        };
      };

    in {

      # Forward inputs for easier debugging. To access each input simply use
      # .#inputs.[input].
      inherit inputs;

      # Hosts to generate configs over.
      hosts = [ "CH-21NS" "CH-22I" ];

      # nixpkgs with all overlays applied.
      overlayed = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = builtins.attrValues overlays;
      };

      nixosConfigurations =
        let
          base = {
            inherit system;
            modules = [
              # enable nix flakes
              ({ ... }: {
                nix.extraOptions = "experimental-features = nix-command flakes";
              })

              # extra overlays
              ({ ... }: {
                nixpkgs.overlays = with overlays; [
                  stable
                  cpufreq-plugin
                  python2 # Python 2 marked insecure #14
                ];
              })

              # main NixOS configuration
              (import ./nixos)

              # impermanence opt-in persistence
              inputs.impermanence.nixosModules.impermanence
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

      homeConfigurations =
        builtins.listToAttrs (builtins.map (host: {
          name = host;
          value = home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            modules = [
              (import ./home {
                overlays = with overlays; [
                  stable
                  cfgeq
                  cpufreq-plugin
                  firefox-114-0-1
                  vim-nix-fenced-syntax
                  zsh-vim-mode
                  python2 # Python 2 marked insecure #14
                ];
                inherit host;
                inherit ((import ./lib {}).me) home;
              })
            ];
            extraSpecialArgs = { inherit inputs; };
          };
        }) self.hosts);
    };
}
