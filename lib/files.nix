{ lib }:

with lib;

rec {
  # Returns file paths
  find = path: pred:
    assert pathIsDirectory path; {
      path = path;
      matches = filter pred (filesystem.listFilesRecursive path);
    };

  pathIsExpr = path: (pathIsRegularFile path) && (hasSuffix ".nix");

  # i.e. is path something that nix can import?
  pathIsResolvable = path:
    pathIsExpr path
    || ((pathIsDirectory path) && (pathIsExpr "${path}/default.nix"));

  # TODO: may be able to use recursive option where this function is used
  #       i.e. https://github.com/nix-community/home-manager/tree/b23c7501f7e0a001486c9a5555a6c53ac7b08e85/modules/lib/file-type.nix
  sourceSet = { dir, base ? dir, prefix ? "", exclude ? (_: false) }:
    listToAttrs (forEach (remove exclude (filesystem.listFilesRecursive dir))
      (source: {
        name =
          "${prefix}${removePrefix ((toString base) + "/") (toString source)}";
        value = { inherit source; };
      }));

  #################################################################################################
  # https://github.com/numtide/nix-filter/blob/41fd48e00c22b4ced525af521ead8792402de0ea/default.nix
  #################################################################################################

  # Default to filter when calling this lib.
  __functor = self: filter;

  # A proper source filter
  filter =
    {
      # Base path to include
      root
    , # Derivation name
      name ? "source"
    , # Only include the following path matches.
      #
      # Allows all files by default.
      include ? [ (_:_:_: true) ]
    , # Ignore the following matches
      exclude ? [ ]
    }:
    assert _pathIsDirectory root;
    let
      callMatcher = args: _toMatcher ({ inherit root; } // args);
      include_ = map (callMatcher { matchParents = true; }) (toList include);
      exclude_ = map (callMatcher { matchParents = false; }) (toList exclude);
    in
      builtins.path {
        inherit name;
        path = root;
        filter = path: type:
          (builtins.any (f: f path type) include_) &&
          (!builtins.any (f: f path type) exclude_);
      };

  # Match a directory and any path inside of it
  inDirectory =
    directory:
    args:
    let
      # Convert `directory` to a path to clean user input.
      directory_ = _toCleanPath args.root directory;
    in
      path: type:
      directory_ == path
      # Add / to the end to make sure we match a full directory prefix
      || _hasPrefix (directory_ + "/") path;

  # Match any directory
  isDirectory = _: _: type: type == "directory";

  # Combines matchers
  and = a: b: args:
    let
      toMatcher = _toMatcher args;
    in
      path: type:
      (toMatcher a path type) && (toMatcher b path type);

  # Combines matchers
  or_ = a: b: args:
    let
      toMatcher = _toMatcher args;
    in
      path: type:
      (toMatcher a path type) || (toMatcher b path type);

  # Or is actually a keyword, but can also be used as a key in an attrset.
  or = or_;

  # Match paths with the given extension
  matchExt = ext:
    args: path: type:
    _hasSuffix ".${ext}" path;

  # Filter out files or folders with this exact name
  matchName = name:
    root: path: type:
    builtins.baseNameOf path == name;

  # Wrap a matcher with this to debug its results
  debugMatch = label: fn:
    args: path: type:
    let
      ret = fn args path type;
      retStr = if ret then "true" else "false";
    in
      builtins.trace "label=${label} path=${path} type=${type} ret=${retStr}"
        ret;

  # Add this at the end of the include or exclude, to trace all the unmatched paths
  traceUnmatched = args: path: type:
    builtins.trace "unmatched path=${path} type=${type}" false;

  # Lib stuff

  # If an argument to include or exclude is a path, transform it to a matcher.
  #
  # This probably needs more work, I don't think that it works on
  # sub-folders.
  _toMatcher = args: f:
    let
      path_ = _toCleanPath args.root f;
      pathIsDirectory = _pathIsDirectory path_;
    in
      if builtins.isFunction f then f args
      else path: type:
        (if pathIsDirectory then
          inDirectory path_ args path type
         else
           path_ == path) || args.matchParents
                             && type == "directory"
                             && _hasPrefix "${path}/" path_;


  # Makes sure a path is:
  # * absolute
  # * doesn't contain superfluous slashes or ..
  #
  # Returns a string so there is no risk of adding it to the store by mistake.
  _toCleanPath = absPath: path:
    assert _pathIsDirectory absPath;
    if builtins.isPath path then
      toString path
    else if builtins.isString path then
      if builtins.substring 0 1 path == "/" then
        path
      else
        toString (absPath + ("/" + path))
    else
      throw "unsupported type ${builtins.typeOf path}, expected string or path";

  _hasSuffix =
    # Suffix to check for
    suffix:
    # Input string
    content:
    let
      lenContent = builtins.stringLength content;
      lenSuffix = builtins.stringLength suffix;
    in
      lenContent >= lenSuffix
      && builtins.substring (lenContent - lenSuffix) lenContent content == suffix;

  _hasPrefix =
    # Prefix to check for
    prefix:
    # Input string
    content:
    let
      lenPrefix = builtins.stringLength prefix;
    in
      prefix == builtins.substring 0 lenPrefix content;

  # Returns true if the path exists and is a directory and false otherwise
  _pathIsDirectory = p:
    let
      parent = builtins.dirOf p;
      base = builtins.unsafeDiscardStringContext (builtins.baseNameOf p);
      inNixStore = builtins.storeDir == toString parent;
    in
      # If the parent folder is /nix/store, we assume p is a directory. Because
      # reading /nix/store is very slow, and not allowed in every environments.
      inNixStore ||
      (
        builtins.pathExists p &&
        (builtins.readDir parent).${builtins.unsafeDiscardStringContext base} == "directory"
      );
}
