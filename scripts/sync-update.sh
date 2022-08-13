#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou
#
# Syncs and updates build to current repository status.

# upgrade NixOS, home and nix-env packages
sudo nixos-rebuild switch --flake $(dirname $0)/..#
home-manager switch --flake $(dirname $0)/..#$(hostname)
nix-env -u
