#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2022 Chua Hou
#
# Updates everything.

set -euo pipefail

# update commits
nix flake update

# upgrade packages
$(dirname $0)/sync-update.sh
