# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ config, pkgs, ... }:

let
  electronCommandSuffix = "'--enable-features=UseOzonePlatform,WaylandWindowDecorations' '--ozone-platform=wayland' --enable-wayland-ime";
in {
  imports = [ ../modules/uid-isolation.nix ];

  security.uid-isolation = {
    programs = [
      {
        inputDerivation = pkgs.tdesktop;
        binaryName = "telegram-desktop";
        user = { name = "telegram"; uid = 2001; };
        desktopFile = {
          name = "org.telegram.desktop.desktop";
          content = ''
            [Desktop Entry]
            Name=Telegram
            Comment=New era of messaging
            Exec=telegram-desktop
            Icon=telegram
            Terminal=false
            StartupWMClass=TelegramDesktop
            Type=Application
            Categories=Chat;Network;InstantMessaging;Qt;
            MimeType=x-scheme-handler/tg;x-scheme-handler/tonsite;
            Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
          '';
        };
      }
      {
        inputDerivation = pkgs.discord;
        binaryName = "Discord";
        user = { name = "discord"; uid = 2002; };
        commandSuffix = electronCommandSuffix;
      }
      {
        inputDerivation = pkgs.bitwarden;
        binaryName = "bitwarden";
        user = { name = "bitwarden"; uid = 2003; };
        commandSuffix = electronCommandSuffix;
      }
      {
        inputDerivation = pkgs.joplin-desktop;
        binaryName = "joplin-desktop";
        user = { name = "joplin"; uid = 2004; };
        allowedArgs = "--no-sandbox";
        commandSuffix = electronCommandSuffix;
      }
      {
        # Google Chrome has .desktop files that have the full nix store path in
        # their Exec line. To get around this, we simply remove the directory so
        # that the Exec just has 'google-chrome-stable', then our wrapper will
        # be called instead.
        inputDerivation = pkgs.symlinkJoin {
          name = "${pkgs.google-chrome.name}-patched-desktop";
          paths = [ pkgs.google-chrome ];
          postBuild = /* sh */ ''
              cd $out/share/applications
              # Make it no longer a symlink so we can edit it.
              cp --remove-destination \
                  $(readlink -f google-chrome.desktop) google-chrome.desktop
              # Remove preceding nix store link.
              sed -i -e 's@^Exec=/nix/store/.*/google-chrome-stable@Exec=google-chrome-stable@' \
                  google-chrome.desktop
          '';
        };
        binaryName = "google-chrome-stable";
        user = { name = "chrome"; uid = 5353; };
        commandSuffix = electronCommandSuffix;
      }
      {
        inputDerivation = pkgs.android-studio;
        binaryName = "android-studio";
        user = { name = "dev"; uid = 2005; };
      }
    ];
    normalUser = config.users.users.user.name;
  };

  # For debugging Polkit rules.
  security.polkit.debug = true;
}
