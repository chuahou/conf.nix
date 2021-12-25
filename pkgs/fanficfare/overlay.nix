# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

self: super: {
  fanficfare = super.fanficfare.overrideAttrs (old: rec {
    name = "${old.pname}-${version}";
    version = "4.8.0";
    src = super.python3Packages.fetchPypi {
      inherit (old) pname;
      inherit version;
      sha256 = "sha256-0yV4QvwSy/OvqZ04cn8hccyMWXcXEQqdIH9M8xNnQEA=";
    };
    propagatedBuildInputs = (old.propagatedBuildInputs or []) ++
      (with super.python3Packages; [
        cloudscraper
        requests-file
      ]);
  });
}
