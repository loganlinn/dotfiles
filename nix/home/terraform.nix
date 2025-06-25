{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # terraform-docs
    # terraform-local # localstack
    # tf-summarize
    # tfsec
    checkov
    iam-policy-json-to-terraform # https://flosell.github.io/iam-policy-json-to-terraform/
    tenv
    terraform-ls
    tfautomv
    tflint
  ];
}
