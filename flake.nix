# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  inputs = {
    nixpkgs.url        = "nixpkgs/nixos-20.09";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url   = "github:nix-community/home-manager/release-20.09";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    secrets.url   = "/home/sgepk/dev/secrets.nix";
    secrets.flake = false;

    # instant RST plugin and pip package
    instantRstPy.url    = "github:gu-fan/instant-rst.py";
    instantRstPy.flake  = false;
    instantRstVim.url   = "github:gu-fan/InstantRst";
    instantRstVim.flake = false;

    # zsh-vim-mode plugin
    zsh-vim-mode.url   = "github:softmoth/zsh-vim-mode";
    zsh-vim-mode.flake = false;
  };

  outputs =
    inputs@{
      self, nixpkgs, nixos-hardware, secrets, home-manager, ...
    }: let system = "x86_64-linux"; in {

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

        # main NixOS configuration
        (import ./nixos (import secrets))

        # nixos-hardware tweaks
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd
      ];
    };

    hmConfigs."${(import ./lib).me.home.username}" =
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
      in
        home-manager.lib.homeManagerConfiguration {
          inherit system;
          inherit ((import ./lib).me.home) username homeDirectory;
          configuration = import ./home {
            overlays = [ instantRstOverlay zshOverlay ];
          };
        };

    };
}
