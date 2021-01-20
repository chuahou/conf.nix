# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  inputs = {
    nixpkgs        = { url = "nixpkgs/nixos-20.09"; };
    unstable       = { url = "nixpkgs/nixpkgs-unstable"; };
    small          = { url = "nixpkgs/nixos-20.09-small"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager/release-20.09";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = { url = "/persist/secrets.nix"; flake = false; };

    # instant RST plugin and pip package
    instantRstPy  = { url = "github:gu-fan/instant-rst.py"; flake = false; };
    instantRstVim = { url = "github:gu-fan/InstantRst";     flake = false; };

    # zsh-vim-mode plugin
    zsh-vim-mode = { url = "github:softmoth/zsh-vim-mode"; flake = false; };

    # cpufreq-plugin
    cpufreq-plugin = { url = "github:chuahou/cpufreq-plugin"; flake = false; };

    # ioslabka
    ioslabka = { url = "github:chuahou/ioslabka.nix"; };
  };

  outputs =
    inputs@{
      self, nixpkgs, unstable, small, nixos-hardware, secrets, home-manager, ...
    }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};
    in rec {

    cpufreqPluginOverlay = self: super: {
      cpufreq-plugin = super.haskell.lib.doJailbreak
        (super.haskellPackages.callCabal2nix "cpufreq-plugin"
          (inputs.cpufreq-plugin) {});
      cpufreq-plugin-wrapped = super.writeShellScriptBin "cpufreq-plugin" ''
        export PATH=${super.cpufrequtils}/bin:${super.gnused}/bin
        ${self.cpufreq-plugin}/bin/cpufreq-plugin "$@"
      '';
    };

    hplipOverlay = self: super: {
      inherit (import small { inherit (super) system config; })
        hplip hplipWithPlugin;
    };

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
          nixpkgs.overlays = [
            cpufreqPluginOverlay inputs.ioslabka.overlay hplipOverlay
          ];
        })

        # main NixOS configuration
        (import ./nixos (import secrets))

        # nixos-hardware tweaks
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd
      ];
    };

    hmConfigs.${(import ./lib {}).me.home.username} =
      let
        instantRstOverlay = self: super: {
          instantRstVim = super.vimUtils.buildVimPlugin {
            name = "InstantRst";
            src  = inputs.instantRstVim;
          };
          instantRstPy = super.python3Packages.buildPythonPackage {
            pname   = "instantRst";
            version = "0.9.9.1";
            doCheck = false;
            src     = inputs.instantRstPy;
            propagatedBuildInputs = with super.python3Packages; [
              docutils
              flask
              flask-socketio
              pygments
            ];
          };
        };
        zshOverlay = self: super: {
          zsh-vim-mode = {
            name = "zsh-vim-mode";
            src  = inputs.zsh-vim-mode;
          };
        };
        unstableOverlay = self: super:
          let
            pkgs = import unstable { inherit (super) system config; };
          in {
            inherit (pkgs) alacritty discord syncthing tdesktop;
            inherit (pkgs.vimPlugins) coc-nvim;
          };
      in home-manager.lib.homeManagerConfiguration {
        inherit system;
        inherit ((import ./lib {}).me.home) username homeDirectory;
        configuration = import ./home {
          overlays = [
            cpufreqPluginOverlay
            instantRstOverlay
            unstableOverlay
            zshOverlay
          ];
        };
      };

    };
}
