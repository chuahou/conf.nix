# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# direnv and nix-direnv with flakes support.

{ pkgs, ... }:

{
  # nix-direnv needs these options to function correctly, see its readme.
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
