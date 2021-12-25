# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou
#
# Shell-agnostic aliases

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

  # git convert https GitHub remote URL to ssh
  gh2ssh =
    let
      username = (import ../../../lib {}).me.github.username;
    in
      ''git remote set-url origin $(git remote get-url origin | sed "s/https:\/\/\(${username}@\)\?github.com\/${username}\/\([^\.]*\)\(\.git\)\?/git@github.com:${username}\/\2/")'';

  # editor
  e = "nvim";

  # emacs
  emacs = "emacs --color=16";
  org   = "emacs ~/org/index.org";

  # enter conf.nix directory
  ccd = "cd ${(import ../../../lib {}).me.home.confDirectory}";

  # view thumbnails with feh
  thumbs = "sh -c 'feh -t --thumb-width 300 --thumb-height 300 >/dev/null 2>&1 & disown'";

  # nix-shell with zsh
  nix-zsh = "nix-shell --run zsh";
}
