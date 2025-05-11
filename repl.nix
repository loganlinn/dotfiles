{
  flakeRef ? (import ./lib { }).flakeRoot,
  ...
}@args:
(builtins.getFlake flakeRef).lib.mkReplAttrs args
