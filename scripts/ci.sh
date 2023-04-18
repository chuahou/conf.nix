#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused findutils coreutils nixUnstable
# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# To be run on CI (e.g. GitHub actions).
# Builds both NixOS/home configurations' paths for derivations that do not exist
# on cache. This is an approximation that aims to capture most time-consuming
# derivations to compile, while not containing large quantities of wasted
# downloads and space (which would be what happens if we built the entire
# configuration).
#
# Note that we use nixUnstable (see the shebang) due to
# cachix/install-nix-action also using nixUnstable, so by doing so we can make
# it so we use the same nix action.

set -euo pipefail

# Hostnames to work over.
hosts=$(nix eval .\#hosts --raw --apply 'builtins.concatStringsSep " "')

# Generates list of derivations in NixOS configuration path for hostname $1.
gen_nixos_drvs () {
	local system_path_drv=$(nix eval --raw \
		.\#nixosConfigurations.$1.config.system.path.drvPath)
	nix derivation show "$system_path_drv^*" | \
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
	echo -n ' '
	>&2 echo "Generating home-manager configuration's derivations for $host."
	gen_home_drvs $host
	echo -n ' '
done)
drvs=$(echo $drvs | xargs -n1 | sort -u | xargs)

# Filter derivations by whether they exist on cache.
>&2 echo "Checking $(wc -w <<< $drvs) derivations."
drvs=$(for drv in $drvs; do
	narinfo=$(nix derivation show $drv^out | \
		jq -r '.[].outputs.out.path' | \
		sed 's@^/nix/store/\([a-z0-9]\+\)-.*$@\1@').narinfo
	curl -sfL https://cache.nixos.org/$narinfo >/dev/null \
		|| curl -sfL https://chuahou.cachix.org/$narinfo >/dev/null \
		|| echo "$drv^*"
		# Was not in cache, so we keep it in the list, appending ^*.
done)

# Build derivations that were not on caches. We use --keep-going so that even if
# some derivations fail, the rest will continue to be built and pushed to cache.
NUM_TO_BUILD=$(wc -w <<< $drvs)
if [ $NUM_TO_BUILD -gt 0 ]; then
	>&2 echo "Building $(wc -w <<< $drvs) derivations."
	nix build --print-out-paths --no-link --keep-going $(xargs <<< $drvs)
else
	>&2 echo "No derivations to build."
fi
