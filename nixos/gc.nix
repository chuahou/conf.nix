# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  nix.gc = {
    # automatically garbage collect 2 weeks-old things every day
    automatic = true;
    dates     = "daily";
    options   = "--delete-older-than 14d";
  };

  # automatically free up to 5 GiB when we reach only 1 GiB of free space
  nix.extraOptions = ''
    min-free = ${toString (1 * 1024 * 1024 * 1024)}
    max-free = ${toString (5 * 1024 * 1024 * 1024)}
  '';
}
