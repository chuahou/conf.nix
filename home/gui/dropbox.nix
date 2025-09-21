# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Chua Hou

{ inputs, pkgs, ... }:

{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];
  home.packages = with pkgs; [ dropbox ];
  programs.plasma.startup.startupScript.dropbox = {
    text = "dropbox";
    runAlways = true;
  };
}
