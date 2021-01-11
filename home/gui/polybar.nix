# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = [ pkgs.cpufreq-plugin-wrapped ];
}
