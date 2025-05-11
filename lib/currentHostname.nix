{
  pkgs ? import (import ../.).inputs.nixpkgs { },
  lib ? pkgs.lib,
}:
with builtins;
let
  when = c: x: if c then x else null;
  some =
    xs:
    let
      xs' = filter (x: x != null) xs;
    in
    when (xs' != [ ]) (head xs');
in
with lib;
some [
  # macOS stores hostname in plist, of course.
  (when pkgs.stdenv.isDarwin
    # poorman's xml extraction
    (
      pipe "/Library/Preferences/SystemConfiguration/preferences.plist" [
        readFile
        (split "<key>LocalHostName</key>")
        last
        trim
        (match "^<string>([^<]*)</string>.+")
        head
      ]
    )
  )
  (when (pathExists "/etc/hostname") (
    pipe "/etc/hostname" [
      readFile
      trim
      (match "([a-zA-Z0-9]+)")
      head
    ]
  ))
  (getEnv "HOST")
]
