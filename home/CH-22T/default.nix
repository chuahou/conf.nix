# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, lib, ... }:

{
  # Polybar changes due to system differences.
  services.polybar.config = let colours = import ../lib/gui/colours.nix; in {
    "module/battery".battery = lib.mkForce "BAT1";
    "module/fshd" = lib.mkForce {};

    # Additional fan level module.
    # For some reason lib.mkAfter doesn't work with home-manager, hence this
    # copy-paste. :(
    "bar/main".modules-left = lib.mkForce "battery fs fshd mem maxtemp cpu fanlevel";
    "module/fanlevel" = {
      type = "custom/script";
      exec = "${pkgs.coreutils-full}/bin/cat /proc/acpi/ibm/fan | ${pkgs.gnused}/bin/sed -n 's/level:\\s\\+\\([^\\s]\\+\\)/\\1/p'";
      label = "fan level %output%";
      format-background = colours.gray.white;
      format-underline = colours.white;

      # Sadly these two are hardcoded since we don't have access to the let
      # expressions in ../gui/polybar.nix.
      format-padding = 1;
      click-left = "${pkgs.wezterm}/bin/wezterm start -- ${pkgs.systemd}/bin/journalctl -fu thinkfan";
    };
  };

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

  # Smaller font on alacritty to counter increased DPI.
  programs.alacritty.settings = {
    font = {
      size = lib.mkForce 12.0;
      offset.x = lib.mkForce (-2.0);
    };
    window.padding = lib.mkForce rec { x = 20; y = x; };
  };

  # Override wezterm config to accommodate smaller screen.
  xdg.configFile."wezterm/override.lua".text = ''
    return function(config)
        -- Make font size smaller for smaller screen.
        config["font_size"] = 12.0;
        config["line_height"] = 1.3;
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
  home.stateVersion = "21.11";
}
