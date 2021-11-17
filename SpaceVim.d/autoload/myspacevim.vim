"
" myspacevim#before is called before SpaceVim core
"
function! myspacevim#before() abort

  " https://github.com/hashivim/vim-terraform
  let g:terraform_align=1
  let g:terraform_fmt_on_save=1

  " https://github.com/SpaceVim/SpaceVim/issues/1714
  " Default to static completion for SQL
  let g:omni_sql_default_compl_type = 'syntax'

" 	lua << EOF
"     local opt = requires('spacevim.opt')
"     opt.enable_projects_cache = false
"     opt.enable_statusline_mode = true
" EOF
endfunction

"
" myspacevim#after is called on autocmd `VimEnter`
"
function! myspacevim#after() abort
  " echo 'boostrap complete'
endfunction


function! Redir(cmd, rng, start, end)
	for win in range(1, winnr('$'))
		if getwinvar(win, 'scratch')
			execute win . 'windo close'
		endif
	endfor
	if a:cmd =~ '^!'
		let cmd = a:cmd =~' %'
			\ ? matchstr(substitute(a:cmd, ' %', ' ' . expand('%:p'), ''), '^!\zs.*')
			\ : matchstr(a:cmd, '^!\zs.*')
		if a:rng == 0
			let output = systemlist(cmd)
		else
			let joined_lines = join(getline(a:start, a:end), '\n')
			let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
			let output = systemlist(cmd . " <<< $" . cleaned_lines)
		endif
	else
		redir => output
		execute a:cmd
		redir END
		let output = split(output, "\n")
	endif
	vnew
	let w:scratch = 1
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, output)
endfunction

command! -nargs=1 -complete=command -bar -range Redir silent call Redir(<q-args>, <range>, <line1>, <line2>)

" function! s:cargo_task() abort
"     if filereadable('Cargo.toml')
"         let commands = ['build', 'run', 'test']
"         let conf = {}
"         for cmd in commands
"             call extend(conf, {
"                         \ cmd : {
"                         \ 'command': 'cargo',
"                         \ 'args' : [cmd],
"                         \ 'isDetected' : 1,
"                         \ 'detectedName' : 'cargo:'
"                         \ }
"                         \ })
"         endfor
"         return conf
"     else
"         return {}
"     endif
" endfunction

