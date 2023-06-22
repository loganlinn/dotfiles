baseLib:

baseLib.extend (self: _: {
  my = import ./. { lib = self; };
})
