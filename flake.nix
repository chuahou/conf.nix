# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  inputs = {
    nixpkgs        = { url = "nixpkgs/nixos-unstable"; };
    nixpkgs-stable = { url = "nixpkgs/nixos-21.11"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rice = { url = "github:bertof/nix-rice"; flake = false; };
    impermanence = { url = "github:nix-community/impermanence"; };

    secrets-CH-21N = { url = "/persist/CH-21N/secrets.nix"; flake = false; };
    secrets-CH-22T = { url = "/persist/CH-22T/secrets.nix"; flake = false; };

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

        # Packages to overlay from a stable branch to avoid bugs and the like.
        stable = self: super:
          let pkgs = import nixpkgs-stable { inherit (super) config system; };
          in {
            inherit (pkgs) steam-run;
          };

        # Use steam-run instead for FDR.
        fdr = self: super: {
          fdr = super.fdr.overrideAttrs (old: {
            libPath = [];
            dontPatchELF = true;
            installPhase = ''
              mkdir -p $out/old
              cp -r * $out/old
              mkdir -p $out/bin
              for b in fdr4 _fdr4 refines _refines cspmprofiler cspmexplorerprof
              do
                  cat << EOF > $out/bin/$b
                      #!${super.runtimeShell}
                      ${super.steam-run}/bin/steam-run $out/old/bin/$b \$@
              EOF
                  chmod +x $out/bin/$b
              done
            '';
          });
        };

        # Adds all inputs into pkgs.flakeInputs for ease of access anywhere.
        flakeInputs = self: super: { flakeInputs = inputs; };
      };

      # Hosts to generate configs over.
      hosts = [ "CH-21N" "CH-22T" ];

    in {

      # Forward inputs for easier debugging. To access each input simply use
      # .#inputs.[input].
      inherit inputs;

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
                  flakeInputs # Give the rest access to pkgs.flakeInputs.
                  stable
                  cpufreq-plugin ioslabka
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
          }) hosts);

      hmConfigs =
        let
          inherit ((import ./lib {}).me) home;
        in
          builtins.listToAttrs (builtins.map (host: {
            name = "${host}-${home.username}";
            value = home-manager.lib.homeManagerConfiguration {
              inherit system;
              inherit (home) username homeDirectory;
              configuration = import ./home {
                overlays = with overlays; [
                  flakeInputs # Give the rest access to pkgs.flakeInputs.
                  stable
                  cfgeq
                  cpufreq-plugin
                  fdr
                  sioyek
                  zsh-vim-mode
                ];
                inherit host;
              };
              stateVersion = builtins.getAttr host {
                "CH-21N" = "20.09";
                "CH-22T" = "21.11";
              };
            };
          }) hosts);
    };
}
