# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{
  inputs = {
    nixpkgs        = { url = "nixpkgs/release-20.09"; };
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

    # zsh-vim-mode plugin
    zsh-vim-mode = { url = "github:softmoth/zsh-vim-mode"; flake = false; };

    # cpufreq-plugin
    cpufreq-plugin = { url = "github:chuahou/cpufreq-plugin"; flake = false; };

    # ioslabka
    ioslabka = { url = "github:chuahou/ioslabka.nix"; };

    # latex.sty styles
    latex-sty = { url = "github:chuahou/latex.sty"; flake = false; };

    # ical2orgpy package for org-mode use
    ical2orgpy = { url = "github:asoroa/ical2org.py"; flake = false; };
  };

  outputs =
    inputs@{
      self, nixpkgs, unstable, nixos-hardware, secrets, home-manager, ...
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
            cpufreqPluginOverlay inputs.ioslabka.overlay
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
        latexOverlay = self: super: { inherit (inputs) latex-sty; };
        unstableOverlay = self: super:
          let
            pkgs = import unstable { inherit (super) system config; };
          in {
            inherit (pkgs) alacritty discord syncthing tdesktop;
            inherit (pkgs.vimPlugins) coc-nvim;
          };
        ical2orgOverlay = self: super: {
          ical2orgpy = super.python3Packages.buildPythonPackage rec {
            pname       = "ical2orgpy";
            version     = "0.3+git";
            PBR_VERSION = version;
            src         = inputs.ical2orgpy;
            propagatedBuildInputs = with super.python3Packages; [
              click future icalendar pbr tzlocal
            ];
          };
          ical2orgpy-wrapper = super.writeShellScriptBin "ical2orgpy-wrapper" ''
            set -eu
            icsUrl=$1
            orgPath=$2
            icsPath=$(mktemp)
            # get calendar
            ${self.curl}/bin/curl $icsUrl > $icsPath
            # convert to org
            ${self.ical2orgpy}/bin/ical2orgpy $icsPath $orgPath
            # remove unneeded calendar file
            ${self.coreutils}/bin/rm $icsPath -f
            # make into calendar event
            ${self.gnused}/bin/sed -i -e 's/^  <\([0-9\-]\{10\} [A-Za-z]\{3\} \)\([0-9][0-9]:[0-9][0-9]\)>--<\1\([0-9][0-9]:[0-9][0-9]\)>/<\1\2-\3>/' $orgPath
            # remove recurring tag
            ${self.gnused}/bin/sed -i -e 's/:RECURRING://' $orgPath
          '';
        };
      in home-manager.lib.homeManagerConfiguration {
        inherit system;
        inherit ((import ./lib {}).me.home) username homeDirectory;
        configuration = import ./home {
          overlays = [
            cpufreqPluginOverlay
            ical2orgOverlay
            instantRstOverlay
            latexOverlay
            unstableOverlay
            zshOverlay
          ];
        };
      };

    };
}
