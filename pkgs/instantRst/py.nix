# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ python3Packages
, src
}:

python3Packages.buildPythonPackage {
  pname   = "instantRst";
  version = "0.9.9.1";
  doCheck = false;
  inherit src;
  propagatedBuildInputs = with python3Packages; [
    docutils
    flask
    flask-socketio
    pygments
  ];
}
