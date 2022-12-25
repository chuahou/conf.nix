#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou
#
# Syncs and updates build to current repository status.

# upgrade NixOS, home and nix-env packages
FLAKE_PATH=$(dirname $0)/..
sudo nom build \
	$FLAKE_PATH#nixosConfigurations.$(hostname).config.system.build.toplevel
sudo nixos-rebuild switch --flake $FLAKE_PATH#
nom build $FLAKE_PATH#homeConfigurations.CH-22I.activationPackage
home-manager switch --flake $FLAKE_PATH#$(hostname)
nix-env -f '<nixos>' -u
