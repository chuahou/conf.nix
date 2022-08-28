# SPDX-License-Identifier: MIT
# Copyright (c) 2021 Chua Hou

{ config, pkgs, ... }:

let
  configLocation = "nvim/copied";
  configDir = "${config.xdg.configHome}/${configLocation}";
in {
  # copy entire nvim configuration directory
  xdg.configFile = {
    ${configLocation}.source = ../res/nvim;
  };

  # copy editorconfig
  home.file.".editorconfig".source = ../res/editorconfig;

  programs.neovim = {
    enable = true;

    package = pkgs.neovim-unwrapped;

    extraConfig = ''
      " faster updates for coc/vim-gitgutter etc
      set updatetime=100

      " start with folds open by default
      set foldlevelstart=99

      " we use the full configuration copied
      set runtimepath^=${configDir} runtimepath+=${configDir}/after
      source ${configDir}/init.vim
    '';

    plugins = with pkgs.vimPlugins; [
      # language plugins
      coc-clangd
      haskell-vim
      vim-stylish-haskell
      vim-markdown
      vim-nix
      {
        plugin = coc-nvim;
        config = ''
          let g:coc_config_home = "${configDir}"

          " original example at
          " https://github.com/neoclide/coc.nvim#example-vim-configuration

          " more space to display
          set cmdheight=2

          " trigger completion with <C-space>
          inoremap <silent><expr> <C-space> coc#refresh()

          " activate actions with <C-space>
          nmap <C-space> <Plug>(coc-codeaction-line)

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
        '';
      }
      coc-vimtex
      {
        plugin = vimtex;
        config = ''
          " use LaTeX flavour by default
          let g:tex_flavor = 'latex'

          " disable alignment of ampersands
          let g:vimtex_indent_on_ampersands = 0

          " disable imaps mappings since ` is used often
          let g:vimtex_imaps_enabled = 0

          " configure vimtex folding
          let g:vimtex_fold_enabled = 1
          let g:vimtex_indent_lists = [
            \"itemize",
            \"enumerate",
            \"questionize",
            \]

          " use Zathura as viewer
          let g:vimtex_view_method = 'zathura'
        '';
      }

      # orgmode and treesitter (solely for orgmode for now)
      (nvim-treesitter.withPlugins (_: [ pkgs.tree-sitter-org ]))
      {
        plugin = orgmode;
        config = ''
          lua <<EOF
            require('orgmode').setup_ts_grammar()
            require('nvim-treesitter.configs').setup({
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = { 'org' }
              }
            })
            require('orgmode').setup({})
          EOF
        '';
      }

      # alignment
      tabular

      # vim-airline
      {
        plugin = vim-airline;
        config = ''
          let g:airline_theme = 'angr'
          let g:airline#extensions#whitespace#mixed_indent_algo = 2
          let g:airline#extensions#checks = [
            \ 'indent', 'long', 'trailing', 'mixed-indent-file', 'conflicts' ]
          let g:airline#extensions#whitespace#skip_indent_check_ft = {
            \ 'vim': ['trailing'],
            \ }

          " custom symbols for vim-airline
          if !exists('g:airline_symbols')
            let g:airline_symbols = {}
          endif
          let g:airline_symbols.maxlinenr = ' ln'
        '';
      }
      vim-airline-themes

      # git sign column
      vim-gitgutter

      # editorconfig
      editorconfig-vim

      # fzf
      {
        plugin = fzf-vim;
        config = ''
          " Buffer commands. Buffer functions thanks to
          " https://github.com/junegunn/fzf.vim/pull/733#issuecomment-559720813.
          function! FZF_list_buffers()
              redir => list
              silent ls
              redir END
              return split(list, "\n")
          endfunction
          function! FZF_del_buffers(lines)
              execute 'bd' join(map(a:lines, {_, line -> split(line)[0]}))
          endfunction
          nnoremap <Leader>b :Buffers<CR>
          nnoremap <Leader>B :call fzf#run(fzf#wrap({
              \'source': FZF_list_buffers(),
              \'sink*':  { lines -> FZF_del_buffers(lines) },
              \'options': '--multi --reverse --bind ctrl-a:select-all'
              \}))<CR>

          " <C-r> to search command history while in command mode. (Deletes all
          " current command text.)
          cnoremap <C-r> <C-\><C-n>:History:<CR>

          " Shorter commands.
          cnoreabbrev Hi History
          cnoreabbrev Fi Files
          cnoreabbrev GFi GFiles
        '';
      }

      # snippets
      {
        plugin = ultisnips;
        config = ''
          let g:UltiSnipsExpandTrigger       = '<Tab>'
          let g:UltiSnipsJumpForwardTrigger  = '<Tab>'
          let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
        '';
      }

      # goyo.vim
      {
        plugin = goyo-vim;
        config = ''
          " We only care about setting options when entering, and count on
          " restarting to restore options, since it is not scalable to maintain.
          function! s:writing_goyo_enter()
              set listchars=tab:\ \ ,trail:+
              set signcolumn=no
              set foldcolumn=0
              set spell
              call goyo#execute(0, "")
          endfunction

          command! Write call <SID>writing_goyo_enter()
        '';
      }

      # NERDTree to be automatically opened by Goyo
      {
        plugin = nerdtree;
        config = ''
          " \n to open and focus NERDTree
          nmap <Leader>n :NERDTreeFocus<CR>
        '';
      }

      # misc
      fastfold # fast folding (important for vimtex)
    ];

    # Extra packages in neovim's path for plugins to access.
    extraPackages = with pkgs; [
      xsel # For clipboard support.
      xdotool # For vimtex's synctex.
      ripgrep # For fzf.vim.
      stylish-haskell # For, surprise, surprise, stylish-haskell.

      # Language servers.
      clang-tools haskell-language-server rnix-lsp
    ];

    viAlias      = true;
    vimAlias     = true;
    vimdiffAlias = true;

    # for coc.nvim
    withNodeJs = true;
  };
}
