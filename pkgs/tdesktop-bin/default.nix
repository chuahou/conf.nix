# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ curl
, gnutar
, jq
, makeDesktopItem
, steam-run
, symlinkJoin
, wget
, writeShellScriptBin
}:

let
  apiUrl = "https://api.github.com/repos/telegramdesktop/tdesktop/releases";
  binLocation = "\${XDG_DATA_HOME:-$HOME/.local/share}/tdesktop-bin";
  binTelegramLocation = "${binLocation}/Telegram/Telegram";
  launcherName = "tdesktop-bin-launcher";

  launcher = writeShellScriptBin launcherName ''
    set -euo pipefail

    download_release () {
        ${curl}/bin/curl $1 \
            | ${jq}/bin/jq -r  '.assets[] | select(.label == "Linux 64 bit: Binary") | .browser_download_url' \
            | ${wget}/bin/wget -i - -O - \
            | ${gnutar}/bin/tar Jxf - -C ${binLocation}
    }

    mkdir -p ${binLocation}
    [ $# -eq 0 ] \
        && api_url="${apiUrl}/latest" \
        || api_url="${apiUrl}/tags/$1"
    [ -f ${binTelegramLocation} ] || download_release $api_url

    exec ${steam-run}/bin/steam-run ${binTelegramLocation}
  '';

  desktop = makeDesktopItem rec {
    name = "tdesktop-bin";
    exec = "${launcher}/bin/${launcherName}";
    desktopName = "Telegram Desktop (Binary)";
  };

in
  symlinkJoin {
    name = "tdesktop-bin";
    paths = [ launcher desktop ];
  }
