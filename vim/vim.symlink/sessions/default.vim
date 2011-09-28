" ~/.vim/sessions/default.vim: Vim session script.
" Created by session.vim 1.4.16 on 19 September 2011 at 09:43:55.
" Open this file in Vim and run :source % to restore your session.

set guioptions=egmrLt
silent! set guifont=
if exists('g:syntax_on') != 1 | syntax on | endif
if exists('g:did_load_filetypes') != 1 | filetype on | endif
if exists('g:did_load_ftplugin') != 1 | filetype plugin on | endif
if exists('g:did_indent_on') != 1 | filetype indent on | endif
if &background != 'dark'
	set background=dark
endif
if !exists('g:colors_name') || g:colors_name != 'no_quarter' | colorscheme no_quarter | endif
call setqflist([])
let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Sites/huddler
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +36 config/config.overrides.php
badd +50 config/config.db.php
badd +0 common/defines.php
args .
set lines=117 columns=241
edit config/config.db.php
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd _ | wincmd |
split
1wincmd k
wincmd w
wincmd w
set nosplitbelow
set nosplitright
wincmd t
set winheight=1 winwidth=1
exe '1resize ' . ((&lines * 57 + 58) / 117)
exe 'vert 1resize ' . ((&columns * 80 + 120) / 241)
exe '2resize ' . ((&lines * 57 + 58) / 117)
exe 'vert 2resize ' . ((&columns * 80 + 120) / 241)
exe 'vert 3resize ' . ((&columns * 160 + 120) / 241)
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 57 - ((56 * winheight(0) + 28) / 57)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
57
normal! 06l
wincmd w
argglobal
edit config/config.overrides.php
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 32 - ((13 * winheight(0) + 28) / 57)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
32
normal! 043l
wincmd w
argglobal
edit common/defines.php
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let s:l = 114 - ((53 * winheight(0) + 57) / 115)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
114
normal! 015l
wincmd w
2wincmd w
exe '1resize ' . ((&lines * 57 + 58) / 117)
exe 'vert 1resize ' . ((&columns * 80 + 120) / 241)
exe '2resize ' . ((&lines * 57 + 58) / 117)
exe 'vert 2resize ' . ((&columns * 80 + 120) / 241)
exe 'vert 3resize ' . ((&columns * 160 + 120) / 241)
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
tabnext 1
2wincmd w

" vim: ft=vim ro nowrap smc=128
