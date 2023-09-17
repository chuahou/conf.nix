# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# Runs Firefox as a completely separate user. This achieves isolation two-ways
# assuming Unix permissions are not broken---other programs cannot access
# Firefox files (and importantly, sessions/cookies) directly, while Firefox
# cannot access arbitrary files.

{ config, lib, pkgs, ... }:

{
  options.programs.firefox-sudo = {
    normalUser = lib.mkOption {
      description = "Username of normal (non-Firefox) user to use this with.";
      type = lib.types.str;
    };
    firefoxUser = lib.mkOption {
      description = "Username of user used specifically to run Firefox.";
      type = lib.types.str;
      default = "firefox";
    };
    userCss = lib.mkOption {
      description = "CSS to place in <profile>/chrome/userChrome.css.";
      type = lib.types.str;
      default = "";
    };
    profileName = lib.mkOption {
      description = "Name of Firefox profile to use.";
      type = lib.types.str;
      default = "firefox-sudo";
    };
    userPrefs = lib.mkOption {
      description = "Attrset of Firefox preferences in about:config.";
      type = lib.types.attrsOf (pkgs.formats.json {}).type;
      default = {};
    };
  };

  config =
    let
      cfg = config.programs.firefox-sudo;

      # Profile setup script that sets up userChrome.css, user.js and
      # profiles.ini. Errors if they exist as regular files (not symlinks).
      profileSetupScript = pkgs.writeShellScript "firefox-sudo-setup" /* sh */ ''
        set -euo pipefail
        cd ~${cfg.firefoxUser}
        mkdir -p .mozilla/firefox/${cfg.profileName}/chrome
        function install_file () {
            if [ -f $2 ]; then
                if [ -L $2 ]; then
                    rm $2
                else
                    >&2 echo "File $2 exists and is not a symlink!"
                    exit 1
                fi
            fi
            ln -s $1 $2
        }
        install_file ${userJs} .mozilla/firefox/${cfg.profileName}/user.js
        install_file ${userCss} .mozilla/firefox/${cfg.profileName}/chrome/userChrome.css
        install_file ${profilesIni} .mozilla/firefox/profiles.ini
      '';

      # Files that are installed.
      userCss = pkgs.writeTextFile {
        name = "userChrome.css";
        text = cfg.userCss;
      };
      profilesIni = pkgs.writeTextFile {
        name = "profiles.ini";
        text = /* ini */ ''
          [General]
          StartWithLastProfile=1
          [Profile0]
          Default=1
          IsRelative=1
          Name=${cfg.profileName}
          Path=${cfg.profileName}
        '';
      };
      userJs = pkgs.writeTextFile {
        name = "user.js";
        text = builtins.concatStringsSep "\n"
          (pkgs.lib.mapAttrsToList (name: value:
            ''user_pref("${name}", ${builtins.toJSON value});'') cfg.userPrefs);
      };

    in {
      # Implement on top of the generic UID isolation module.
      security.uid-isolation.programs = [
        {
          inputDerivation = pkgs.symlinkJoin {
            name = "firefox-with-profile-setup";
            paths = with pkgs; [ firefox ];
            postBuild = /* sh */ ''
              cd $out
              unwrapped=$(realpath bin/.firefox-without-profile-setup)
              mv bin/firefox $unwrapped
              cat << EOF > bin/firefox
                  # This is run when we are already the firefox user.
                  ${profileSetupScript}
                  $unwrapped "\$@"
              EOF
              chmod +x bin/firefox
            '';
          };
          binaryName = "firefox";
          user = { name = cfg.firefoxUser; uid = 2000; };
        }
      ];
      security.uid-isolation.normalUser = cfg.normalUser;
    };

  imports = [ ./uid-isolation.nix ];
}
