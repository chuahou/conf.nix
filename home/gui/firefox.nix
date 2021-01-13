# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  programs.firefox = {
    enable  = true;
    package = pkgs.firefox-bin;

    profiles =
      let
        me = (import ../../lib {}).me;
      in {
        "${me.home.username}" = {
          inherit (me) name;
          settings = {
            # always ask for downloads
            "browser.download.useDownloadDir" = false;

            # don't use new tab page
            "browser.newtabpage.enabled" = false;

            # enable full-screen within window (for i3wm)
            "full-screen-api.ignore-widgets" = true;

            # prevent Alt from showing window menu
            "ui.key.menuAccessKeyFocuses" = false;

            # disable telemetry, reporting, experiments etc.
            # source:
            # https://www.reddit.com/r/firefox/comments/8izzu1/how_to_turn_off_telemetry_using_userjs/dywdews/
            "app.normandy.api_url"                         = "";
            "app.normandy.enabled"                         = false;
            "app.shield.optoutstudies.enabled"             = false;
            "browser.ping-centre.telemtry"                 = false;
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
        };
      };
  };
}
