#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq
# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

nix-env -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$(cat flake.lock |
	jq .nodes.nixpkgs_3.locked.rev | sed 's/^"\(.*\)"$/\1/').tar.gz $@
