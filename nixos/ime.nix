# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ pkgs, ... }:

{
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      mozc # Japanese
      table table-others # LaTeX etc
    ];
  };
}
