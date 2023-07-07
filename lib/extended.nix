baseLib:

let mkMyLib = import ./.;
in baseLib.extend (self: _: {
  my = mkMyLib { lib = self; };
})
