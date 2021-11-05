# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

self: super: {
  cpufreq-plugin = super.callPackage ./. {
    src = super.flakeInputs.cpufreq-plugin;
  };
  cpufreq-plugin-wrapped = self.callPackage  ./wrapped.nix {};
}
