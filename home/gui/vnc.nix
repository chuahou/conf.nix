# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# Script to use TigerVNC to start the VNC server on the remote host, SSH tunnel
# to that host, start a viewer here, and cleanup as necessary.

{ config, pkgs, lib, ... }:

let
  inherit (import ../../lib { inherit pkgs lib; }) mkPath;
  vnc = pkgs.writeShellScriptBin "vnc" /* bash */ ''
    set -euo pipefail

    ${mkPath (with pkgs; [ coreutils openssh openssl tigervnc ])}

    # Server to connect to.
    server=$1

    # Temporary working directory to keep things in.
    temp_dir=$(mktemp -p $XDG_RUNTIME_DIR -d)
    passwd_file=$temp_dir/passwd
    ssh_ctrl_socket=$temp_dir/ssh_ctrl_socket

    # Perform cleanup upon exit.
    cleanup () {
        set +e
        # Close SSH connection if it exists.
        ssh -S $ssh_ctrl_socket -O check $server \
            && ssh -S $ssh_ctrl_socket -O exit $server \
            || true
        # Stop VNC server.
        ssh $server vncserver -kill :1
        # Delete passwd file on remote.
        ssh $server rm .vnc/passwd
        # Remove temporary files.
        rm $temp_dir -rf
        # WORKAROUND: on the server I use this on, for some reason many
        # ssh-agents are spawned. So this dirty solution for now.
        ssh $server killall ssh-agent
    }
    trap "cleanup" 0 1 2 15

    # Add SSH key if not yet added.
    ssh-add -l || ssh-add -t 4h

    # Generate password and copy it to server.
    openssl rand -base64 20 | vncpasswd -f - > $passwd_file
    scp $passwd_file $server:.vnc/passwd
    ssh $server chmod 600 .vnc/passwd

    # Start VNC server and tunnel.
    ssh $server vncserver :1
    ssh -S $ssh_ctrl_socket -M -fNT -L 5901:localhost:5901 $server

    # Start VNC viewer.
    sleep 2
    vncviewer localhost:5901 -passwd $passwd_file

    # Upon exit, should call cleanup.
  '';

in { home.packages = [ vnc ]; }
