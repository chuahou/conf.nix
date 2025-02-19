#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022, 2023 Chua Hou
#
# Syncs and updates build to current repository status.

set -euo pipefail

FLAKE_PATH=$(dirname $0)/..
nom build \
	$FLAKE_PATH#nixosConfigurations.$(hostname).config.system.build.toplevel
nix-shell -p libnotify --run 'notify-send "sudo required"'
sudo nixos-rebuild switch --flake $FLAKE_PATH#
nix-env -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$(
	jq ".nodes.$(
		jq '.nodes.root.inputs.nixpkgs' $FLAKE_PATH/flake.lock -r).locked.rev" \
			$FLAKE_PATH/flake.lock -r).tar.gz -u
