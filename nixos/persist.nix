{ config, lib, ... }:

{
  # opt in persistence
  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    "NetworkManager/system-connections".source =
      "/persist/etc/NetworkManager/system-connections";
  };
  security.sudo.extraConfig = "Defaults lecture = never";

  # make root blank on boot
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    mkdir -p /mnt
    mount /dev/mapper/data-root /mnt
    btrfs sub list -o /mnt/root | awk '{print $NF}' |
      while read sub; do
        btrfs sub del /mnt/$sub
      done && btrfs sub del /mnt/root
    btrfs sub snap /mnt/root-blank /mnt/root
    umount /mnt
  '';
}
