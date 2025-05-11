{
  flakeref ? (import ./lib { }).flakeRoot,
  ...
}@args:
(builtins.getFlake flakeref).lib.mkReplAttrs args
