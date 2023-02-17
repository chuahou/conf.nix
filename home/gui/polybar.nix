# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, lib, ... }:

{
  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      i3Support = true;
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

        mkIpcPair = name: interval: ipc:
          let
            hook = "polybar-msg action ${name}_ipc hook.0";
          in {
            "module/${name}" = {
              type  = "custom/script";
              exec  = hook;
              label = "";
              inherit interval;
            };
            "module/${name}_ipc" = { type = "custom/ipc"; } // ipc hook;
          };

        launchTerminal = command:
          "${pkgs.wezterm}/bin/wezterm start -- ${command} & disown";

        launchTerminalWatch = command:
          launchTerminal "${pkgs.procps}/bin/watch -n 2 ${command}";

      in {
        "bar/main" = {
          width              = "100%";
          height             = 30;
          fixed-center       = true;
          font-0             = "Iosevka:pixelsize=12;3";
          font-1             = "Iosevka:pixelsize=13;2";
          font-2             = "Iosevka Fixed:pixelsize=12;3";
          line-size          = 2;
          line-color         = foreground;
          tray-position      = "right";
          padding            = 1;
          module-margin-left = 1;
          enable-ipc         = true;
          modules-left       = "battery fs mem maxtemp cpu";
          modules-center     = "i3";
          modules-right      = "dropbox dnd dnd_ipc sound_ipc sound cpufreq_ipc cpufreq date";
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
          label-charging                = "ac %percentage%% %{T3}⇡%{T-} %consumption%W %time%";
          label-discharging             = "dc %percentage%% %{T3}⇣%{T-} %consumption%W %time%";
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
          inherit format-padding;
        };

        "module/maxtemp" = {
          type              = "custom/script";
          exec              = "${pkgs.lm_sensors}/bin/sensors | ${pkgs.gnused}/bin/sed -n 's/^[^(]*+\\([0-9]\\+\\)\\.[0-9]°C.*/\\1/p' | ${pkgs.coreutils-full}/bin/sort -r | ${pkgs.coreutils-full}/bin/head -n 1";
          label             = "temp %output%°C";
          format-background = colours.gray.red;
          format-underline  = colours.red;
          interval          = 1;
          click-left        = launchTerminalWatch "${pkgs.lm_sensors}/bin/sensors";
          inherit format-padding;
        };

        "module/cpu" = {
          type              = "internal/cpu";
          format            = "cpu <label>";
          format-background = colours.gray.magenta;
          format-underline  = colours.magenta;
          inherit format-padding;
        };

        "module/dropbox" = {
          type = "custom/script";
          exec = "${pkgs.writeShellScriptBin "polybar-dropbox" ''
            echo -n "dropbox"
            case $(${pkgs.dropbox-cli}/bin/dropbox status 2> /dev/null |
                ${pkgs.coreutils}/bin/head -n 1 |
                ${pkgs.gawk}/bin/awk '{ print $1 }') in
              Up)         echo ""         ;;
              Syncing)    echo " syncing" ;;
              Syncing...) echo " syncing" ;;
              *)          echo " ???"     ;;
            esac
          ''}/bin/polybar-dropbox";
          interval          = 5;
          format-background = colours.gray.blue;
          format-underline  = colours.blue;
          click-left        = launchTerminalWatch "${pkgs.dropbox-cli}/bin/dropbox status";
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
      } //

      mkIpcPair "cpufreq" 60
        (let
          cpufreq-plugin = "${pkgs.cpufreq-plugin-wrapped}/bin/cpufreq-plugin";
          sed            = "${pkgs.gnused}/bin/sed";
        in (hook: {
          hook-0            = "${cpufreq-plugin} | ${sed} 's/powersave/save/' | ${sed} 's/performance/perf/'";
          click-left        = "sudo ${cpufreq-plugin} gov; ${hook}";
          scroll-up         = "sudo ${cpufreq-plugin} increase 500; ${hook}";
          scroll-down       = "sudo ${cpufreq-plugin} decrease 500; ${hook}";
          format-background = colours.gray.red;
          format-underline  = colours.red;
          inherit format-padding;
        })) //

      mkIpcPair "sound" 10
        (let
          script =
            (import ../lib/gui/scripts.nix { inherit config pkgs lib; }).volumeScript;
          scriptBin = "${script}/bin/volume.sh";
        in (hook: {
          hook-0            = scriptBin;
          click-left        = "${scriptBin} sink; ${hook}";
          click-middle      = "${scriptBin} mute; ${hook}";
          click-right       = "${pkgs.pavucontrol}/bin/pavucontrol & disown";
          scroll-up         = "${scriptBin} volup; ${hook}";
          scroll-down       = "${scriptBin} voldn; ${hook}";
          format-background = colours.gray.yellow;
          format-underline  = colours.yellow;
          inherit format-padding;
        })) //

      mkIpcPair "dnd" 60 (hook:
        let
          script =
            (import ../lib/gui/scripts.nix { inherit config pkgs lib; }).dndScript;
          scriptBin = "${script}/bin/donotdisturb.sh";
        in {
          hook-0            = scriptBin;
          click-left        = "${scriptBin} toggle; ${hook}";
          format-background = colours.gray.magenta;
          format-underline  = colours.magenta;
          inherit format-padding;
        });

    # The systemd unit script "polybar-start" will fork and call the inner
    # script "polybar-start-i3-ipc" (otherwise the session will block waiting
    # for this to execute, and i3 cannot start properly!). The inner script
    # waits for i3 to start before executing polybar, and also forks a process
    # that calls each IPC module at startup to make them appear for the first
    # time.
    script =
      let
        i3 = config.xsession.windowManager.i3.package;
        cfg = builtins.attrNames config.services.polybar.config;
        mods = builtins.filter (lib.hasPrefix "module/") cfg;
        ipcs = builtins.filter (lib.hasSuffix "_ipc") mods;
        script = pkgs.writeShellScript "polybar-start-i3-ipc" ''
          until ${i3}/bin/i3 --get-socket; do ${pkgs.coreutils}/bin/sleep 1; done
          (
              until polybar-msg cmd show; do ${pkgs.coreutils}/bin/sleep 1; done
              ${lib.concatMapStringsSep "\n${pkgs.coreutils}/bin/sleep 1\n"
                (ipc: ''
                  until polybar-msg action ${lib.removePrefix "module/" ipc} hook.0; do
                    ${pkgs.coreutils}/bin/sleep 1; done
                '') ipcs}
          ) &
          exec polybar main # Must be exec! Otherwise polybar will be killed.
        '';
      in "${script} &";
  };
}
