{ config, pkgs, ... }:

{
  imports = [
    ./fs.nix
    ./hardware.nix
    ./persist.nix
  ];

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  # use systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking settings
  networking.hostName = "CH-21N";
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp60s0.useDHCP = true;
  networking.interfaces.wlp61s0.useDHCP = true;

  # time zone
  time.timeZone = "Asia/Singapore";
  time.hardwareClockInLocalTime = true; # compatibility with Windows

  # locale
  i18n.defaultLocale = "en_SG.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # GNOME 3 (for now)
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.windowManager.i3.package = pkgs.i3-gaps;

  # keyboard layout
  services.xserver.layout = "us";

  # CUPS for printer
  services.printing.enable = true;

  # sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # touchpad support
  services.xserver.libinput.enable = true;

  # user accounts
  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = (import ./secrets.nix).root.hashedPassword;
      };
      sgepk = {
        isNormalUser = true;
        description = "Chua Hou";
        extraGroups = [ "wheel" "networkmanager" ];
        hashedPassword = (import ./secrets.nix).sgepk.hashedPassword;
      };
    };
  };

  # fonts to install system-wide
  fonts.fonts = with pkgs; [
    fira
    iosevka
    ipafont
    ipaexfont
    roboto-slab
  ];

  # system-wide packages
  environment.systemPackages = with pkgs; [
    # base packages
    bc
    curl
    cpufrequtils
    gawk
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

    # basic packages for i3 environment
    alacritty
    blueman
    dunst
    feh
    firefox-bin
    flameshot
    i3lock
    imagemagick
    libnotify
    light
    lxappearance
    mate.mate-polkit
    pavucontrol
    playerctl
    rofi
    scrot
    xfce.thunar
  ];

  # enable gpg-agent
  programs.gnupg.agent.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
