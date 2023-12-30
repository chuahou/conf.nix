#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou
#
# Syncs and updates build to current repository status.

set -euo pipefail

# upgrade NixOS, home and nix-env packages
FLAKE_PATH=$(dirname $0)/..
nom build \
	$FLAKE_PATH#nixosConfigurations.$(hostname).config.system.build.toplevel
notify-send "sudo required"
sudo nixos-rebuild switch --flake $FLAKE_PATH#
nom build $FLAKE_PATH#homeConfigurations.$(hostname).activationPackage
home-manager switch --flake $FLAKE_PATH#$(hostname)
nix-env -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$(
	jq ".nodes.$(
		jq '.nodes.root.inputs.nixpkgs' $FLAKE_PATH/flake.lock -r).locked.rev" \
			$FLAKE_PATH/flake.lock -r).tar.gz -u
