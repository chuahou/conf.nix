#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused findutils coreutils
# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# To be run on CI (e.g. GitHub actions).
# Builds both NixOS/home configurations' paths for derivations that do not exist
# on cache. This is an approximation that aims to capture most time-consuming
# derivations to compile, while not containing large quantities of wasted
# downloads and space (which would be what happens if we built the entire
# configuration).

set -euo pipefail

# Hostnames to work over.
hosts=$(nix eval .\#hosts --raw --apply 'builtins.concatStringsSep " "')

# Generates list of derivations in NixOS configuration path for hostname $1.
gen_nixos_drvs () {
	local system_path_drv=$(nix eval --raw \
		.\#nixosConfigurations.$1.config.system.path.drvPath)
	nix show-derivation $system_path_drv | \
		jq -r '.[].inputDrvs | keys | .[]'
}

# Generates list of derivations in home-manager programs path for hostname $1.
gen_home_drvs () {
	nix eval --raw .\#homeConfigurations.$1.config.home.packages \
		--apply 'pkgs: builtins.concatStringsSep " " (builtins.map (pkg: pkg.drvPath) pkgs)'
}

# Generate all derivations we need and deduplicate them.
drvs=$(for host in $hosts; do
	>&2 echo "Generating NixOS configuration's derivations for $host."
	gen_nixos_drvs $host
	>&2 echo "Generating home-manager configuration's derivations for $host."
	gen_home_drvs $host
done)
drvs=$(echo $drvs | xargs -n1 | sort -u | xargs)

# Check if each derivation is on our caches, otherwise build it.
>&2 echo "Checking/building $(wc -w <<< $drvs) derivations."
unset FAILED # String not set as long as we don't fail any derivation.
for drv in $drvs; do
	narinfo=$(nix show-derivation $drv | \
		jq -r '.[].env.out' | \
		sed 's@^/nix/store/\([a-z0-9]\+\)-.*$@\1@').narinfo
	curl -sfL https://cache.nixos.org/$narinfo >/dev/null \
		|| curl -sfL https://chuahou.cachix.org/$narinfo >/dev/null \
		|| nix build --print-out-paths --no-link $drv \
		|| FAILED=yes
		# We failed so set the string. However, we continue building the rest to
		# populate the cache as much as possible.
done

# Return error code if one of the derivations failed.
[[ ! -v FAILED ]]
