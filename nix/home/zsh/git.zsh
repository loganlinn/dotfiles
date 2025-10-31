() {
  $1 () {
    setopt localoptions pipefail no_aliases 2> /dev/null
    local menu_pick="$(fzf --bind one:accept --accept-nth=1 <<'EOF'
  b -- branch
  o -- open...
  p -- prefix
  s -- status
  t -- top
  u -- up
EOF
)"
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
      w) LBUFFER+="$(git rev-parse --show-superproject-working-tree 2>/dev/null)" ;;
      o)
      local submenu_pick="$(fzf --bind one:accept --accept-nth=1 <<'EOF'
    b -- branch
    o -- open...
    p -- prefix
    s -- status
    t -- top
    u -- up
EOF
)"
      case $submenu_pick in
        o) gh browse --branch="$(git rev-parse --abbrev-ref HEAD)" . ;;
        p) gh pr view --web ;;
      esac
      echo
      ;;
      *)
        zle redisplay
    esac

    zle reset-prompt
  }

  zle -N $1
  bindkey "$2" "$1"

} git-widget "^X^g"
