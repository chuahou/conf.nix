# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ lib, ... }:

{
  # Default to building as though we were building for CH-22I, but use our own
  # "secrets".
  imports = [ ../CH-22I ];
  networking.hostName = lib.mkForce "ci-common";
}
