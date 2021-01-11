# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  services.blueman-applet.enable = true;

  home.packages = [ pkgs.dconf ];

  # otherwise blueman-manager will keep prompting for this
  dconf.settings."org/blueman/plugins/powermanager".auto-power-on = false;
}
