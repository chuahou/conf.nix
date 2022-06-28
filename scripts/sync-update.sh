#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou
#
# Syncs and updates build to current repository status.

# update channel
sudo nix-channel --update

# upgrade NixOS, home and nix-env packages
sudo nixos-rebuild switch --flake $(dirname $0)/..#
home-manager switch --flake $(dirname $0)/..#$(hostname)
$(dirname $0)/nix-env.sh -u
