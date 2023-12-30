# SPDX-License-Identifier: MIT
# Copyright (c) 2021, 2023 Chua Hou
#
# Shell-agnostic aliases

{ config }:

{
  # basic commands
  ls   = "ls --group-directories-first --color=tty";
  rm   = "rm -i";
  q    = "exit";
  wget = "wget -c";

  # enable aliases in sudo
  sudo = "sudo ";

  # make tree max depth 3 by default and exclude .git folder
  tree = "tree -L 3 -I .git";

  # set lifetime by default to 10m for ssh-add
  ssh-add = "ssh-add -t 10m";

  # fun
  please  = "sudo";
  fucking = "sudo";
  meow    = "echo meow";

  # git
  add   = "git add";
  a     = "git add";
  aa    = "git add .";
  c     = "git commit";
  cm    = "git commit -m";
  fix   = "git commit --amend --no-edit";
  amend = "git commit --amend";
  d     = "git diff";
  ds    = "git diff --staged";
  s     = "git status";
  p     = "git push";
  pull  = "git pull";
  log   = "git log";
  l     = "git log --oneline --decorate";
  l1    = "l -n 1";
  lshow = "git log -n 1";

  # editor
  e = "$VISUAL";

  # enter conf.nix directory
  ccd = "cd ${config.home.homeDirectory}/dev/conf.nix";

  # view thumbnails with feh
  thumbs = "sh -c 'feh -t --thumb-width 300 --thumb-height 300 >/dev/null 2>&1 & disown'";

  # nix-shell with zsh
  nix-shell = "nix-shell --run zsh";

  # by default, run nix-env with <nixos> since we set NIX_PATH manually instead
  # of using channels
  nix-env = "nix-env -f '<nixos>'";
}
