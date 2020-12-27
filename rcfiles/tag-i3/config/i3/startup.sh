#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Chua Hou
#
# Starts everything in startup.d.

for script in $(dirname $0)/startup.d/*.sh; do
	$script &
done
