# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Firewall settings disallowing connections originating from specific groups.

{ config, ... }:

let
  group = "nonet";

in {
  users.groups.${group} = {};

  networking.firewall =
  let
    commands = modifyType: ''
      iptables ${modifyType} OUTPUT -m owner --gid-owner ${group} -j REJECT
    '';
  in {
    extraCommands = commands "-A";
    extraStopCommands = commands "-D";
  };

  # Programs to run without internet.
  environment.shellAliases =
  let
    progs = [ "nvim" ];
  in builtins.foldl' (x: y: x // y) {} (builtins.map (prog:
    { ${prog} = "sudo -u $USER -g nonet ${prog}"; }) progs);

  # Allow running without internet to be passwordless.
  security.sudo.extraRules = let user = config.users.users.user.name; in [
    {
      users = [ user ];
      runAs = "${user}:${group}";
      commands = [ { command = "ALL"; options = [ "SETENV" "NOPASSWD" ]; } ];
    }
  ];
}
