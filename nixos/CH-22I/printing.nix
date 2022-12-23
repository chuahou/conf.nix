# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ lib, ... }:

{
  # Use department CUPS server for printing.
  services.printing.clientConf = ''
    ServerName cups.cs.ox.ac.uk
  '';
}
