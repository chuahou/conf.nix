# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ config, ... }:

let
  prefs = {
    # use WebRender
    "gfx.webrender.all"        = true;
    "gfx.webrender.compositor" = true;

    # always ask for downloads
    "browser.download.useDownloadDir" = false;

    # don't use new tab page
    "browser.newtabpage.enabled" = false;

    # always use HTTPS
    "dom.security.https_only_mode" = true;

    # enable full-screen within window (for i3wm)
    "full-screen-api.ignore-widgets" = true;

    # prevent Alt from showing window menu
    "ui.key.menuAccessKeyFocuses" = false;

    # only show context menu after mouseup to prevent misclicks
    "ui.context_menus.after_mouseup" = true;

    # enable userChrome.css
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # disable prefetching
    "network.prefetch-next" = false;
    "network.dns.disablePrefetch" = false;
    "network.http.speculative-parallel-limit" = 0;

    # disable telemetry, reporting, experiments etc.
    # source:
    # https://www.reddit.com/r/firefox/comments/8izzu1/how_to_turn_off_telemetry_using_userjs/dywdews/
    "app.normandy.api_url"                         = "";
    "app.normandy.enabled"                         = false;
    "app.shield.optoutstudies.enabled"             = false;
    "browser.ping-centre.telemetry"                = false;
    "datareporting.healthreport.uploadEnabled"     = false;
    "datareporting.policy.dataSubmissionEnabled"   = false;
    "toolkit.telemetry.archive.enabled"            = false;
    "toolkit.telemetry.bhrPing.enabled"            = false;
    "toolkit.telemetry.cachedClientID"             = "";
    "toolkit.telemetry.enabled"                    = false;
    "toolkit.telemetry.firstShutdownPing.enabled"  = false;
    "toolkit.telemetry.newProfilePing.enabled"     = false;
    "toolkit.telemetry.reportingpolicy.firstRun"   = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified"                    = false;
    "toolkit.telemetry.updatePing.enabled"         = false;
  };

in {
  imports = [ ../modules/firefox-sudo.nix ];
  programs.firefox-sudo = {
    normalUser = config.users.users.user.name;
    userCss = /* css */ ''
      #fullscr-toggler { display:none !important; }

      /* For use with Tree Style Tab. */
      #TabsToolbar { visibility: collapse !important; }
      #sidebar-header { font-size: 80% !important; padding: 0px !important; }
      #sidebar-close { display: none; }
    '';
    userPrefs = prefs;
  };
}
