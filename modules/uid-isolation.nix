# SPDX-License-Identifier: MIT
# Copyright (c) 2023, 2025 Chua Hou
#
# Runs a program as a completely separate user. This achieves user-level
# isolation with Unix permissions.
#
# This means that file transfers need to be done manually using root
# permissions, but can be bypassed using X11 clipboard for many convenient
# cases. We also provide a shared directory for ease.

{ config, lib, pkgs, ... }:

let
  perProgramOptions = { ... }: {
    options = {
      inputDerivation = lib.mkOption {
        description = "Derivation of program to run as separate user.";
        type = lib.types.package;
        example = pkgs.firefox;
      };
      binaryName = lib.mkOption {
        description = "Name of binary to wrap. Assumed to be in bin/ directory.";
        type = lib.types.str;
        example = "firefox";
      };
      commandPrefix = lib.mkOption {
        description = "To prepend to binary name when calling it.";
        type = lib.types.str;
        example = "env DBUS_SESSION_BUS_ADDRESS=unix:path=/dev/null";
        default = "";
      };
      commandSuffix = lib.mkOption {
        description = "To append to binary name when calling it.";
        type = lib.types.str;
        example = "(command line args)";
        default = "";
      };
      desktopFile = {
        name = lib.mkOption {
          description = "Filename for custom desktop file.";
          type = lib.types.str;
          default = "";
        };
        content = lib.mkOption {
          description = "Custom desktop file for application if necessary.";
          type = lib.types.str;
          default = "";
        };
      };
      user = {
        name = lib.mkOption {
          description = "Username of user to run program as.";
          type = lib.types.str;
          example = "firefox";
        };
        uid = lib.mkOption {
          description = "UID of user to run program as.";
          type = lib.types.int;
          example = 1101;
        };
      };
      allowedArgs = lib.mkOption {
        description = "Args to allow the application to run with without authentication.";
        type = lib.types.str;
        default = "";
      };
    };
  };

  cfg = config.security.uid-isolation;

  # Generates config to wrap a single program. Takes perProgramOptions as an
  # argument.
  mkConfig = opts:

    # Wraps the program in a new derivation.
    # Typically, the share/applications/*.desktop will have Exec= lines that
    # don't specify the binary path, such as `Exec=firefox`. Since we replace
    # the binary with our wrapper by name, the path will only contain our
    # wrapper and this will work out of the box.
    # In cases where the .desktop file contains an absolute nix store path, it
    # will need to be patched out manually.
    let
      unwrappedPath = "bin/.uid-isolation-unwrapped";
      pkg = pkgs.symlinkJoin {
        name = "${opts.inputDerivation.name}-uid-isolated";
        paths = [ opts.inputDerivation ];
        postBuild = ''
          cd $out
          unwrapped=$(realpath ${unwrappedPath})
          mv bin/${opts.binaryName} $unwrapped

          cat << EOF > bin/${opts.binaryName}
          #!/usr/bin/env bash
          # Allow group to read file so shared directory works well.
          umask 007
          ${pkgs.ego}/bin/ego -u ${opts.user.name} ${opts.commandPrefix} $unwrapped "\$@" ${opts.commandSuffix}
          EOF

          chmod +x bin/${opts.binaryName}

          ${if opts.desktopFile.name != "" then ''
            mv share/applications share/applications_old
            mkdir -p share/applications
            cat << EOF > share/applications/${opts.desktopFile.name}
            ${opts.desktopFile.content}
            EOF
          '' else ""}
        '';
      };

    in {
      environment.systemPackages = [ pkg ];
      users.users.${opts.user.name} = {
        isNormalUser = true;
        createHome = true;
        inherit (opts.user) uid;
        group = cfg.sharedDir.group.name;
      };

      # Allow normal user to run this program without password.
      security.polkit.extraConfig =
        let
          allowedArgs = if opts.allowedArgs != "" then " ${opts.allowedArgs}" else "";
          allowedPrefix = if opts.commandPrefix != "" then "${opts.commandPrefix} " else "";
          allowedSuffix = if opts.commandSuffix != "" then " ${opts.commandSuffix}" else "";
        in ''
          polkit.addRule(function(action, subject) {
              if (action.id == "org.freedesktop.machine1.host-shell" &&
                  action.lookup("user") == "${opts.user.name}" &&
                  subject.user == "${cfg.normalUser}") {
                  if (action.lookup("command_line") == "/bin/sh -c dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY PULSE_SERVER PULSE_COOKIE; systemctl --user start xdg-desktop-portal-gtk; exec ${allowedPrefix}${pkg}/${unwrappedPath}${allowedArgs}${allowedSuffix}") {
                      return polkit.Result.YES;
                  } else {
                      polkit.log(JSON.stringify(action));
                  }
              }
          });
        '';
    };

    # We have to merge individual top-level attributes manually to avoid
    # infinite recursion.
    allConfigs = map mkConfig cfg.programs;
    allConfigsCombined = {
      environment = lib.mkMerge (map (c: c.environment) allConfigs);
      users = lib.mkMerge (map (c: c.users) allConfigs);
      security.polkit = lib.mkMerge (map (c: c.security.polkit) allConfigs);
    };

in {
  options.security.uid-isolation = {
    programs = lib.mkOption {
      description = "Programs to run as separate user.";
      type = with lib.types; listOf (submodule perProgramOptions);
      default = [];
    };
    normalUser = lib.mkOption {
      description = "Username of normal user account.";
      type = lib.types.str;
    };
    sharedDir = {
      path = lib.mkOption {
        description = "Path to shared folder for all isolated programs to have access to.";
        type = lib.types.path;
        default = "/shared";
      };
      group = {
        name = lib.mkOption {
          description = "Name of group that all isolated users belong to, for shared folder to work.";
          type = lib.types.str;
          default = "uid-isolation";
        };
        gid = lib.mkOption {
          description = "GID of group that all isolated users belong to, for shared folder to work.";
          type = lib.types.int;
          default = 199;
        };
      };
    };
  };

  config = lib.mkIf (cfg.programs != []) {

    # Shared directory belongs to group that normal user and all program users
    # will belong to. SETGID bit is set so that anything written there will
    # automatically belong to the shared group. It is still necessary to
    # manually set read permissions by group if copying a file that does not
    # have group read permissions beforehand.
    systemd.tmpfiles.rules = [
      "d ${cfg.sharedDir.path} 2770 0 ${toString cfg.sharedDir.group.gid}"
    ];

    # We have to merge these manually to prevent infinite recursion.
    environment = lib.mkMerge [
      allConfigsCombined.environment
      {
        systemPackages = [
          # Shell script to copy file(s) to the shared directory and change
          # their group permissions so applications can access it.
          (pkgs.writeShellScriptBin "cpshare" /* sh */ ''
            cp "$@" ${cfg.sharedDir.path} -a
            find ${cfg.sharedDir.path} -user $(whoami) \
                -exec chmod g=u {} \; \
                -exec chgrp ${cfg.sharedDir.group.name} {} \;
          '')
        ];
      }
    ];
    security.polkit = allConfigsCombined.security.polkit;
    users = lib.mkMerge [
      allConfigsCombined.users
      {
        groups = {
          ${cfg.sharedDir.group.name} = {
            inherit (cfg.sharedDir.group) gid;
            members = [ cfg.normalUser ];
          };
        };
      }
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };
}
