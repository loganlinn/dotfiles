{
  inputs,
  lib,
  ...
}: {
  imports = [inputs.comfyui-nix.nixosModules.default];

  services.comfyui = {
    port = 8188;
    gpuSupport = lib.mkDefault "cuda";
    enableManager = true;
  };
}
