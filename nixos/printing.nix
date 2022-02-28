# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplipWithPlugin ];
    browsedConf = ''
      BrowsePoll cups.cs.ox.ac.uk
      LocalQueueNamingRemoteCUPS RemoteName
    '';
  };
  services.avahi.enable = true;
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };
}
