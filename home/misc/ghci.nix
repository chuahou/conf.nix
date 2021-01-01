# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

# ghci configuration file

{ ... }:

{
  home.file.".ghci".text = ''
    :set prompt "\ESC[1;34m%s\n\ESC[0;34mλ> \ESC[m"
  '';
}
