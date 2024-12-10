{ lib }:
{
  mkKeymap = mode: key: options: action: {
    mode = if lib.isString mode then lib.stringToCharacters mode else mode;
    key = key;
    action = action; # TODO can check if __raw, then wrap implicit `function() ... end` to cut down on noise
    options =
      if lib.isString options then
        {
          desc = options;
          # silent = true;
          # noremap = true;
        }
      else
        options;
  };
}
