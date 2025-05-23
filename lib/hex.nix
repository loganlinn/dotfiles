{lib, ...}:
with lib; let
  # Generate an attribute set by mapping a function of a list of attribute values.
  genTable = values: f: listToAttrs (map (v: nameValuePair (toString (f v)) v) values);

  # hex character => decimal value
  toIntTable = genTable (range 0 15) toHexString;
in {
  # Convert an hexadecimal string to an integer
  toInt = s:
    pipe s [
      (removePrefix "0x")
      stringToCharacters
      (map (c: toIntTable.${toUpper c}))
      (foldl (acc: n: acc * 16 + n) 0)
    ];

  # Convert an integer to a hex string
  fromInt = toHexString;

  # Convert an integer to hex string with padding
  fromIntWithPadding = n: i: let
    s = toHexString i;
    pad = n - (stringLength s);
  in
    if n > 0
    then "${concatStrings (replicate (n - 1) "0")}${s}"
    else s;
}
