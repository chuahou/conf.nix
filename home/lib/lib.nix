# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

# common shared functions
{
  importFolder = folder:
    builtins.map (file: folder + "/${file}")
      (builtins.attrNames (builtins.readDir folder));
}
