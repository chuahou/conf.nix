#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Does the equivalent of 'home-manager switch' with the current flakes setup.

set -eu

# build activation package
FLAKE=$(dirname ${0})/..#hmConfigs.${USER}.activationPackage
nix build ${FLAKE}

# activate new generation, with 'VERBOSE' if '-v' is passed
while getopts "v" opt; do
	if [ ${opt} = "v" ]; then
		export VERBOSE="yes"
	fi
done
result/activate
