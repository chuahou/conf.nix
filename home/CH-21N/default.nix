# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ pkgs, lib, ... }:

{
  # Picom blur and shadow only for this computer.
  services.picom = {
    package = lib.mkForce pkgs.picom-next;
    backend = lib.mkForce "glx";
    experimentalBackends = lib.mkForce true;

    shadow = lib.mkForce true;
    extraOptions = lib.mkForce ''
      blur:
      {
        method = "dual_kawase";
        strength = 3;
      };
    '';
  };

  # Override wezterm config to accommodate smaller screen.
  xdg.configFile."wezterm/override.lua".text = ''
    return function(config)
        -- Make font size smaller for smaller screen.
        config["font_size"] = 12.5;
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
  home.stateVersion = "20.09";
}
