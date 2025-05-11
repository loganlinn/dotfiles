with builtins;
let
  extractFlakeAttr =
    arg:
    let
      xs = split "#" arg;
    in
    if length xs >= 3 then elemAt xs 2 else null;
in
{
  # i.e. --argstr name $(scutil --get LocalHostName)
  name ? (extractFlakeAttr (getEnv "NIX_DARWIN_FLAKE")),
  flakeref ? (if (getEnv "FLAKE_ROOT") != "" then (getEnv "FLAKE_ROOT") else toString ./..),
}:
let
  flake = getFlake flakeref;
  cfg = flake.darwinConfigurations.${name};
in
flake // cfg
