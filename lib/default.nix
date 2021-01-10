# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Common shared functions and variables.

{
  # import entire folder's expressions
  importFolder = folder:
    builtins.map (file: folder + "/${file}")
      (builtins.attrNames (builtins.readDir folder));

  # information about me
  me = import ./me.nix;
}
