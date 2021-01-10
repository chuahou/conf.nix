# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  inputs = {
    nixpkgs.url        = "nixpkgs/nixos-20.09";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    secrets.url   = "/home/sgepk/dev/secrets.nix";
    secrets.flake = false;
  };

  outputs = { self, nixpkgs, nixos-hardware, secrets }: {

    nixosConfigurations.CH-21N = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # enable nix flakes
        ({ pkgs, ... }: {
          nix = {
            package      = pkgs.nixFlakes;
            extraOptions = "experimental-features = nix-command flakes";
          };
        })

        # main NixOS configuration
        (import nixos/configuration.nix (import secrets))

        # nixos-hardware tweaks
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-laptop-ssd
      ];
    };

  };
}
