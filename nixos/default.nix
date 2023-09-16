# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou

{ pkgs, config, inputs, ... }:

{
  imports = [
    ./cachix.nix
    ./clamav.nix
    ./direnv.nix
    ./firefox.nix
    ./gc.nix
    ./ime.nix
    ./persist.nix
    ./piper.nix
    ./printing.nix
    ./syncthing.nix
    ./virt.nix
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
  programs.nm-applet.enable = true;

  # time settings
  time.timeZone = "Asia/Singapore";

  # locale
  i18n.defaultLocale = "en_SG.UTF-8";
  console = {
    font   = "Lat2-Terminus16";
    keyMap = "us";
  };

  # xserver settings
  services.xserver = {
    enable = true;

    displayManager.lightdm.enable = true;
    desktopManager.session = [
      {
        name = "home-manager-xsession";
        start = ''
          ${pkgs.runtimeShell} $HOME/.hm-xsession &
          waitPID=$!
        '';
      }
    ];

    xkbOptions = "ctrl:nocaps";
  };

  # user accounts
  users =
    let
      passwdDir = "/persist/passwd";
    in {
      mutableUsers = false;
      users = {
        root.hashedPasswordFile = "${passwdDir}/root";
        user =
          let inherit (import ../lib {}) me;
          in {
            isNormalUser = true;
            name = me.home.username;
            description = me.name;
            hashedPasswordFile = "${passwdDir}/user";
            shell = pkgs.zsh;
            extraGroups = [
              "wheel" "networkmanager" "video" "scanner" "lp"
            ];
          };
      };
    };
  # set main user as trusted user for nix purposes
  nix.settings.trusted-users = [ config.users.users.user.name ];

  # various programs/services
  programs.zsh.enable = true; # enable as interactive shell
  programs.gnupg.agent.enable = true;
  programs.light.enable = true; # backlight control
  services.blueman.enable = true; # bluetooth
  services.upower.enable = true;
  services.cron.enable = true;

  # steam
  programs.steam.enable = true;

  # fonts to install system-wide
  fonts.packages = with pkgs; [
    corefonts
    fira
    fira-code
    iosevka
    ipaexfont
    ipafont
    lmmath
    lmodern
    mplus-outline-fonts.githubRelease
    noto-fonts-cjk
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

  # extra sudoers rules
  security.sudo.extraRules = [
    {
      groups   = [ "wheel" ];
      commands = [
        {
          command = "${pkgs.cpufreq-plugin-wrapped}/bin/cpufreq-plugin *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
