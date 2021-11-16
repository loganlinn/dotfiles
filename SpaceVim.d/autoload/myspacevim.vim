function! myspacevim#before() abort

  " https://github.com/hashivim/vim-terraform
  let g:terraform_align=1
  let g:terraform_fmt_on_save=1

  " https://github.com/SpaceVim/SpaceVim/issues/1714
  " Default to static completion for SQL
  let g:omni_sql_default_compl_type = 'syntax'

endfunction

function! myspacevim#after() abort
  " noop
endfunction

