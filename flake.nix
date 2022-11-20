# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  inputs = {
    nixpkgs        = { url = "nixpkgs/nixos-unstable"; };
    nixpkgs-stable = { url = "nixpkgs/nixos-22.05"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rice = { url = "github:bertof/nix-rice"; flake = false; };
    impermanence = { url = "github:nix-community/impermanence"; };

    secrets-CH-21NS = { url = "/persist/CH-21NS/secrets.nix"; flake = false; };
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

    # orgmode and friends
    orgmode = { url = "github:nvim-orgmode/orgmode"; flake = false; };
    nvim-treesitter = { url = "github:nvim-treesitter/nvim-treesitter"; flake = false; };
    tree-sitter-org = { url = "github:milisims/tree-sitter-org"; flake = false; };
  };

  outputs =
    inputs@{
      self, nixpkgs, nixos-hardware, home-manager, ...
    }:
    let
      system = "x86_64-linux";
      pkgs   = nixpkgs.legacyPackages.${system};

      overlays = with inputs; {
        cpufreq-plugin =
          import pkgs/cpufreq-plugin/overlay.nix inputs.cpufreq-plugin;

        ioslabka = ioslabka.overlay;
        cfgeq    = self: super: { cfgeq = cfgeq.defaultPackage.${system}; };

        zsh-vim-mode = self: super: {
          zsh-vim-mode = { name = "zsh-vim-mode"; src = zsh-vim-mode; };
        };

        # Packages to overlay from a stable branch to avoid bugs and the like.
        stable = self: super:
          let pkgs = import nixpkgs-stable { inherit (super) config system; };
          in {
            # Currently unneeded.
            # inherit (pkgs) some-pkg;
          };

        # Syncing up org parser versions for nvim-orgmode/orgmode and
        # tree-sitter-org.
        vim-orgmode-plugins = self: super: {
          vimPlugins = super.vimPlugins // (with super.vimPlugins; {
            orgmode = orgmode.overrideAttrs (old: {
              src = inputs.orgmode;
            });
            nvim-treesitter = nvim-treesitter.overrideAttrs (old: {
              src = inputs.nvim-treesitter;
            });
          });
          # We assert in this derivation that the expected revisions match.
          tree-sitter-org =
            let
              actualRev = inputs.tree-sitter-org.rev;
              ntsExpected = (super.lib.importJSON
                "${inputs.nvim-treesitter}/lockfile.json").org.revision;
              orgmodeExpected = builtins.readFile
                (super.runCommand "orgmodeExpectedRev" {} ''
                  sed -n -e "2s/^local ts_revision = '\([^']\+\)'$/\1/p" \
                      ${inputs.orgmode}/lua/orgmode/init.lua \
                      | tr -d '\n' > $out
                '');
            in
              assert actualRev == ntsExpected;
              assert actualRev == orgmodeExpected;
              super.tree-sitter-grammars.tree-sitter-org-nvim.overrideAttrs (old: {
                src = inputs.tree-sitter-org;
              });
        };
      };

      # Hosts to generate configs over.
      hosts = [ "CH-21NS" "CH-22T" ];

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

      homeConfigurations =
        builtins.listToAttrs (builtins.map (host: {
          name = host;
          value = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ (import ./home {
              overlays = with overlays; [
                stable
                cfgeq
                cpufreq-plugin
                vim-orgmode-plugins
                zsh-vim-mode
              ];
              inherit host;
              inherit ((import ./lib {}).me) home;
            }) ];
            extraSpecialArgs = { inherit inputs; };
          };
        }) hosts);
    };
}
