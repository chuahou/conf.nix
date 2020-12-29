{ config, ... }:

let
  me = import ../me.nix;
in
  {
    programs.git = {
      enable = true;
      userName = me.name;
      userEmail = me.email;
      signing = {
        key = "314311D4CE92CC07DD5BDDC8A7F9181F143648FD";
        signByDefault = true;
      };
      extraConfig = {
        core.editor = "nvim";
      };
    };
  }
