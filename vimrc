;; let s:settings = {}
;; let s:settings.dein_dir = expand('~/.cache/dein')
;; let s:settings.dein_repo_dir = s:settings.dein_dir . '/repos/github.com/Shougo/dein.vim'
;; 
;; "-------------------------------------------------------------------------------
;; " Plugin Manager
;; "-------------------------------------------------------------------------------
;; 
;; " Bootstrap:
;; if &runtimepath !~# '/dein.vim'
;; 	if !isdirectory(s:settings.dein_repo_dir)
;;     execute '!git clone --depth 1 https://github.com/Shougo/dein.vim ' . s:settings.dein_repo_dir 
;;   endif
;;   execute 'set rtp^=' . fnamemodify(s:settings.dein_repo_dir, ':p')
;; endif
;; 
;; " Dein:
;; if &compatible
;;   set nocompatible               " Be iMproved
;; endif
;; 
;; set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim
;; 
;; if dein#load_state(s:settings.dein_dir)
;;   call dein#begin(s:settings.dein_dir)
;;   call dein#add(s:settings.dein_repo_dir)
;; 
;;   " Libraries:
;;   call dein#add('google/vim-maktaba')
;;   " call dein#add('tomtom/tlib_vim')
;;   call dein#add('google/vim-glaive')
;; 
;;   " Basics:
;;   call dein#add('tpope/vim-abolish')
;;   call dein#add('tpope/vim-endwise')
;;   call dein#add('tpope/vim-eunuch')
;;   call dein#add('tpope/vim-ragtag')
;;   call dein#add('tpope/vim-repeat')
;;   call dein#add('tpope/vim-surround')
;; 
;;   " TpopeFanboySection:
;;   call dein#add('tpope/vim-classpath')
;;   call dein#add('tpope/vim-commentary')
;;   call dein#add('tpope/vim-cucumber')
;;   call dein#add('tpope/vim-dispatch')
;;   call dein#add('tpope/vim-fireplace')
;;   call dein#add('tpope/vim-fugitive')
;;   call dein#add('tpope/vim-haml')
;;   call dein#add('tpope/vim-markdown')
;;   call dein#add('tpope/vim-projectionist')
;;   call dein#add('tpope/vim-rails')
;;   call dein#add('tpope/vim-rhubarb')
;;   call dein#add('tpope/vim-rsi')
;;   call dein#add('tpope/vim-salve')
;;   call dein#add('tpope/vim-sensible')
;;   call dein#add('tpope/vim-sexp-mappings-for-regular-people')
;;   call dein#add('tpope/vim-speeddating')
;;   call dein#add('tpope/vim-tbone')
;;   call dein#add('tpope/vim-unimpaired')
;; 
;;   " UI:
;;   call dein#add('airblade/vim-gitgutter')
;;   call dein#add('arcticicestudio/nord-vim')
;;   call dein#add('bling/vim-bufferline')
;;   call dein#add('godlygeek/tabular')
;;   call dein#add('kien/ctrlp.vim')
;;   call dein#add('kien/rainbow_parentheses.vim')
;;   call dein#add('preservim/nerdtree')
;;   call dein#add('Raimondi/delimitMate')
;;   call dein#add('scrooloose/nerdcommenter')
;;   call dein#add('tmux-plugins/vim-tmux')
;;   call dein#add('tmux-plugins/vim-tmux-focus-events')
;;   call dein#add('vim-airline/vim-airline')
;;   call dein#add('vim-airline/vim-airline')
;;   call dein#add('vim-syntastic/syntastic')
;;   call dein#add('wsdjeg/dein-ui.vim')
;; 
;;   " System:
;;   call dein#add('Chun-Yang/vim-action-ag')
;;   call dein#add('rking/ag.vim')
;;   call dein#add('bazelbuild/vim-bazel')
;;   " call dein#add('google/vim-codefmt')
;;   call dein#add('direnv/direnv.vim')
;;   call dein#add('junegunn/fzf')
;;   call dein#add('justinmk/vim-sneak')
;;   call dein#add('mattn/gist-vim')
;; 
;;   " Files:
;;   call dein#add('dln/avro-vim')
;;   call dein#add('fatih/vim-go')
;;   call dein#add('guns/vim-clojure-highlight')
;;   call dein#add('guns/vim-clojure-static')
;;   call dein#add('guns/vim-sexp')
;;   call dein#add('guns/vim-slamhound')
;;   call dein#add('itspriddle/vim-shellcheck')
;;   call dein#add('leafgarland/typescript-vim')
;;   call dein#add('mxw/vim-jsx')
;;   call dein#add('pangloss/vim-javascript')
;; 
;;   call dein#end()
;;   call dein#save_state()
;; endif
;; 
;; filetype plugin indent on
;; 
;; syntax enable
;; 
;; " if dein#check_install()
;; "   call dein#install()
;; " endif
;; "-------------------------------------------------------------------------------
;; " Basics
;; "-------------------------------------------------------------------------------
;; set background=dark
;; 
;; " Use <Leader> in global plugin.
;; let g:mapleader = ','
;; " Use <LocalLeader> in filetype plugin.
;; let g:maplocalleader = 'm'
;; 
;; set textwidth=80
;; set formatoptions=cqj
;; set tabstop=2
;; set shiftwidth=2
;; set softtabstop=2
;; set expandtab
;; set rnu
;; set nobackup
;; set nowritebackup
;; set noswapfile
;; set mouse=a
;; set list
;; set listchars=""                " Reset the listchars
;; set listchars=tab:\ \           " a tab should display as "  ", trailing whitespace as "."
;; set listchars+=trail:.          " show trailing spaces as dots
;; set listchars+=extends:>        " The character to show in the last column when wrap is
;;                                 " off and the line continues beyond the right of the screen
;; set listchars+=precedes:<       " The character to show in the last column when wrap is
;;                                 " off and the line continues beyond the right of the screen
;; set autoread                    " Automatically read
;; set cursorline                  " Highlight current line
;; set backspace=indent,eol,start  " Backspace for dummies
;; set linespace=0                 " No extra spaces between rows
;; set number                      " Line numbers on
;; set showmatch                   " Show matching brackets/parenthesis
;; set incsearch                   " Find as you type search
;; set hlsearch                    " Highlight search terms
;; set winminheight=0              " Windows can be 0 line high
;; set ignorecase                  " Case insensitive search
;; set smartcase                   " Case sensitive when uc present
;; set wildmenu                    " Show list instead of just completing
;; set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
;; set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
;; set scrolljump=5                " Lines to scroll when cursor leaves screen
;; set scrolloff=3                 " Minimum lines to keep above and below cursor
;; set nofoldenable                " Disable auto fold code
;; set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
;; set splitright                  " Puts new vsplit windows to the right of the current
;; set splitbelow                  " Puts new split windows to the bottom of the current
;; set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
;; set colorcolumn=+1              " Highlight 81st column
;; " Highlight when CursorMoved.
;; set cpoptions-=m
;; set matchtime=1
;; 
;; " FileType specific
;; 
;; "" {{{ Python
;; augroup ft_python
;;   au FileType python setlocal textwidth=120
;; augroup END
;; 
;; "" {{{ Clojure
;; augroup ft_clojure
;;   "" testing
;;   au FileType clojure setlocal lispwords+=describe,it,testing,facts,fact,provided
;;   "" jdbc
;;   au FileType clojure setlocal lispwords+=with-connection,with-query-results,with-naming-strategy,with-quoted-identifiers,update-or-insert-values,insert-record,delete-rows,insert!
;;   "" core.async
;;   au FileType clojure setlocal lispwords+=go-loop
;;   "" carmine (redis)
;;   au FileType clojure setlocal lispwords+=wcar
;;   "" ClojureScript
;;   au FileType clojure setlocal lispwords+=this-as
;; 
;; 	" Indent top-level form.
;; 	au FileType clojure nmap <buffer> <localleader>= mz99[(v%='z
;; 
;;   "" TODO: visual bindings
;;   au Filetype clojure nnoremap <localleader>ee :Eval<CR>
;;   au Filetype clojure nnoremap <localleader>ef :%Eval<CR>
;;   au Filetype clojure nnoremap <localleader>er :Require<CR>
;;   au Filetype clojure nnoremap <localleader>eR :Require!<CR>
;;   au Filetype clojure nnoremap <localleader>r :call fireplace#eval("(user/reset)")<CR>
;; 
;;   let g:clojure_syntax_keywords = {
;;       \ 'clojureMacro': ["defproject", "defcustom", "defstate"],
;;       \ 'clojureFunc': ["string/join", "string/replace"]
;;       \ }
;; 
;;   let g:clojure_align_subforms = 1
;;   let g:clojure_align_multiline_strings = 1
;; augroup END
;; 
;; augroup clojure_plumbatic
;;   au FileType clojure setlocal lispwords+=fnk,defnk,for-map,letk
;;   au FileType clojure setlocal lispwords+=go-loop
;;   au FileType clojure setlocal lispwords+=this-as
;; augroup END
;; 
;; autocmd BufNewFile,BufReadPost *.cljx setfiletype clojure
;; au BufRead,BufNewFile *.edn setfiletype clojure
;; au BufRead,BufNewFile *.cljc setfiletype clojure
;; 
;; "" Avro
;; au BufRead,BufNewFile *.avdl setlocal filetype=avro-idl
;; 
;; "" Groovy
;; autocmd Filetype groovy setlocal ts=4 sts=4 sw=4
;; 
;; "-------------------------------------------------------------------------------
;; " Abbreviations
;; "-------------------------------------------------------------------------------
;; iabbrev ldis ಠ_ಠ
;; iabbrev lsad ಥ_ಥ
;; iabbrev lhap ಥ‿ಥ
;; iabbrev lmis ಠ‿ಠ
;; 
;; "-------------------------------------------------------------------------------
;; " Mappings
;; "-------------------------------------------------------------------------------
;; "
;; 
;; " Easier moving in tabs and windows
;; map <C-J> <C-W>j
;; map <C-K> <C-W>k
;; map <C-L> <C-W>l
;; map <C-H> <C-W>h
;; map <S-L> gt
;; map <S-H> gT
;; 
;; " Wrapped lines goes down/up to next row, rather than next line in file.
;; noremap j gj
;; noremap k gk
;; 
;; " Disable Ex mode
;; map Q <Nop>
;; 
;; " Some helpers to edit mode
;; " http://vimcasts.org/e/14
;; cnoremap %% <C-R>=expand('%:h').'/'<cr>
;; map <leader>ew :e %%
;; map <leader>es :sp %%
;; map <leader>ev :vsp %%
;; map <leader>et :tabe %%
;; noremap <Leader>dt :tabnew<Enter><Leader>d
;; 
;; " Last tab binding
;; let g:lasttab = 1
;; nmap <c-w>; :exe "tabn ".g:lasttab<cr>
;; au TabLeave * let g:lasttab = tabpagenr()
;; 
;; " Safely alias :we to :w
;; cnoreabbrev <expr> we ((getcmdtype() is# ':' && getcmdline() is# 'w')?('we'):('w'))
;; 
;; " Don't move on *
;; nnoremap * *<c-o>
;; 
;; " Keep search matches in the middle of the window.
;; nnoremap n nzzzv
;; nnoremap N Nzzzv
;; 
;; " Tab close
;; nnoremap <Leader>C :tabc<CR>
;; 
;; " Yank from the cursor to the end of the line, to be consistent with C and D.
;; nnoremap Y y$
;; 
;; " Stupid shift key fixes
;; command! -bang -nargs=* -complete=file E e<bang> <args>
;; command! -bang -nargs=* -complete=file W w<bang> <args>
;; command! -bang -nargs=* -complete=file Wq wq<bang> <args>
;; command! -bang -nargs=* -complete=file WQ wq<bang> <args>
;; command! -bang Wa wa<bang>
;; command! -bang WA wa<bang>
;; command! -bang Q q<bang>
;; command! -bang QA qa<bang>
;; command! -bang Qa qa<bang>
;; cmap Tabe tabe
;; 
;; " Shortcuts to change working directory to that of the current file
;; cmap cwd lcd %:p:h
;; cmap cd. lcd %:p:h
;; 
;; " Visual shifting (does not exit Visual mode)
;; vnoremap < <gv
;; vnoremap > >gv
;; 
;; " Fix home and end keybindings for screen, particularly on mac
;; " - for some reason this fixes the arrow keys too. huh.
;; map [F $
;; imap [F $
;; map [H g0
;; imap [H g0
;; 
;; " leader - q closes all buffers in tab
;; map <leader>q :tabclose
;; 
;; "-------------------------------------------------------------------------------
;; " Plugin Settings
;; "-------------------------------------------------------------------------------
;; 
;; " Black (https://github.com/psf/black/blob/38385727/README.md)
;; " autocmd BufWritePre *.py execute ':Black'
;; " nnoremap <F9> :Black<CR>
;; 
;; " NERDTree
;; let NERDTreeMinimalUI = 1
;; let NERDTreeDirArrows = 1
;; let NERDTreeIgnore=[]
;; call add(NERDTreeIgnore, '^tmp/')
;; call add(NERDTreeIgnore, '^dist/')
;; call add(NERDTreeIgnore, '^target/')
;; call add(NERDTreeIgnore, '^node_modules')
;; call add(NERDTreeIgnore, '^__pycache__')
;; call add(NERDTreeIgnore, '^bower_components')
;; call add(NERDTreeIgnore, '^flow-typed')
;; call add(NERDTreeIgnore, '\.pyc')
;; call add(NERDTreeIgnore, '\~$')
;; call add(NERDTreeIgnore, '\.swo$')
;; call add(NERDTreeIgnore, '\.beam$')
;; call add(NERDTreeIgnore, '\.swp$')
;; call add(NERDTreeIgnore, '\.git$')
;; call add(NERDTreeIgnore, '\.hg')
;; call add(NERDTreeIgnore, '\.svn')
;; call add(NERDTreeIgnore, '\.bzr')
;; call add(NERDTreeIgnore, '\.so')
;; call add(NERDTreeIgnore, '\.o')
;; map <leader>t :NERDTreeFind<CR>
;; map <leader>T :NERDTreeClose<CR>
;; 
;; " delimitMate
;; let delimitMate_quotes = "\" \'"
;; let delimitMate_smart_quotes = 0
;; 
;; " kein/rainbow_parens.vim
;; au VimEnter * RainbowParenthesesToggle
;; au Syntax * RainbowParenthesesLoadRound
;; au Syntax * RainbowParenthesesLoadSquare
;; au Syntax * RainbowParenthesesLoadBraces
;; 
;; " airline
;; let g:airline_powerline_fonts = 1
;; let g:airline#extensions#tabline#enabled = 1
;; 
;; " CtrlP
;; let g:ctrlp_switch_buffer = 0
;; let g:ctrlp_working_path_mode = 'r'
;; let g:ctrlp_user_command = {
;;     \ 'types': {
;;       \ 1: ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others'],
;;       \ 2: ['.hg', 'hg --cwd %s locate -I .'],
;;       \ },
;;     \ 'fallback': 'find %s -type f'
;;   \ }
;;  let g:ctrlp_custom_ignore = {
;;        \ 'file': '\.exe$\|\.so$\|\.dll$\|\.pyc$',
;;        \ 'dir': '\.git$\|\.hg$\|\.svn$\|\.repl'
;;        \ }
;; 
;; " Ack
;; " nnoremap <leader>a :Ack!<space>
;; " let g:ackprg = 'ag --nogroup --nocolor --column'
;; 
;; " Tagbar
;; "" Move focus to tagbar when it opens to make it usable for windows on right side
;; let g:tagbar_autofocus = 1
;; 
;; " Tabularize
;; nmap <Leader>a- :Tabularize /=><CR>
;; vmap <Leader>a- :Tabularize /=><CR>
;; 
;; " vim-indent-guides
;; let g:indent_guides_enable_on_vim_startup = 0
;; 
;; " vim-gitgutter
;; let g:gitgutter_eager = 0
;; 
;; " vim-jsx
;; let g:jsx_ext_required = 0
;; 
;; "-------------------------------------------------------------------------------
;; " General Settings & Modifications
;; "-------------------------------------------------------------------------------
;; 
;; " Use clipboard register.
;; if has('unnamedplus')
;;   set clipboard& clipboard+=unnamedplus
;; else
;;   set clipboard& clipboard+=unnamed
;; endif
;; 
;; " Disable session dialog
;; let g:session_autosave='no'
;; 
;; " Tabline modifications
;; if has('gui')
;;   set guioptions-=e
;; endif
