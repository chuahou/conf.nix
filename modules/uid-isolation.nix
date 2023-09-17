# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
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
    };
  };

  cfg = config.security.uid-isolation;

  # Generates config to wrap a single program. Takes perProgramOptions as an
  # argument.
  mkConfig = opts:

    # Wraps the program in a new derivation.
    let pkg = pkgs.symlinkJoin {
      name = "${opts.inputDerivation.name}-uid-isolated";
      paths = [ opts.inputDerivation ];
      postBuild = /* sh */ ''
        cd $out
        unwrapped=$(realpath bin/.uid-isolation-unwrapped)
        mv bin/${opts.binaryName} $unwrapped
        cat << EOF > bin/${opts.binaryName}
            ${pkgs.xorg.xhost}/bin/xhost +SI:localuser:${opts.user.name}
            # Allow group to read file so shared directory works well.
            umask 007
            sudo --preserve-env=DISPLAY,XAUTHORITY,XMODIFIERS,GTK_IM_MODULE,QT_IM_MODULE \
                -u ${opts.user.name} $unwrapped "\$@"
            ${pkgs.xorg.xhost}/bin/xhost -SI:localuser:${opts.user.name}
        EOF
        chmod +x bin/${opts.binaryName}
      '';
    };

    in {
      environment.systemPackages = [ pkg ];
      users.users.${opts.user.name} = {
        isNormalUser = true;
        createHome = true;
        inherit (opts.user) uid;
        group = cfg.sharedDir.group.name;
        extraGroups = [ "pulse-access" ];
      };

      # Allow normal user to run this program without password for sudo.
      security.sudo.extraRules = [ {
        users = [ cfg.normalUser ];
        runAs = opts.user.name;
        commands = [ {
          command = "${pkg}/bin/.uid-isolation-unwrapped";
          options = [ "NOPASSWD" "SETENV" ];
        } ];
      } ];
    };

    # We have to merge individual top-level attributes manually to avoid
    # infinite recursion.
    allConfigs = map mkConfig cfg.programs;
    allConfigsCombined = {
      environment = lib.mkMerge (map (c: c.environment) allConfigs);
      users = lib.mkMerge (map (c: c.users) allConfigs);
      security.sudo = lib.mkMerge (map (c: c.security.sudo) allConfigs);
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

    # Enable shared pulseaudio for audio to work. Also requires adding users to
    # pulse-access group.
    hardware.pulseaudio.systemWide = true;

    # We have to merge these manually to prevent infinite recursion.
    environment = lib.mkMerge [
      allConfigsCombined.environment
      {
        systemPackages = [
          # Shell script to copy file(s) to the shared directory and change
          # their group permissions so applications can access it.
          (pkgs.writeShellScriptBin "cpshare" ''
            for path in "$@"; do
                # -a option since we may copy directories as well.
                cp $path ${cfg.sharedDir.path} -a
                dest_path=${cfg.sharedDir.path}/$(basename $path)
                chmod -R g=u $dest_path
                chgrp -R ${cfg.sharedDir.group.name} $dest_path
            done
          '')
        ];
      }
    ];
    security.sudo = allConfigsCombined.security.sudo;
    users = lib.mkMerge [
      allConfigsCombined.users
      {
        groups = {
          ${cfg.sharedDir.group.name} = {
            inherit (cfg.sharedDir.group) gid;
            members = [ cfg.normalUser ];
          };
          pulse-access.members = [ cfg.normalUser ];
        };
      }
    ];
  };
}
