# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

src: self: super: {
  ionideVim = super.callPackage ./. { inherit src; };
}
