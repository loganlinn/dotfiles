{ pkgs, ... }:
{
  homebrew.taps = [ "hashicorp/tap" ];
  homebrew.brews = [
    "hashicorp/tap/terraform-ls"
  ];
  home-manager.users.logan = {
    home.packages = with pkgs; [
      tenv # provides terraform binary
      tflint
      terraformer
      # terraform-docs
      # tf-summarize
      # terraform-local # localstack
      # tfsec
      # iam-policy-json-to-terraform # https://flosell.github.io/iam-policy-json-to-terraform/
    ];
  };
}
