# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ vimUtils
, src
}:

vimUtils.buildVimPlugin {
  name = "Ionide-vim";
  inherit src;

  # We only want the syntax file
  dontBuild = true;
  postInstall = ''
    # Delete all .vim files except syntax and ftdetect file
    find $target \
      \( -path $target/syntax -o -path $target/ftdetect \) \
      -prune -false -o \
      -name '*.vim' -exec rm {} \;
  '';
}
