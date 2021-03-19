# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

vimSrc: pySrc: self: super: {
  instantRstVim = super.callPackage ./.      { src = vimSrc; };
  instantRstPy  = super.callPackage ./py.nix { src = pySrc; };
}
