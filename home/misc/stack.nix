# SPDX-License-Identifier: MIT
# Copyright (c) 2022 Chua Hou

{ ... }:

{
  # We don't need any stack config, but we never need stack upgrade
  # recommendations since all the stacks we use are momentary ones in shells.
  home.file.".stack/config.yaml".text = builtins.toJSON {
    recommend-stack-upgrade = false;
  };
}
