with builtins;

{ lib ? (getFlake (toString ../.)).inputs.nixpkgs.lib, ... }:

with lib;

{

  types = import ./types.nix { inherit lib; };

  float = import ./float.nix { inherit lib; };

  hex = import ./hex.nix { inherit lib; };

  color = import ./color.nix { inherit lib; };

  # an incomplete, non-idiomatic collection of clojure.core creature comforts
  # apostrophe suffix generally denotes function takes list, whereas clojure version is variadic.
  clj = rec {
    nil = null; # 🤡
    assoc = setAttr;
    merge' = fold' mergeAttrs;
    merge-with' = foldl' mergeAttrsWithFunc;
    some = findFirst (x != nil) nil;
    comp' = fns: val: foldl' (x: f: f x) val (reverseList fns);
    first = xs: if xs == null || length xs == 0 then null else head xs;
    rest = xs: if xs == null || length xs == 1 then [ ] else tail xs;
    next = xs: if xs == null || length xs == 1 then null else tail xs;
    second = comp [ first rest seq ];
    when = cond: impl: if cond then impl else null; # as in, a one-legged conditional
    juxt = f: g: x: [ (f x) (g x) ];
    juxt' = fns: x: map (f: f x) fns;
    every-pred = preds: x: findFirst (pred: ! pred x) false preds;
    seq = xs:
      if xs == nil then null
      else if isList xs then (if length x == 0 then null else xs)
      else if isAttrs xs then (mapAttrsToList (k: v: [ k v ]) xs)
      else if isString xs then stringToCharacters xs
      else throw "${typeOf xs} is not seqable";
    # conj = coll: x:
    #   if (isList coll) then coll ++ [x]
    #   else if isAttrs coll then (
    #     if isAttrs x then (
    #       warnIf ((hasAttr "name" x) && (hasAttr "value" x))
    #         "${x} looks like a key-value pair, but attrs are treated as associative"
    #         coll // x
    #     ) else isList x then (
    #       if length x == 2 then coll //
    #     )
    #   )
  };

  # Returns
  toExe = input:
    if isDerivation input
    then getExe input
    else if isAttrs input
    then getExe (input.finalPackage or input.package)
    else throw "Cannot coerce ${input} to main executable program path.";

  currentHostname =
    if pathExists "/etc/hostname"
    then pipe "/etc/hostname" [ readFile (match "^([^#].*)\n$") head ]
    else pipe "HOSTNAME" [ getEnv (warn "Unable to detect system hostname") ];

  files = {
    sourceSet =
      { dir
      , base ? dir
      , prefix ? ""
      , exclude ? (_: false)
      }:
      listToAttrs
        (forEach (remove exclude (filesystem.listFilesRecursive dir))
          (source: {
            name = "${prefix}${removePrefix ((toString base) + "/") (toString source)}";
            value = {
              inherit source;
            };
          }));
  };

  strings = {
    substitute = dict: replaceStrings (attrNames dict) (map toString (attrValues dict));
    ensurePrefix = prefix: content:
      if hasPrefix prefix content
      then content
      else "${content}${prefix}";
    ensureSuffix = suffix: content:
      if hasSuffix suffix content
      then content
      else "${content}${suffix}";
  };


  nerdfonts = import ./nerdfonts;

  font-awesome = import ./font-awesome.nix;

  rofi = import ./rofi.nix { inherit lib; };
}
