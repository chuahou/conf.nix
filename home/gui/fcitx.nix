# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ pkgs, ... }:

{
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };
}
