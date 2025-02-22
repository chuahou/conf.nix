{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [ fcitx5-mozc ];
      waylandFrontend = true;
      settings.globalOptions = {
        "Behavior/DisabledAddons"."0" = "clipboard";
      };
    };
  };
}
