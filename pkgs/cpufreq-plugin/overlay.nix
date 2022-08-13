# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

src: self: super: {
  cpufreq-plugin = super.callPackage ./. { inherit src; };
  cpufreq-plugin-wrapped = self.callPackage ./wrapped.nix {};
}
