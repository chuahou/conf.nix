# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ writeShellScriptBin
, cpufrequtils
, gnused
, cpufreq-plugin
}:

writeShellScriptBin "cpufreq-plugin" ''
  PATH=${cpufrequtils}/bin:${gnused}/bin ${cpufreq-plugin}/bin/cpufreq-plugin "$@"
''
