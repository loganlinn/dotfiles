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

}
