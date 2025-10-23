function zg_widget {
  local menu=$(
cat<<'EOF'
b -- branch
s -- status
t -- top
u -- up
p -- prefix
EOF
)
  local menu_pick="${${(s: :)$(echo "${menu}" | fzf --query=^ --bind one:accept)}[1]}"
  case $menu_pick in
    b)
      local git_branch_name="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
      LBUFFER+="${git_branch_name/HEAD/}"
      ;;
    s)
      local git_status_files="$(git -c 'color.status=always' status -su 2> /dev/null)"
      if [[ -n "${git_status_files}" ]]; then
        local git_status_selected_files=(${(f)"$(echo ${git_status_files} | fzf --multi --ansi)"})
        for (( i=1; i<=${#git_status_selected_files}; i++ )); do
          LBUFFER+="${${(s: :)${git_status_selected_files[${i}]}}[2]}"
          if [[ ${i} -lt ${#git_status_selected_files} ]]; then
            LBUFFER+=' '
          fi
        done
      fi
      ;;
    t) LBUFFER+="$(git rev-parse --show-toplevel 2>/dev/null)/" ;;
    u) LBUFFER+="$(git rev-parse --show-cdup 2>/dev/null)" ;;
    p) LBUFFER+="$(git rev-parse --show-prefix 2>/dev/null)" ;;
    w) LBUFFER+="$(git rev-parse --show-superproject0working-tree 2>/dev/null)" ;;
  esac
  zle reset-prompt
}

zle -N zg_widget
bindkey '^g' zg_widget

