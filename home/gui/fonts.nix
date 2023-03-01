# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Chua Hou

{ ... }:

{
  # Get Japanese fallback using M PLUS 2.
  xdg.configFile."fontconfig/conf.d/99-mplus2.conf".text = /* xml */ ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
        <alias>
            <family>Mplus Code 60</family>
            <prefer>
                <family>Mplus Code 60</family>
                <family>M PLUS 2</family>
            </prefer>
        </alias>
    </fontconfig>
  '';
}
