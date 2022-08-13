# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, inputs, ... }:

{
  home.packages = [ pkgs.texlive.combined.scheme-full ];
  home.file."texmf/tex/latex/local".source = inputs.latex-sty;
}
