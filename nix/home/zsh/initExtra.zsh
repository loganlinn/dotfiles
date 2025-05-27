
unsetopt EXTENDED_GLOB      # Don't use extended globbing syntax.
setopt IGNOREEOF            # Do not exit on end-of-file <C-d>
setopt EQUALS               # Expansion of =command expands into full pathname of command
setopt LONG_LIST_JOBS       # List jobs in the long format by default.
setopt AUTO_RESUME          # Attempt to resume existing job before creating a new process.
setopt NOTIFY               # Report status of background jobs immediately.
unsetopt BG_NICE            # Don't run all background jobs at a lower priority.
unsetopt HUP                # Don't kill jobs on shell exit.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

DIRSTACKSIZE=9

[[ ! -v XDG_DATA_HOME ]] ||
  fpath+=("$XDG_DATA_HOME/zsh/functions")

[[ ! -v DOTFILES_DIR ]] ||
  fpath+=("$DOTFILES_DIR/nix/home/zsh/functions")

bindkey -s '^G,' ' $(git rev-parse --show-cdup)\t'
bindkey -s '^G.' ' "$(git rev-parse --show-prefix)"\t'
bindkey -s '^G~' ' "$(git rev-parse --show-toplevel)"\t'
bindkey -s '^G^G' ' git status^M' # ctrl-space (^M is accept line)
bindkey -s '^G^S' ' git snapshot^M'
bindkey -s '^G^_' ' "$(git rev-parse --show-toplevel)"\t' # i.e. C-g C-/
bindkey -s '^G^c' ' gh pr checks^M'
bindkey -s '^G^f' ' git fetch^M'
bindkey -s '^G^g' ' git status^M'
bindkey -s '^G^s' ' git snapshot^M'

if (( ${+commands[bat] })); then
  alias d='batdiff'
  alias g='batgrep'
  eval "$(batman --export-env)"
  eval "$(batpipe)"
fi

(( ! ${+functions[wezterm::init]} )) || wezterm::init

[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
