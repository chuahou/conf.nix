# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# Script to spin up a (temporary) DigitalOcean droplet to perform remote nix
# builds. Requires a NixOS (or other nix-equipped image) to spin up.
#
# Usage: remote-up
# Usage: remote-nix [arguments as to `nix`]
# Usage: remote-down
#
# For remote-build, the command will be run as
#   nom $1 <remote build options> <rest of args>
# in order to allow overriding remote build options.
#
# Most constants in the script can be overridden by setting them in advance,
# e.g. DO_REGION=sgp1 STATE_DIR=../dir remote-up.

{ config, pkgs, lib, ... }:

let
  # Default constant values.
  doImage = "127352009";
  doSizeSlug = "s-8vcpu-16gb-amd";
  remoteJobs = 16;
  doRegion = "lon1";
  nixCommand = "${pkgs.nix-output-monitor}/bin/nom";
  stateDir = "${config.xdg.dataHome}/remote-build";

  inherit (import ../../lib { inherit pkgs lib; }) mkPath;
  remote-build-script = pkgs.writeShellScript "remote-build-script"
  /* bash */ ''
    set -euo pipefail

    # DigitalOcean constants. Get them if necessary from the Droplet creation
    # page and click "create from command line".
    IMAGE=''${DO_IMAGE:-${doImage}}
    SIZE=''${DO_SIZE:-${doSizeSlug}}
    REGION=''${DO_REGION:-${doRegion}}
    DO_API=https://api.digitalocean.com

    # Default nix build options.
    REMOTE_JOBS=''${REMOTE_JOBS:-${builtins.toString remoteJobs}}
    LOCAL_JOBS=0 # Overrideable with --max-jobs.
    NIX_COMMAND=''${NIX_COMMAND:-${nixCommand}}

    # Paths to store state.
    STATE_DIR=''${REMOTE_BUILD_STATE_DIR:-${stateDir}}
    SSH_KEY_PATH=$STATE_DIR/ssh_id
    DO_SSH_KEY_ID_PATH=$STATE_DIR/do_ssh_key_id
    DO_DROPLET_ID_PATH=$STATE_DIR/do_droplet_id
    DO_DROPLET_IPV4_PATH=$STATE_DIR/do_droplet_ipv4
    DO_TOKEN_PATH=$STATE_DIR/do_token

    # Print info message.
    echoi () {
        tput setaf 4 # Blue.
        echo "$@"
        tput sgr0
    }

    do_request () {
        curl -sS -H "Authorization: Bearer $(cat $DO_TOKEN_PATH)" "$@"
    }

    do_request_json () {
        do_request -H "Content-Type: application/json" "$@"
    }

    up () {
        if [ -d $STATE_DIR ]; then
            echo "Remote already up. Please run remote-down first."
            exit 1
        fi
        mkdir -p $STATE_DIR

        # Create SSH key.
        echoi "Creating SSH key at $SSH_KEY_PATH."
        ssh-keygen -t ed25519 -f $SSH_KEY_PATH -N ""

        # Get DigitalOcean token.
        echo ""
        echo "https://cloud.digitalocean.com/account/api/tokens"
        read -s -p "DigitalOcean Personal Access Token: " token
        echo ""
        echo -n $token > $DO_TOKEN_PATH

        echoi "Uploading SSH key to DO."
        SSH_KEY_NAME=remote-build-$(date -Iseconds)
        SSH_KEY_ID=$(do_request_json -X POST -d \
            "{\"name\": \"$SSH_KEY_NAME\", \"public_key\": \"$(cat $SSH_KEY_PATH.pub)\"}" \
            $DO_API/v2/account/keys | jq -r '.ssh_key.id')
        echo $SSH_KEY_ID
        echo -n $SSH_KEY_ID > $DO_SSH_KEY_ID_PATH

        echoi "Creating Droplet."
        DROPLET_ID=$(do_request_json -X POST -d \
            "{\"name\": \"remote-build\", \"region\": \"$REGION\",
                \"size\": \"$SIZE\", \"image\": \"$IMAGE\",
                \"ssh_keys\": \"$SSH_KEY_ID\"}" \
            $DO_API/v2/droplets | jq -r '.droplet.id')
        echo $DROPLET_ID
        echo -n $DROPLET_ID > $DO_DROPLET_ID_PATH

        echoi "Waiting for Droplet to go up."
        DROPLET_IP=$(until do_request -X GET $DO_API/v2/droplets/$DROPLET_ID \
            | jq -re '.droplet.networks.v4[] | select (.type == "public") | .ip_address'
            do sleep 10; done)
        echo $DROPLET_IP
        echo -n $DROPLET_IP > $DO_DROPLET_IPV4_PATH

        # Check Droplet is up, get its host key and get our root to accept it.
        echoi "Trying to SSH to check if Droplet is up."
        sudo bash -c "mkdir -p ~root/.ssh; until ssh-keyscan -t ed25519 $DROPLET_IP; do sleep 1; done >> ~root/.ssh/known_hosts"
        until sudo ssh -i $SSH_KEY_PATH -o ConnectTimeout=10 root@$DROPLET_IP true; do
            sleep 1
        done
    }

    nix () {
        if [ ! -d $STATE_DIR ]; then
            echo "Remote not yet up. Please run remote-up first."
            exit 1
        fi
        cmd=$1
        shift
        set -x
        $NIX_COMMAND $cmd \
            --builders "ssh://root@$(cat $DO_DROPLET_IPV4_PATH) x86_64-linux,i686-linux $SSH_KEY_PATH $REMOTE_JOBS - big-parallel,kvm,nixos-test,benchmark" \
            --max-jobs $LOCAL_JOBS \
            --option builders-use-substitutes true \
            "$@"
        set +x
    }

    down () {
        if [ ! -d $STATE_DIR ]; then
            echo "Remote not yet up. Please run remote-up first."
            exit 1
        fi

        # Don't exit on error, perform any cleanup possible.
        set +e

        echoi "Deleting Droplet."
        do_request -X DELETE $DO_API/v2/droplets/$(cat $DO_DROPLET_ID_PATH) \
            && rm $DO_DROPLET_ID_PATH

        echoi "Removing SSH fingerprint of Droplet."
        sudo ssh-keygen -R $(cat $DO_DROPLET_IPV4_PATH) -f ~root/.ssh/known_hosts \
            && rm $DO_DROPLET_IPV4_PATH

        echoi "Removing SSH key from DO."
        do_request -X DELETE $DO_API/v2/account/keys/$(cat $DO_SSH_KEY_ID_PATH) \
            && rm $DO_SSH_KEY_ID_PATH

        echoi "Deleting DO token."
        rm $DO_TOKEN_PATH

        echoi "Deleting SSH key."
        rm $SSH_KEY_PATH{,.pub}

        # If all's gone well, $STATE_DIR should be empty.
        echoi "Deleting state directory $STATE_DIR."
        rmdir $STATE_DIR

        tput setaf 9
        tput bold
        echo "Remember to remove the DO token if necessary."
        tput sgr0
        echo "https://cloud.digitalocean.com/account/api/tokens"
    }

    case "$(basename $0)" in
        remote-up) up "$@";;
        remote-nix) nix "$@";;
        remote-down) down "$@";;
        *) exit 1;;
    esac
  '';

  # Package with all names symlinked.
  symlinked = pkgs.runCommand "remote-build" {} /* bash */ ''
    mkdir -p $out/bin
    for symlink in remote-up remote-nix remote-down; do
        symlinkPath=$out/bin/$symlink
        ln -s ${remote-build-script} $symlinkPath
    done
  '';

in { home.packages = [ symlinked ]; }
