# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, ... }:

let
  inherit (import ../lib/gui/scripts.nix { inherit config pkgs; })
    xconfigScript lockScript;
in
  {
    home.packages = [
      # shell script that does all X-related configuration
      xconfigScript
      lockScript
    ];

    xsession = {
      enable = true;
      scriptPath = ".hm-xsession";

      initExtra = ''
        ${xconfigScript}/bin/xconfig.sh
      '';

      windowManager.i3 =
        let
          # use Alt as mod key
          mod   = "Mod1";
          super = "Mod4";

          # direction keys
          left  = "h";
          down  = "j";
          up    = "k";
          right = "l";

          # resize mode
          resizeMode = "Resize Mode";
          resizeKey  = "${mod}+r";

          # end session mode
          endMode     = "End Session  [mod+${endLogout}] logout [mod+${endShutdown}] shutdown  [mod+${endRestart}] restart";
          endLogout   = "l";
          endShutdown = "p";
          endRestart  = "r";
          endKey      = "${mod}+Shift+e";

          # programs
          rofi = "${config.programs.rofi.package}/bin/rofi";

        in
          {
            enable = true;
            extraConfig = ''
              default_border          pixel 2
              default_floating_border pixel 2
            '';
            config = {
              # basics
              #bars              = [];
              focus.followMouse = false;
              modifier          = mod;

              # appearance
              colors =
                let
                  colours = (import ../lib/gui/colours.nix);
                in
                  rec {
                    focused = {
                      border      = colours.red;
                      background  = colours.gray."2";
                      text        = colours.gray."7";
                      indicator   = colours.blue;
                      childBorder = colours.red;
                    };
                    focusedInactive = {
                      border      = colours.gray."4";
                      background  = colours.gray."1";
                      text        = colours.gray."4";
                      indicator   = colours.gray."1";
                      childBorder = colours.gray."4";
                    };
                    unfocused = {
                      inherit (focusedInactive) border background text indicator
                        childBorder;
                    };
                    urgent = {
                      border      = colours.gray."0";
                      background  = colours.red;
                      text        = colours.gray."7";
                      indicator   = colours.red;
                      childBorder = colours.gray."0";
                    };
                  };
              fonts = [ "Iosevka Medium 14" ];
              gaps = {
                inner = 8;
                outer = 2;
              };

              # floating windows
              floating = {
                modifier = mod;
                criteria = [
                  { class = "Blueman-manager"; }
                  { class = "Pavucontrol";     }
                  { title = "floatthis";       }
                ];
              };

              # startup
              startup = [
                { command = "i3-msg workspace 1"; notification = false; }
              ];

              # keybindings
              keybindings = {
                # window navigation
                "${mod}+Tab"     = "focus mode_toggle";
                "${mod}+a"       = "focus parent";
                "${mod}+Shift+a" = "focus child";

                # multiple monitors
                "${mod}+m"       = "move workspace to output right";
                "${mod}+Shift+m" = "move workspace to output left";

                # scratchpad
                "${mod}+Ctrl+a" = "scratchpad show";
                "${mod}+Ctrl+m" = "move to scratchpad";

                # next window split
                "${mod}+v" = "split vertical";
                "${mod}+c" = "split horizontal";

                # fullscreen/floating
                "${mod}+f"       = "fullscreen toggle";
                "${mod}+Shift+f" = "floating toggle";

                # closing window
                "${mod}+Shift+q" = "[con_id=\"__focused__\"] kill";

                # reload i3 config / restart
                "${mod}+Shift+r" = "reload";
                "${mod}+Ctrl+r"  = "restart";

                # modes
                "${resizeKey}" = "mode \"${resizeMode}\"";
                "${endKey}"    = "mode \"${endMode}\"";

                # launch applications
                "${mod}+space"       = "exec ${rofi} -show drun";
                "${mod}+Shift+space" = "exec ${rofi} -show run";
                "${mod}+Ctrl+space"  = "exec ${rofi} -show window";

                # redo xconfig
                "${mod}+Shift+Ctrl+z" = "exec ${xconfigScript}/bin/xconfig.sh";

                # lock screen
                "${mod}+Shift+Escape" = "exec ${lockScript}/bin/lock.sh --show-failed-attempts";

                # multimedia controls
                "XF86MonBrightnessUp"   = "exec ${pkgs.light}/bin/light -A 10";
                "XF86MonBrightnessDown" = "exec ${pkgs.light}/bin/light -U 10";
              } //

              # workspace navigation
              (builtins.foldl' (x: y: x // y) {}
                (builtins.genList (x:
                  let
                    key = builtins.toString x;
                    ws  = if x == 0 then "10" else key;
                  in
                    {
                      "${mod}+${key}"       = "workspace number ${ws}";
                      "${mod}+Shift+${key}" = "move container to workspace number ${ws}";
                      "${mod}+Ctrl+${key}"  = "move container to workspace number ${ws}; workspace number ${ws}";
                    }) 10)) //

              # window navigation
              (builtins.foldl' (x: y: x // y) {}
                (builtins.attrValues (builtins.mapAttrs (key: dirn: {
                  "${mod}+${key}"       = "focus ${dirn}";
                  "${mod}+Shift+${key}" = "move ${dirn}";
                }) {
                  "${left}"  = "left";
                  "${down}"  = "down";
                  "${up}"    = "up";
                  "${right}" = "right";
                })));

              modes = {
                "${resizeMode}" = {
                  "Escape"       = "mode \"default\"";
                  "Return"       = "mode \"default\"";
                  "${resizeKey}" = "mode \"default\"";
                } //
                (builtins.foldl' (x: y: x // y) {}
                    (builtins.attrValues (builtins.mapAttrs (key: dirn: {
                      "${key}"       = "resize ${dirn} 6 px or 6 ppt";
                      "Shift+${key}" = "resize ${dirn} 36 px or 36 ppt";
                      "Ctrl+${key}"  = "resize ${dirn} 3 px or 3 ppt";
                    }) {
                      "${left}"  = "shrink width";
                      "${down}"  = "grow height";
                      "${up}"    = "shrink height";
                      "${right}" = "grow width";
                    })));

                "${endMode}" = {
                  "${mod}+${endLogout}"   = "exec i3-msg exit";
                  "${mod}+${endShutdown}" = "exec systemctl poweroff";
                  "${mod}+${endRestart}"  = "exec systemctl reboot";
                  "Escape"                = "mode \"default\"";
                  "Return"                = "mode \"default\"";
                  "${endKey}"             = "mode \"default\"";
                };
              };
            };
          };
    };
  }
