# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  services.picom = {
    enable  = true;
    backend = "xrender";

    # inactive windows
    inactiveDim = "0.03";

    # fading
    fade      = true;
    fadeDelta = 5;
    fadeSteps = [ "0.05" "0.05" ];

    # vsync
    vSync = true;

    # custom application opacities
    opacityRule = [
      "88:class_g *?= 'zathura'"
      "90:class_g *?= 'rofi'"
    ];

    extraOptions = ''
      dbe = true;
      no-fading-openclose = false;
      detect-client-opacity = true; # detect _NET_WM_OPACITY;
      mark-wmwin-focused = true; # try to detect WM windows and mark them as active
      mark-ovredir-focused = true; # mark override-redirect windows active
      use-ewmh-active-win = true; # use EWMH to determine focused window
      detect-transient = true; # use WM_TRANSIENT_FOR to group windows and focus all
      detect-client-leader = true; # use WM_CLIENT_LEADER to group windows
    '';
  };
}
