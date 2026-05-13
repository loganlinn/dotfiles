{
  pkgs,
  lib,
  ...
}:
{
  home.shellAliases = {
  };

  programs.zsh.initContent = lib.mkAfter ''
    tfstate() {
      local pattern
      case $# in
        1) pattern="$1" ;;
        2) pattern="$1.$2" ;;
        *) echo >&2 "usage: tfstate <type.name> | <type> <name>  (wildcards ok)"; return 2 ;;
      esac
      local regex
      regex=$(printf '%s' "$pattern" | sed -e 's/[.[\(){}+^$|\\]/\\&/g' -e 's/\*/.*/g' -e 's/?/./g')
      terraform show -json |
        jq --arg re "^''${regex}$" '
          [ .values.root_module | .. | objects | select(.address? and (.address | test($re))) ]
        '
    }

    terraformw() {
      local ws="''${1:?usage: terraformw <workspace> [args...]}"
      shift
      local -a env=(TF_WORKSPACE="$ws")
      if [[ -f "''${ws}.tfvars" ]]; then
        local arg="-var-file=''${ws}.tfvars"
        env+=(
          TF_CLI_ARGS_plan="$arg"
          TF_CLI_ARGS_apply="$arg"
          TF_CLI_ARGS_console="$arg"
          TF_CLI_ARGS_import="$arg"
          TF_CLI_ARGS_refresh="$arg"
          TF_CLI_ARGS_test="$arg"
        )
      fi
      env "''${env[@]}" terraform "$@"
    }
  '';

  home.packages = with pkgs; [
    # terraform-docs
    # terraform-local # localstack
    # tfsec
    checkov
    iam-policy-json-to-terraform # https://flosell.github.io/iam-policy-json-to-terraform/
    tenv
    terraform-ls
    tf-summarize
    tfautomv
    tflint
  ];
}
