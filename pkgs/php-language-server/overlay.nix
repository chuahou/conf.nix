# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

self: super: {
  php-language-server = super.callPackage ./. {
    src = super.flakeInputs.php-language-server;
  };
}
