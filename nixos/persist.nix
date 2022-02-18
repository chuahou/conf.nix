# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ ... }:

{
  security.sudo.extraConfig = "Defaults lecture = never";

  # make /bin/bash after boot
  boot.postBootCommands = ''
    cat > /bin/bash << EOF
        #!/bin/sh
        /usr/bin/env bash \$@
    EOF
    chmod +x /bin/bash
  '';
}
