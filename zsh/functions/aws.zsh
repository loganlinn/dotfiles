if (( $+commands[aws] )); then
  alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli'
fi

function aws-env() {
  local profile="$1"
  if [[ -z "$profile" ]]; then
    profile="$(aws-okta list | fzf --tac | cut -f1)"
  fi
  eval "$(aws-okta env "$profile")"
}

function aws-login() {
  local profile="$1"
  if [[ -z "$profile" ]]; then
    profile="$(aws-okta list | fzf --tac | cut -f1)"
  fi
  eval "$(aws-okta login "$profile")"
}
