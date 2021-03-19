# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ haskell
, haskellPackages
, src
}:

haskell.lib.doJailbreak (haskellPackages.callCabal2nix "cpufreq-plugin" src {})
