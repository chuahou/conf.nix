# conf.nix

[![](https://forthebadge.com/images/badges/no-ragrets.svg)](https://forthebadge.com)  
[![Build derivations with updated inputs](https://github.com/chuahou/conf.nix/actions/workflows/ci.yml/badge.svg)](https://github.com/chuahou/conf.nix/actions/workflows/ci.yml)

Personal configuration for NixOS, home-manager and others.

## Usage

1. Partition accordingly.
1. Set up LUKS as appropriate.
	1. `cryptsetup luksFormat /dev/XXX`
	1. `cryptsetup open /dev/XXX crypt`
	1. `pvcreate /dev/mapper/crypt`
	1. `vgcreate data /dev/mapper/crypt`
	1. `lvcreate -n swap -L 4G data`
	1. `lvcreate -n root -l 100%FREE data`
	1. `mkswap /dev/mapper/data-swap`
	1. `mkfs.btrfs /dev/mapper/data-root`
1. Create subvolumes.
	1. `mount -t btrfs /dev/mapper/data-root -o noatime,ssd,space_cache=v2,commit=120,compress=zstd /mnt`
	1. `for i in root home nix persist log; do btrfs sub create /mnt/$i; done`
	1. `btrfs sub snap -r /mnt/root{,-blank}`
	1. `umount /mnt`
	1. `mount -t btrfs /dev/mapper/data-root -o noatime,ssd,space_cache=v2,commit=120,compress=zstd,subvol=root /mnt`
	1. `mkdir -p /mnt/{home,nix,persist,var/log,boot}`
	1. `for i in home nix persist; do mount -t btrfs /dev/mapper/data-root -o noatime,ssd,space_cache=v2,commit=120,compress=zstd,subvol=$i /mnt/$i; done`
	1. `mount -t btrfs /dev/mapper/data-root -o noatime,ssd,space_cache=v2,commit=120,compress=zstd,subvol=log /mnt/var/log`
	1. `mount /dev/BOOTPARTITION /mnt/boot`
1. `nixos-generate-config --root /mnt` and copy relevant generated details to a
   new host under `nixos/`.
1. Write host-specific config under new host under `nixos/`.
	1. UUIDs can be found using `blkid | grep UUID`.
1. Setup password files.
	1. `mkdir -p /mnt/persist/passwd`
	1. `mkpasswd -m sha-512 > /mnt/persist/passwd/root`
	1. `mkpasswd -m sha-512 > /mnt/persist/passwd/user`
1. `nixos-install --impure --flake /path/to/conf.nix#NEWHOSTNAME`

## Previously on configuration repos

RIP [kiwami](https://github.com/chuahou/kiwami),
[utility repo](https://github.com/chuahou/utility>)
