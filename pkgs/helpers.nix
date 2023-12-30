# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou
#
# Common shared functions, as an overlay.

self: super:
  let
    # Produce export statement exporting the 'bin' folders of each of the input
    # 'deps', prepending to path if 'prepend' is true and replacing the path
    # otherwise.
    addToPath' = prepend: deps: ''
      export PATH=${
        super.lib.concatMapStringsSep ":" (dep: "${dep}/bin") deps
      }${if prepend then ":$PATH" else ""}
    '';

  in {

    # Scoped to prevent future clashes with pkgs.
    ch = {

      # Produce export statement exporting the 'bin' folders of each of the input
      # 'deps' prepended to $PATH.
      addToPath = addToPath' true;

      # Produce export statement exporting the 'bin' folders of each of the input
      # 'deps' replacing $PATH.
      mkPath = addToPath' false;

      # Prepends either of 'addToPath' if 'prepend' is true, or 'mkPath' otherwise,
      # with each of the dependencies 'deps' to an input script 'infile' with name
      # given by the base name of 'infile'.
      mkScriptWithDeps = { prepend ? true, deps ? [], infile }:
        super.writeShellScriptBin (builtins.baseNameOf infile) ''
          ${addToPath' prepend deps}
          ${builtins.readFile infile}
        '';
    };
  }
