{ pkgs, ... }:
{
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
