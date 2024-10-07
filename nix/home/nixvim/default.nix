{ self, inputs, ... }:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ../../modules/programs/nixvim
  ];
}
