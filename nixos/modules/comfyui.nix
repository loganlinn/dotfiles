{
  inputs,
  ...
}: {
  imports = [ inputs.comfyui-nix.nixosModules.default ];

  services.comfyui = {
    enable = true;
    port = 8188;
  };
}
