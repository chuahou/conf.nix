# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# nix-index support both for nix-index and to replace command-not-found
# functionality.

{ inputs, ... }:

{
  # Use pre-generated database.
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
