# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, ... }:

{
  home.packages = [ pkgs.cpufreq-plugin-wrapped ];

  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      i3GapsSupport = true;
    };

    config =
      let
        colours         = import ../lib/gui/colours.nix;
        background      = colours.gray."0";
        background-alt  = colours.gray."1";
        background-alt2 = colours.gray."2";
        foreground      = colours.gray."5";
        foreground-alt  = colours.gray."4";
        foreground-alt2 = colours.gray."3";
        good            = colours.green;
        caution         = colours.yellow;
        bad             = colours.red;
        other           = colours.blue;
        format-padding  = 1;
      in {
        "bar/main" = {
          width              = "100%";
          height             = 30;
          fixed-center       = true;
          font-0             = "Iosevka:pixelsize=12;3";
          font-1             = "Iosevka:pixelsize=13;2";
          line-size          = 2;
          line-color         = foreground;
          tray-position      = "right";
          padding            = 1;
          module-margin-left = 1;
          enable-ipc         = true;
          modules-left       = "battery fs mem maxtemp cpu";
          modules-center     = "i3";
          modules-right      = "date"; # "dnd dnd_ipc nordvpn nordvpn_ipc sound_ipc sound cpufreq_ipc cpufreq date";
          inherit background foreground format-padding;
        };

        "module/i3" = rec {
          # behaviour
          type                       = "internal/i3";
          format                     = "<label-state> <label-mode>";
          index-sort                 = true;
          wrapping-scroll            = true;
          strip-wsnumbers            = true;

          # mode display
          label-mode-padding         = 1;
          label-mode-background      = colours.red;

          # workspace display
          label-focused              = "%{T2}:%name%%{T-}";
          label-unfocused            = "%{T2}.%name%%{T-}";
          label-visible              = "%{T2}.%name%%{T-}";
          label-urgent               = "%{T2}!%name%%{T-}";
          label-focused-underline    = colours.gray."5";
          label-focused-background   = colours.blue;
          label-unfocused-background = background-alt;
          label-visible-background   = label-unfocused-background;
          label-urgent-background    = colours.red;
          label-focused-padding      = 1;
          label-unfocused-padding    = label-focused-padding;
          label-visible-padding      = label-focused-padding;
          label-urgent-padding       = label-focused-padding;
        };

        "module/battery" = rec {
          type                          = "internal/battery";
          time-format                   = "%H:%M";
          battery                       = "BAT0";
          adapter                       = "AC";
          format-charging-padding       = format-padding;
          format-discharging-padding    = format-charging-padding;
          format-full-padding           = format-charging-padding;
          format-charging-background    = colours.gray.yellow;
          format-charging-underline     = colours.yellow;
          format-discharging-background = colours.gray.red;
          format-discharging-underline  = colours.red;
          format-full-background        = colours.gray.green;
          format-full-underline         = colours.green;
          bar-capacity-width            = 4;
          label-charging                = "ac %percentage%% %{T3}⇡%{T-} %time%";
          label-discharging             = "dc %percentage%% %{T3}⇣%{T-} %time%";
          label-full                    = "ac FULL";
        };

        "module/fs" = {
          type                      = "internal/fs";
          mount-0                   = "/";
          label-mounted             = "fs %used% / %total%";
          format-mounted-underline  = colours.blue;
          format-mounted-background = colours.gray.blue;
          format-mounted-padding    = format-padding;
        };

        "module/mem" = {
          type              = "internal/memory";
          format            = "<label>";
          label             = "mem %gb_used%";
          format-background = colours.gray.green;
          format-underline  = colours.green;
          format-padding    = 1;
        };

        "module/maxtemp" = {
          type              = "custom/script";
          exec              = "${pkgs.lm_sensors}/bin/sensors | ${pkgs.gnused}/bin/sed -n 's/^[^(]*+\\([0-9]\\+\\)\\.[0-9]°C.*/\\1/p' | ${pkgs.coreutils-full}/bin/sort -r | ${pkgs.coreutils-full}/bin/head -n 1";
          label             = "temp %output%°C";
          format-background = colours.gray.red;
          format-underline  = colours.red;
          interval          = 1;
          click-left        = "${config.programs.alacritty.package}/bin/alacritty -e ${pkgs.procps}/bin/watch -n 2 ${pkgs.lm_sensors}/bin/sensors & disown";
          inherit format-padding;
        };

        "module/cpu" = {
          type              = "internal/cpu";
          format            = "cpu <label>";
          format-background = colours.gray.magenta;
          format-underline  = colours.magenta;
          inherit format-padding;
        };

        "module/date" = {
          type              = "internal/date";
          date              = "%a %m/%d";
          time              = "%H:%M:%S";
          label             = "%date% %time%";
          format-background = colours.gray.white;
          format-underline  = colours.white;
          inherit format-padding;
        };
      };

    script = ''
      polybar main &

      #sleep 1
      #for ipc in dnd_ipc nordvpn_ipc sound_ipc cpufreq_ipc; do
      #  polybar-msg hook $ipc 1; sleep 1
      #done
    '';
  };
}
