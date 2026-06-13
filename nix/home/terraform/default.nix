{
  pkgs,
  lib,
  ...
}: {
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
  '';

  home.packages = with pkgs; [
    # terraform-docs
    # terraform-local # localstack
    # tfsec
    iam-policy-json-to-terraform # https://flosell.github.io/iam-policy-json-to-terraform/
    tenv
    terraform-ls
    tf-summarize
    tfautomv
    tflint
  ];
}
