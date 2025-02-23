# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou

{ pkgs, config, inputs, ... }:

{
  imports = [
    ./adb.nix
    ./direnv.nix
    ./firefox.nix
    ./gc.nix
    ./ime.nix
    ./opensnitch.nix
    ./persist.nix
    ./piper.nix
    ./printing.nix
    ./syncthing.nix
    ./uid-isolation.nix
    ./virt.nix
    ./yubikey.nix
  ];

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  # set NIX_PATH
  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    "nixos=${inputs.nixpkgs}"
  ];

  # enable all firmware
  hardware.enableAllFirmware = true;

  # allow magic SysRq
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # use systemd-boot
  boot.loader = {
    systemd-boot = {
      enable = true;
      consoleMode = "max";
    };
    efi.canTouchEfiVariables = true;
    timeout = 5;
  };

  # networking settings
  networking = {
    networkmanager.enable = true;
    useDHCP               = false;
  };

  # time settings
  time.timeZone = "Asia/Singapore";

  # locale
  i18n = {
    defaultLocale = "en_SG.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_SE.UTF-8";
    };
    glibcLocales = (pkgs.glibcLocales.override {
      allLocales = false;
      locales = config.i18n.supportedLocales;
    }).overrideAttrs (old: {
      postUnpack = /* sh */ ''
        cp ${pkgs.fetchurl {
          url = "https://gist.githubusercontent.com/bmaupin/d64368e78cd359d309685fecbe2baf23/raw/e933a0fc2e727aa640f4a1cb1f699622876940fc/en_SE";
          hash = "sha256-ArXL+rMDVWI4Mmcw8xoRlZFXhEeSQL0tLJf5pKEOx3s=";
        }} $sourceRoot/localedata/locales/en_SE
        echo 'en_SE.UTF-8/UTF-8 \' >> $sourceRoot/localedata/SUPPORTED
      '';
    });
  };
  console = {
    font   = "Lat2-Terminus16";
    keyMap = "us";
  };

  # KDE
  services.displayManager.sddm = {
    enable = true;
    settings."Users"."MaximumUid" = 1500; # Exclude uid-isolation users.
  };
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
  ];

  # user accounts
  users =
    let
      passwdDir = "/persist/passwd";
    in {
      mutableUsers = false;
      users = {
        root.hashedPasswordFile = "${passwdDir}/root";
        user = {
          isNormalUser = true;
          name = "sgepk";
          description = "Chua Hou";
          hashedPasswordFile = "${passwdDir}/user";
          shell = pkgs.zsh;
          extraGroups = [
            "wheel" "networkmanager" "video" "scanner" "lp"
          ];
          uid = 1000;
        };
      };
    };
  # set main user as trusted user for nix purposes
  nix.settings.trusted-users = [ config.users.users.user.name ];

  # various programs/services
  programs.zsh.enable = true; # enable as interactive shell
  programs.gnupg.agent.enable = true;
  services.upower.enable = true;

  # allow mounting of NTFS
  boot.supportedFilesystems = [ "ntfs" ];

  # fonts to install system-wide
  fonts.packages = with pkgs; [
    cascadia-code
    corefonts
    fira
    fira-code
    iosevka
    ipaexfont
    ipafont
    lmmath
    lmodern
    mplus-outline-fonts.githubRelease
    noto-fonts-cjk-sans
    open-sans
    overpass
    roboto
    roboto-slab
  ];

  # system-wide packages
  environment.systemPackages = with pkgs; [
    bc
    cachix
    curl
    cpufrequtils
    gawk
    file
    git
    gnupg
    gparted
    htop
    jq
    killall
    ldns
    lm_sensors
    neovim
    nix-output-monitor
    pciutils
    pv
    tree
    unzip
    wget
    wireguard-tools
    zip
    zsh
  ];
}
