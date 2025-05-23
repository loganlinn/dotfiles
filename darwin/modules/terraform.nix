{ lib, ... }:
{
  homebrew.taps = [ "hashicorp/tap" ];
  homebrew.brews = [
    "hashicorp/tap/terraform-ls"
  ];
  home-manager.sharedModules = lib.singleton (
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # terraform-docs
        # terraform-local # localstack
        # tf-summarize
        # tfsec
        iam-policy-json-to-terraform # https://flosell.github.io/iam-policy-json-to-terraform/
        tenv # provides terraform binary
        terraformer
        tflint
      ];
    }
  );
}
