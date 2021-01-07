# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, ... }:

{
  imports = [
    ./fs.nix
    ./hardware.nix
    ./persist.nix

    # nix flakes
    ./flakes.nix
  ];

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  # use systemd-boot
  boot.loader = {
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
  };

  # networking settings
  networking = {
    hostName              = "CH-21N";
    networkmanager.enable = true;
    useDHCP               = false;
    interfaces = {
      enp60s0.useDHCP = true;
      wlp61s0.useDHCP = true;
    };
  };

  # time settings
  time = {
    timeZone                 = "Asia/Singapore";
    hardwareClockInLocalTime = true; # compatibility with Windows
  };

  # locale
  i18n.defaultLocale = "en_SG.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # xserver settings
  services.xserver = {
    enable = true;

    displayManager.lightdm.enable = true;

    # GNOME 3 (for now)
    desktopManager.gnome3.enable = true;

    # keyboard layout
    layout     = "us";
    xkbOptions = "ctrl:nocaps";
  };

  # hardware services
  services.printing.enable         = true; # printer CUPS
  sound.enable                     = true;
  hardware.pulseaudio.enable       = true;
  services.xserver.libinput.enable = true; # touchpad support

  # user accounts
  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = (import ./secrets.nix).root.hashedPassword;
      };
      user =
        let
          me = (import ../home/lib/me.nix);
        in
          {
            isNormalUser   = true;
            name           = me.home.username;
            description    = me.name;
            extraGroups    = [ "wheel" "networkmanager" ];
            hashedPassword = (import ./secrets.nix).user.hashedPassword;
            shell          = pkgs.zsh;
          };
    };
  };

  # enable zsh as an interactive shell, needed to set it as default shell
  programs.zsh.enable = true;

  # enable gpg-agent
  programs.gnupg.agent.enable = true;

  # fonts to install system-wide
  fonts.fonts = with pkgs; [
    corefonts
    fira
    iosevka
    ipaexfont
    ipafont
    open-sans
    roboto
    roboto-slab
  ];

  # system-wide packages
  environment.systemPackages = with pkgs; [
    bc
    curl
    cpufrequtils
    gawk
    file
    git
    gnupg
    gparted
    killall
    lm_sensors
    neovim
    pciutils
    rcm
    tree
    wget
    zsh
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
