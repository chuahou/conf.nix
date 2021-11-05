# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

self: super: {
  intelephense = (super.callPackage ./. {}).intelephense;
}
