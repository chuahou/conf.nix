# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ pkgs, config, inputs, ... }:

{
  imports = [
    ./cachix.nix
    ./direnv.nix
    ./gc.nix
    ./persist.nix
    ./piper.nix
    ./printing.nix
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
    systemd-boot.enable      = true;
    efi.canTouchEfiVariables = true;
  };

  # networking settings
  networking = {
    networkmanager.enable = true;
    useDHCP               = false;
  };

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
      secrets = import inputs."secrets-${config.networking.hostName}";
    in {
      mutableUsers = false;
      users = {
        root = {
          hashedPassword = secrets.root.hashedPassword;
        };
        user =
          let inherit (import ../lib {}) me;
          in {
            isNormalUser   = true;
            name           = me.home.username;
            description    = me.name;
            hashedPassword = secrets.user.hashedPassword;
            shell          = pkgs.zsh;
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
  fonts.fonts = with pkgs; [
    corefonts
    fira
    fira-code
    iosevka
    iosevkaFixed
    ioslabka
    ipaexfont
    ipafont
    lmmath
    lmodern
    noto-fonts-cjk
    open-sans
    overpass
    roboto
    roboto-slab
  ];

  # input methods
  i18n.inputMethod = {
    enabled       = "fcitx";
    fcitx.engines = [ pkgs.fcitx-engines.mozc ];
  };

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
