{ inputs, osConfig, ... }:

{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];
  programs.plasma = {
    enable = true;
    startup.startupScript.opensnitch.text = /* sh */ ''
      opensnitch-ui --socket ${osConfig.services.opensnitch.settings.Server.Address}
    '';
    shortcuts = {
      kwin."Window Move" = "Alt";
      kwin."Window Maximize" = "Meta+Shift+Up";
      kwin."Switch Window Down" = "Alt+J";
      kwin."Switch Window Left" = "Alt+H";
      kwin."Switch Window Right" = "Alt+L";
      kwin."Switch Window Up" = "Alt+K";
      kwin."Walk Through Windows Alternative" = "Meta+Tab";
      kwin."Walk Through Windows Alternative (Reverse)" = "Meta+Shift+Tab";
      kwin."Walk Through Windows of Current Application" = [ ];
      kwin."Walk Through Windows of Current Application (Reverse)" = [ ];
      kwin."Walk Through Windows of Current Application Alternative" = [ ];
      kwin."Walk Through Windows of Current Application Alternative (Reverse)" = [ ];
      "services/org.kde.konsole.desktop"."_launch" = "Alt+Return";
      "services/io.github.Qalculate.qalculate-qt.desktop"."_launch" = "Ctrl+Alt+C";
    };
    input.keyboard = {
      numlockOnStartup = "on";
      options = [ "ctrl:nocaps" ];
    };
    kwin = {
      edgeBarrier = 0;
      effects = {
        shakeCursor.enable = false;
        desktopSwitching.animation = "off";
      };
      virtualDesktops = {
        number = 2;
        rows = 1;
      };
    };
    powerdevil = let universalConfig = {
      autoSuspend.action = "nothing";
      powerButtonAction = "showLogoutScreen";
      whenLaptopLidClosed = "lockScreen";
      inhibitLidActionWhenExternalMonitorConnected = true;
      dimDisplay.enable = false;
      turnOffDisplay.idleTimeout = "never";
    }; in {
      AC = universalConfig;
      battery = universalConfig;
      lowBattery = universalConfig;
    };
    configFile = {
      "kdeglobals"."Sounds"."Enable" = false;
      "kwinrc" = {
        # Additional virtual desktop configuration.
        "Plugins"."desktopchangeosdEnabled" = true;
        "Windows"."RollOverDesktops" = true;
        "Script-desktopchangeosd"."PopupHideDelay" = 100;
        # Task switcher configuration.
        "TabBox"."MultiScreenMode" = 1; # Filter by screen.
        "TabBoxAlternative"."DesktopMode" = 2; # Other desktops only.
        # Window decoration buttons.
        "org.kde.kdecoration2"."ButtonsOnLeft" = "MF";
        # Disable top-left corner overview.
        "Effect-overview"."BorderActivate" = 9;
      };
      "krunnerrc" = {
        "Plugins" = {
          "krunner_appstreamEnabled" = false;
          "krunner_dictionaryEnabled" = false;
          "krunner_webshortcutsEnabled" = false;
          "unitconverterEnabled" = false;
        };
      };
      # Don't relaunch apps when logging in.
      "ksmserverrc"."General"."loginMode" = "emptySession";
      # Sweden has a nice ISO date format.
      "plasma-localerc"."Formats"."LC_TIME" = "en_SE.UTF-8";
    };
  };
}
