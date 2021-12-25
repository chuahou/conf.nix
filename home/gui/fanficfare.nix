# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  home.packages = with pkgs; [ fanficfare ];

  xdg.configFile."fanficfare/personal.ini".text =
    let username = (import ../../lib {}).me.home.username;
    in ''
      [defaults]
      browser_cache_path:/home/${username}/.cache/mozilla/firefox/${username}/cache2
      continue_on_chapter_error:false

      [www.fanfiction.net]
      use_browser_cache:true
      use_browser_cache_only:false
      never_make_cover:true
      skip_author_cover:true
    '';
}
