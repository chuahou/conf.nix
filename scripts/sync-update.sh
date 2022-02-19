#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Syncs and updates build to current repository status.

# update channel
sudo nix-channel --update

# upgrade NixOS, home and nix-env packages
sudo nixos-rebuild switch --flake $(dirname $0)/..#
$(dirname $0)/home-switch.sh
$(dirname $0)/nix-env.sh -u
