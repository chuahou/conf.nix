#!/usr/bin/env nix-shell
#!nix-shell -i bash -p mkpasswd git coreutils
# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Creates a repo ../secrets.nix with a single file ../secrets.nix/default.nix
# containing the desired secrets (prompted during the script's run), and a
# pseudorandom generated file ../secrets.nix/random to minimimze predictability
# of the git revision hash.

set -eu

SECRETS_REPO=../secrets.nix
SECRETS_FILE=${SECRETS_REPO}/default.nix
RANDOM_FILE=${SECRETS_REPO}/random

mkpasswdfn ()
{
	mkpasswd -m sha-512
}
gitfn ()
{
	git -C ${SECRETS_REPO} "${@}"
}

mkdir ${SECRETS_REPO}
dd if=/dev/urandom of=${RANDOM_FILE} bs=4096 count=1

cat > ${SECRETS_FILE} <<EOF
{
	root.hashedPassword = "$(mkpasswdfn)";
	user.hashedPassword = "$(mkpasswdfn)";
}
EOF

gitfn init
gitfn add .
gitfn commit -m "initial: by ${0}"
