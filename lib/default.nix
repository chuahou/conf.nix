# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Common shared functions and variables.

{ lib ? {} }:

rec {
  # import entire folder's expressions
  importFolder = folder:
    builtins.map (file: folder + "/${file}")
      (builtins.attrNames (builtins.readDir folder));

  # produce export statement exporting the 'bin' folders of each of the input
  # 'pkgs' prepended to $PATH
  addToPath = addToPath' true;

  # produce export statement exporting the 'bin' folders of each of the input
  # 'pkgs' replacing $PATH
  mkPath = addToPath' false;

  # internal
  addToPath' = prepend: paths: ''
    export PATH=${
      lib.concatMapStringsSep ":" (pkg: "${pkg}/bin") paths
    }${if prepend then ":$PATH" else ""}
  '';

  # information about me
  me = import ./me.nix;
}
