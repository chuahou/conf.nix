# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = [ pkgs.texlive.combined.scheme-full ];
  home.file."texmf/tex/latex/local".source = pkgs.flakeInputs.latex-sty;
}
