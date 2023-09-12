# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, lib, ... }:

let
  inherit (import ../lib/gui/scripts.nix { inherit config pkgs lib; })
    xconfigScript lockScript volumeScript;
  volumeScriptBin = "${volumeScript}/bin/volume.sh";
  soundIpcHook =
    let ipc = "sound_ipc";
    in
      if builtins.hasAttr "module/${ipc}" config.services.polybar.config
      then "polybar-msg action sound_ipc hook.0"
      else "true";
  suspendScript = with pkgs; writeShellScriptBin "suspend-window" ''
    win_id=$(${xdotool}/bin/xdotool getactivewindow)
    win_pid=$(${xdotool}/bin/xdotool getwindowpid $win_id)
    # Check if already suspended.
    if [ $(${procps}/bin/ps -o s= -p $win_pid) = "T" ]; then
        # Already suspended, unsuspend.
        kill -CONT $win_pid
        ${config.services.picom.package}/bin/picom-trans -w $win_id --delete
    else
        # Suspend now.
        kill -STOP $win_pid
        ${config.services.picom.package}/bin/picom-trans -w $win_id 50
    fi
  '';

in {
  home.keyboard = {
    layout = "us";
    options = [ "ctrl:nocaps" ];
  };

  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";

    initExtra = ''
      ${xconfigScript}/bin/xconfig.sh
      eval $(ssh-agent)
      umask 077
    '';

    numlock.enable = true;

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
        endMode     = "End Session  [mod+${endLogout}] logout  [mod+${endShutdown}] shutdown  [mod+${endRestart}] restart";
        endLogout   = "l";
        endShutdown = "p";
        endRestart  = "r";
        endKey      = "${mod}+Shift+e";

        # passthrough mode for gaming
        passthroughMode = "Passthrough Mode [mod+super+a]";
        passthroughKey  = "${mod}+${super}+a";

        # programs
        rofi = "${config.programs.rofi.package}/bin/rofi";

      in {
        enable = true;
        extraConfig = ''
          for_window [class=".*"] border pixel 2
          default_border          pixel 2
          default_floating_border pixel 2
        '';
        config = {
          # basics
          bars              = [];
          focus.followMouse = false;
          modifier          = mod;

          # appearance
          colors =
            let colours = (import ../lib/gui/colours.nix);
            in rec {
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
          fonts = {
            names = [ "Iosevka " ];
            style = "Medium";
            size  = 14.0;
          };
          gaps = {
            inner = 8;
            outer = 2;
          };

          # floating windows
          floating = {
            modifier = mod;
            criteria = [
              { class = "blueman-manager"; }
              { class = "Pavucontrol";     }
              { class = "Galculator";      }
            ];
          };

          # startup
          startup = [
            { # Restore initial layout.
              command = ''i3-msg "${builtins.concatStringsSep "; " [
                # Do workspace 1 last as that's where we want to end up.
                "workspace 2" "append_layout ${../res/i3/layout-2.json}"
                "workspace 1" "append_layout ${../res/i3/layout-1.json}"
                # Program windows will be captured appropriately.
                "exec firefox"
                "exec telegram-desktop"
                "exec discord"
              ] }"'';
            }
            {
              command = "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1";
              notification = false;
            }
            {
              command = "${pkgs.feh}/bin/feh --bg-fill ${pkgs.stdenv.mkDerivation {
                name = "wallpaper";
                src = builtins.fetchurl {
                  name = "wallpaper-src";
                  url = "https://assets.rockpapershotgun.com/images/2020/10/yakuza-like-a-dragon-yokohama.jpg";
                  sha256 = "sha256-jnWWoL6piIaTZAmCUDtCkfuHIy+A8ldOmVwjHiGSYTc=";
                };
                dontUnpack = true;
                buildPhase = ''
                  waifu2x-converter-cpp -i $src -o $(realpath ./up.jpg)
                  convert up.jpg -gaussian-blur 16x4 out.jpg
                '';
                installPhase = "cp out.jpg $out";
                nativeBuildInputs = with pkgs; [
                  waifu2x-converter-cpp
                  imagemagick
                ];
              }}";
              always = true; notification = false;
            }
            {
              command = "ibus-daemon --xim --replace --daemonize"; notification = false; always = true;
            }
          ];

          # keybindings
          keybindings = rec {
            # applications
            "${mod}+Return"       = "exec --no-startup-id ${config.programs.alacritty.package}/bin/alacritty";
            "${mod}+Shift+Return" = "exec firefox";
            "Print"               = "exec --no-startup-id ${pkgs.flameshot}/bin/flameshot gui";
            "${mod}+p"            = Print;
            "${mod}+Shift+p"      = "exec --no-startup-id ${pkgs.flameshot}/bin/flameshot screen --path ${config.xdg.userDirs.pictures}";
            "${mod}+Shift+c"      = "exec ${pkgs.galculator}/bin/galculator";

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

            # reload polybar
            "${mod}+Ctrl+Shift+r" = "exec --no-startup-id ${pkgs.systemd}/bin/systemctl --user restart polybar";

            # modes
            "${resizeKey}"      = "mode \"${resizeMode}\"";
            "${endKey}"         = "mode \"${endMode}\"";
            "${passthroughKey}" = "mode \"${passthroughMode}\"";

            # launch applications
            "${mod}+space"       = "exec ${rofi} -show drun";
            "${mod}+Shift+space" = "exec ${rofi} -show run";
            "${mod}+Ctrl+space"  = "exec ${rofi} -show window";

            # redo xconfig
            "${mod}+Shift+Ctrl+z" = "exec --no-startup-id ${xconfigScript}/bin/xconfig.sh";

            # fallback xrandr command to recover
            "${mod}+Shift+Ctrl+x" = "exec --no-startup-id ${pkgs.xorg.xrandr}/bin/xrandr --auto";

            # lock screen
            "${mod}+Shift+Escape" = "exec --no-startup-id ${lockScript}/bin/lock.sh --show-failed-attempts";

            # multimedia controls
            "XF86AudioPlay" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl play-pause";
            "XF86AudioNext" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioPrev" = "exec --no-startup-id ${pkgs.playerctl}/bin/playerctl previous";
            "XF86MonBrightnessUp"   = "exec --no-startup-id ${pkgs.light}/bin/light -A 10";
            "XF86MonBrightnessDown" = "exec --no-startup-id ${pkgs.light}/bin/light -U 10";
            "XF86AudioLowerVolume"  = "exec --no-startup-id ${volumeScriptBin} voldn && ${soundIpcHook}";
            "XF86AudioRaiseVolume"  = "exec --no-startup-id ${volumeScriptBin} volup && ${soundIpcHook}";
            "XF86AudioMute"         = "exec --no-startup-id ${volumeScriptBin} mute  && ${soundIpcHook}";

            # dunst controls
            "${mod}+bracketright" = "exec --no-startup-id ${pkgs.dunst}/bin/dunstctl close";
            "${mod}+bracketleft"  = "exec --no-startup-id ${pkgs.dunst}/bin/dunstctl history-pop";
            "${mod}+backslash"    = "exec --no-startup-id ${pkgs.dunst}/bin/dunstctl close-all";

            # suspend window
            "${mod}+Shift+s" = "exec --no-startup-id ${suspendScript}/bin/suspend-window";
          } //

          # workspace navigation
          (builtins.foldl'
            (x: y: x // y)
            {}
            (builtins.genList
              (x: let
                key = builtins.toString x;
                ws  = if x == 0 then "10" else key;
              in {
                "${mod}+${key}"       = "workspace number ${ws}";
                "${mod}+Shift+${key}" = "move container to workspace number ${ws}";
                "${mod}+Ctrl+${key}"  = "move container to workspace number ${ws}; workspace number ${ws}";
              }) 10)) //

          # window navigation
          (builtins.foldl'
            (x: y: x // y)
            {}
            (builtins.attrValues
              (builtins.mapAttrs
                (key: dirn: {
                  "${mod}+${key}"       = "focus ${dirn}";
                  "${mod}+Shift+${key}" = "move ${dirn}";
                })
                {
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
                  "Shift+${key}" = "resize ${dirn} 18 px or 18 ppt";
                  "Ctrl+${key}"  = "resize ${dirn} 3 px or 3 ppt";
                }) {
                  "${left}"  = "shrink width";
                  "${down}"  = "grow height";
                  "${up}"    = "shrink height";
                  "${right}" = "grow width";
                })));

            "${endMode}" = {
              "${mod}+${endLogout}"   = "exec --no-startup-id i3-msg exit";
              "${mod}+${endShutdown}" = "exec --no-startup-id systemctl poweroff";
              "${mod}+${endRestart}"  = "exec --no-startup-id systemctl reboot";
              "Escape"                = "mode \"default\"";
              "Return"                = "mode \"default\"";
              "${endKey}"             = "mode \"default\"";
            };

            "${passthroughMode}" = {
              "${passthroughKey}" = "mode \"default\"";
            };
          };
        };
      };
  };
}
