# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ python3Packages
, src
}:

python3Packages.buildPythonPackage {
  name = "smdv";
  inherit src;
  propagatedBuildInputs = with python3Packages; [ flask websockets ];
}
