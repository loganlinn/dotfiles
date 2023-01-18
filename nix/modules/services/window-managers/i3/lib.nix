{ lib, ... }:

with builtins;
with lib;

let
in
rec {
  concatKeysyms = concatStringsSep "+";

  keybindStr = keysyms: concatKeysyms (map toString (remove isNull (flatten keysyms)));

  sizeStr = { px, ppt ? null }: optionalString (!isNull px) (
    "${toString px} px" + (
      optionalString (!isNull ppt) "or ${toString ppt} ppt")
  );

  resizeKeybinds =
    { wider ? null
    , narrower ? null
    , taller ? null
    , shorter ? null
    , modifier ? null
    , size ? { px = 5; ppt = 1; }

    }: {
      "${keybindStr [modifier narrower]}" = "resize shrink width ${sizeStr size}";
      "${keybindStr [modifier taller]}" = "resize grow height ${sizeStr size}";
      "${keybindStr [modifier shorter]}" = "resize shrink height ${sizeStr size}";
      "${keybindStr [modifier wider]}" = "resize grow width ${sizeStr size}";
    };

  colorStr = { colorclass, border, background, text }: "${colorclass} ${border} ${background} ${text}";
}
