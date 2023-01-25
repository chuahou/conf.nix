# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou
#
# Provide a "not insecure" Python 2 to packages that desperately need it for
# now. See #14. Shouldn't be too bad since nixpkgs is now using ActiveState's
# fork, I suppose...?

self: super:
  let
    # Package set with Python 2's known vulnerability removed. We assert that
    # the old meta.knownVulnerabilities is as we expect it to be, in case there
    # are more added/changed that we shouldn't automatically ignore. We make a
    # new package set instead of adding it in the same overlay to prevent it
    # from being available to any other packages, and we need it to be done in
    # an overlay so that other Python-related packages depending on python27
    # will have changes propagated to them.
    expectedKnownVuln = [
      "Python 2.7 has reached its end of life after 2020-01-01. See https://www.python.org/doc/sunset-python-2/."
    ];
    pkgs' = import super.path {
      inherit (super) system config;
      overlays = [ (self: super: {
        python27 = super.python27.overrideAttrs
          (old:
            assert old.meta.knownVulnerabilities == expectedKnownVuln;
            super.lib.recursiveUpdate old
              { meta.knownVulnerabilities = []; });
      }) ];
    };
  in {
    # Our GIMP plugins need Python 2 support.
    gimp = super.gimp.override {
      withPython = true;
      python2 = pkgs'.python2;
    };
  }
