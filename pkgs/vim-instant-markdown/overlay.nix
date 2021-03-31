# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

src: smdvSrc: self: super: {
  vim-instant-markdown = super.callPackage ./.          { src = src; };
  smdv                 = super.callPackage ./server.nix { src = smdvSrc; };
}
