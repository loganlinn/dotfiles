  # an incomplete, just-for-fun, and non-idiomatic collection of nix functions
  # resembling clojure.core, i.e. my creature comforts.
  #
  # notes:
  # - apostrophe suffix generally denotes the func takes a list,
  #   whereas clojure version is variadic.
{ lib }:
{
  nil = null; # 🤡
  assoc = setAttr;
  constantly = constant;
  merge' = fold' mergeAttrs;
  merge-with' = foldl' mergeAttrsWithFunc;
  some = findFirst (x != nil) nil;
  comp' = fns: val: foldl' (x: f: f x) val (reverseList fns);
  first = xs: if xs == null || length xs == 0 then null else head xs;
  rest = xs: if xs == null || length xs == 1 then [ ] else tail xs;
  next = xs: if xs == null || length xs == 1 then null else tail xs;
  second = comp [ first rest seq ];
  when = cond: impl:
    if cond then impl else null; # as in, a one-legged conditional
  juxt = f: g: x: [ (f x) (g x) ];
  juxt' = fns: x: map (f: f x) fns;
  every-pred = preds: x: findFirst (pred: !pred x) false preds;
  seq = xs:
    if xs == nil then
      null
    else if isList xs then
      (if length x == 0 then null else xs)
    else if isAttrs xs then
      (mapAttrsToList (k: v: [ k v ]) xs)
    else if isString xs then
      stringToCharacters xs
    else
      throw "${typeOf xs} is not seqable";
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
