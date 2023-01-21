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

    secrets-CH-21NS = { url = "/persist/CH-21NS/secrets.nix"; flake = false; };
    secrets-CH-22I = { url = "/persist/CH-22I/secrets.nix"; flake = false; };

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

      overlays = with inputs; {
        cpufreq-plugin =
          import pkgs/cpufreq-plugin/overlay.nix inputs.cpufreq-plugin;

        ioslabka = ioslabka.overlay;
        cfgeq    = self: super: { cfgeq = cfgeq.defaultPackage.${system}; };

        zsh-vim-mode = self: super: {
          zsh-vim-mode = { name = "zsh-vim-mode"; src = zsh-vim-mode; };
        };

        # Provide a "not insecure" Python 2 to packages that desperately need it
        # for now. See #14. Shouldn't be too bad since nixpkgs is now using
        # ActiveState's fork, I suppose...?
        python2 = self: super:
          let
            # Package set with Python 2's known vulnerability removed. We assert
            # that the old meta.knownVulnerabilities is as we expect it to be,
            # in case there are more added/changed that we shouldn't
            # automatically ignore.
            expectedKnownVuln = [
              "Python 2.7 has reached its end of life after 2020-01-01. See https://www.python.org/doc/sunset-python-2/."
            ];
            pkgs' = import nixpkgs {
              inherit (super) system config;
              overlays = [ (self: super: {
                python27 = super.python27.overrideAttrs
                  (old:
                    assert old.meta.knownVulnerabilities == expectedKnownVuln;
                    super.lib.recursiveUpdate old
                      { meta.knownVulnerabilities = []; });
              }) ];
            };
          in {
            # Our GIMP plugins need Python 2 support.
            gimp = super.gimp.override {
              withPython = true;
              python2 = pkgs'.python2;
            };
            # mozc needs Python 2 to build.
            fcitx-engines = super.fcitx-engines // {
              mozc = super.fcitx-engines.mozc.override {
                python = pkgs'.python2;
                inherit (pkgs'.python2Packages) gyp;
              };
            };
          };

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
      hosts = [ "CH-21NS" "CH-22I" ];

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
          }) hosts);

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
                  vim-nix-fenced-syntax
                  vim-orgmode-plugins
                  zsh-vim-mode
                  python2 # Python 2 marked insecure #14
                ];
                inherit host;
                inherit ((import ./lib {}).me) home;
              })
            ];
            extraSpecialArgs = { inherit inputs; };
          };
        }) hosts);
    };
}
