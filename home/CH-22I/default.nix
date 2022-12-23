# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, lib, ... }:

{
  # Load tabs on demand for Firefox due to slower CPU.
  programs.firefox.profiles.${(import ../../lib {}).me.home.username}.settings = {
    "browser.sessionstore.restore_on_demand" = lib.mkForce true;
    "browser.sessionstore.restore_pinned_tabs_on_demand" = lib.mkForce true;
  };

  # Smaller gaps on smaller screen.
  xsession.windowManager.i3.config.gaps = {
    inner = lib.mkForce 4;
    outer = lib.mkForce 4;
  };

  # Override wezterm config to accommodate smaller screen.
  xdg.configFile."wezterm/override.lua".text = ''
    return function(config)
        -- Make font size smaller for smaller screen.
        config["font_size"] = 12.0;
        config["line_height"] = 1.4;
        config["font"]["font"][1]["stretch"] = "Normal";
        return config
    end
  '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";
}
