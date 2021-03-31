# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ vimUtils
, src
}:

vimUtils.buildVimPlugin {
  name = "instant-markdown";
  inherit src;
}
