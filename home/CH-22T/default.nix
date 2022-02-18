# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ lib, ... }:

{
  # Polybar changes due to system differences.
  services.polybar.config = {
    "module/battery".battery = lib.mkForce "BAT1";
    "module/fshd" = lib.mkForce {};
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";
}
