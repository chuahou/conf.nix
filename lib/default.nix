# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Common shared functions and variables.

{ pkgs ? {}, lib ? {} }:

rec {
  # import entire folder's expressions
  importFolder = folder:
    builtins.map (file: folder + "/${file}")
      (builtins.attrNames (builtins.readDir folder));

  # produce export statement exporting the 'bin' folders of each of the input
  # 'deps' prepended to $PATH
  addToPath = addToPath' true;

  # produce export statement exporting the 'bin' folders of each of the input
  # 'deps' replacing $PATH
  mkPath = addToPath' false;

  # internal
  addToPath' = prepend: deps: ''
    export PATH=${
      lib.concatMapStringsSep ":" (dep: "${dep}/bin") deps
    }${if prepend then ":$PATH" else ""}
  '';

  # prepends either of 'addToPath' if 'prepend' is true, or 'mkPath' otherwise,
  # with each of the dependencies 'deps' to an input script 'infile' with name
  # given by the base name of 'infile'
  mkScriptWithDeps = { prepend ? true, deps ? [], infile }:
    pkgs.writeShellScriptBin (baseNameOf infile) ''
      ${addToPath' prepend deps}
      ${builtins.readFile infile}
    '';

  # information about me
  me = import ./me.nix;
}
