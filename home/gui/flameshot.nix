# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, ... }:

{
  home.packages = [ pkgs.flameshot ];
  xdg.configFile."flameshot/flameshot.ini".text = ''
    [General]
    buttons=@Variant(\0\0\0\x7f\0\0\0\vQList<int>\0\0\0\0\x6\0\0\0\xf\0\0\0\b\0\0\0\n\0\0\0\v\0\0\0\f\0\0\0\r)
    closeAfterScreenshot=false
    disabledTrayIcon=true
    drawColor=#ffff00
    drawThickness=0
    savePath=${config.xdg.userDirs.pictures}
    startupLaunch=false
  '';
}
