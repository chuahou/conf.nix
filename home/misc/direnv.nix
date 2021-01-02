# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

# direnv and lorri integration for nix-shells
{ ... }:

{
  programs.direnv.enable = true;
  services.lorri.enable  = true;
}
