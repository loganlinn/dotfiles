{
  pkgs,
  lib,
}:
with lib; {
  # https://developer.apple.com/documentation/bundleresources/information_property_list
  plist = {}: {
    type = let
      valueType =
        nullOr
        (oneOf [
          bool
          int
          float
          str
          path
          (attrsOf valueType)
          (listOf valueType)
        ])
        // {
          description = "plist value";
        };
    in
      valueType;

    generate = name: data: {};
  };
}
