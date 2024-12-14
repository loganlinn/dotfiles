{ pkgs, ... }:
{
  homebrew.taps = [ "hashicorp/tap" ];
  homebrew.brews = [
    "hashicorp/tap/terraform-ls"
  ];
  home-manager.users.logan = {
    home.packages = with pkgs; [
      tenv # provides terraform binary
      # terraform-ls
      tflint
      # terraformer
      terraform-docs
      # terraform-local # localstack
      # tfsec
      # tf-summarize
      # iam-policy-json-to-terraform # https://flosell.github.io/iam-policy-json-to-terraform/
    ];
  };
}
