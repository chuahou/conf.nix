# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

self: super: {
  tdesktop-bin = super.callPackage ./. {};
}
