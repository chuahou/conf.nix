# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ pkgs, ... }:

{
  services.pcscd.enable = true;
  services.udev.packages = with pkgs; [ yubikey-personalization ];
  environment.systemPackages = with pkgs; [
    yubikey-manager yubikey-manager-qt
  ];

  # Allow Firefox to access the Yubikey for webauthn.
  services.udev.extraRules = ''
    ACTION!="add|change", GOTO="yubico_end"
    # Yubico Yubikey II
    ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", \
        ENV{ID_SECURITY_TOKEN}="1", GROUP="yubikey-access"
    LABEL="yubico_end"
  '';
  users.users.firefox.extraGroups = [ "yubikey-access" ];
  users.groups.yubikey-access = {};
}
