# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, ... }:

let
  configDir = "${config.xdg.configHome}/nvim";

  # python package used by InstantRst plugin
  instantRst =
    pkgs.python3Packages.buildPythonPackage rec {
      name    = "instantRst";
      version = "0.9.9.1";
      doCheck = false;
      src = builtins.fetchGit {
        inherit name;
        url = "https://github.com/gu-fan/instant-rst.py";
        ref = "refs/heads/master";
        rev = "305be3a7e10481a546f5802ec2e5e53d450a8a18";
      };
      propagatedBuildInputs = with pkgs.python3Packages; [
        docutils
        flask
        flask-socketio
        pygments
      ];
    };

in
  {
    # copy entire nvim configuration directory
    xdg.configFile.nvim.source = ../res/nvim;

    programs.neovim = {
      enable = true;

      configure = {
        customRC = ''
          " we use the full configuration copied
          set runtimepath^=${configDir} runtimepath+=${configDir}/after
          source ${configDir}/init.vim

          " additional plugin customization

          " vim-airline
          let g:airline_theme = 'angr'
          let g:airline#extensions#whitespace#mixed_indent_algo = 1
          let g:airline#extensions#checks = [
            \ 'indent', 'long', 'trailing', 'mixed-indent-file', 'conflicts' ]
          let g:airline#extensions#whitespace#skip_indent_check_ft = {
            \ 'vim': ['trailing'],
            \ }

          " faster updates for coc/vim-gitgutter etc
          set updatetime=100

          " coc configuration
          " original example at
          " https://github.com/neoclide/coc.nvim#example-vim-configuration

          " more space to display
          set cmdheight=2

          " trigger completion with <C-space>
          inoremap <silent><expr> <C-space> coc#refresh()

          " activate actions with <C-space>
          nmap <C-space> :CocAction<CR>

          " diagnostics navigation
          nmap <silent> [g <Plug>(coc-diagnostic-prev)
          nmap <silent> ]g <Plug>(coc-diagnostic-next)

          " code navigation
          nmap <silent> gd <Plug>(coc-definition)
          nmap <silent> gy <Plug>(coc-type-definition)
          nmap <silent> gi <Plug>(coc-implementation)
          nmap <silent> gr <Plug>(coc-references)

          " use K to show documentation in preview window
          nnoremap <silent> K :call <SID>show_documentation()<CR>
          function! s:show_documentation()
              if (index(['vim','help'], &filetype) >= 0)
                  execute 'h '.expand('<cword>')
              elseif (coc#rpc#ready())
                  call CocActionAsync('doHover')
              else
                  execute '!' . &keywordprg . " " . expand('<cword>')
              endif
          endfunction

          " add instantRst to path for InstantRst plugin
          let $PATH .= ':' . '${instantRst}/bin'
        '';

        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # language plugins
            coc-nvim
            haskell-vim
            vim-nix

            # alignment
            tabular

            # vim-airline
            vim-airline
            vim-airline-themes

            # git sign column
            vim-gitgutter

            # InstantRst
            (pkgs.vimUtils.buildVimPlugin rec {
              name = "InstantRst";
              src  = builtins.fetchGit {
                inherit name;
                url = "https://github.com/gu-fan/InstantRst";
                ref = "refs/heads/master";
                rev = "52144e8adb307db2c101432d2b90d84fb4255f61";
              };
            })
          ];
        };
      };

      viAlias      = true;
      vimAlias     = true;
      vimdiffAlias = true;

      # for coc.nvim
      withNodeJs = true;

      # for InstantRst
      extraPython3Packages = _: [ instantRst ];
    };
  }
