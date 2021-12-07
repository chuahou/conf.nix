# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  inputs = {
    nixpkgs        = { url = "nixpkgs/nixpkgs-unstable"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = { url = "/persist/secrets.nix"; flake = false; };

    # zsh-vim-mode plugin
    zsh-vim-mode = { url = "github:softmoth/zsh-vim-mode"; flake = false; };

    # cpufreq-plugin
    cpufreq-plugin = { url = "github:chuahou/cpufreq-plugin"; flake = false; };

    # ioslabka
    ioslabka = { url = "github:chuahou/ioslabka.nix"; };

    # latex.sty styles
    latex-sty = { url = "github:chuahou/latex.sty"; flake = false; };

    # cfgeq
    cfgeq = { url = "github:chuahou/cfgeq"; };
  };

  outputs =
    inputs@{
      self, nixpkgs, nixos-hardware, home-manager, ...
    }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};

      overlays = with inputs; {
        cpufreq-plugin = import pkgs/cpufreq-plugin/overlay.nix;
        sioyek         = import pkgs/sioyek/overlay.nix;

        ioslabka = ioslabka.overlay;
        cfgeq    = self: super: { cfgeq = cfgeq.defaultPackage.${system}; };

        zsh-vim-mode = self: super: {
          zsh-vim-mode = { name = "zsh-vim-mode"; src = zsh-vim-mode; };
        };

        alacritty-ligatures = self: super: {
          alacritty = super.alacritty.overrideAttrs (old: rec {
            src = super.fetchFromGitHub {
              owner = "zenixls2";
              repo = "alacritty";
              rev = "3ed043046fc74f288d4c8fa7e4463dc201213500";
              sha256 = "sha256-1dGk4ORzMSUQhuKSt5Yo7rOJCJ5/folwPX2tLiu0suA=";
            };
            version = "ligatures-git";
            cargoDeps = old.cargoDeps.overrideAttrs (oldDeps: {
              inherit src;
              outputHash = "sha256-tY5sle1YUlUidJcq7RgTzkPsGLnWyG/3rtPqy2GklkY=";
            });
            buildInputs = (old.buildInputs or []) ++ (with super; [
              stdenv.cc.cc.lib
            ]);
            postInstall = (old.postInstall or "") + ''
              patchelf --add-rpath "${super.lib.makeLibraryPath
                [ super.stdenv.cc.cc.lib ]}" $out/bin/alacritty
            '';
          });
        };

        # Adds all inputs into pkgs.flakeInputs for ease of access anywhere.
        flakeInputs = self: super: { flakeInputs = inputs; };
      };

    in {

      # Forward inputs for easier debugging. To access each input simply use
      # .#inputs.[input].
      inherit inputs;

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
              flakeInputs # Give the rest access to pkgs.flakeInputs.
              cpufreq-plugin ioslabka
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
              flakeInputs # Give the rest access to pkgs.flakeInputs.
              alacritty-ligatures
              cfgeq
              cpufreq-plugin
              sioyek
              zsh-vim-mode
            ];
          };
        };
    };
}
