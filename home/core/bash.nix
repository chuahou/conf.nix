{ config, lib, ... }:

{
  programs.bash = {
    enable    = true;
    initExtra = import ../lib/shell { inherit config lib; };
  };
}
