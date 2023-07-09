# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ ... }:

{
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };
}
