# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ stdenv
, stdenvNoCC
, fetchgit
, fetchhg
, fetchsvn
, fetchurl
, lib
, php
, phpPackages
, unzip
, writeShellScriptBin
, writeTextFile
, src
}:

let
  composerEnv = import ./composer-env.nix {
    inherit stdenv lib writeTextFile fetchurl php unzip phpPackages;
  };
  php-package = import ./php-packages.nix {
    inherit composerEnv;
    noDev = false;
    inherit fetchurl fetchgit fetchhg fetchsvn;
    src = stdenvNoCC.mkDerivation {
      pname   = "source";
      version = "patched";
      inherit src;
      dontBuild         = true;
      dontConfigure     = true;
      dontPatchShebangs = true;
      patchPhase        = "cp ${./composer.lock} ./composer.lock";
      installPhase      = "cp -r . $out";
    };
  };

in
  writeShellScriptBin "php-language-server" ''
    ${php}/bin/php ${php-package}/bin/php-language-server.php $@
  ''
