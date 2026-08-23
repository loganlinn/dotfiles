{
  coreutils,
  lib,
  pandoc,
  stdenv,
  writeShellApplication,
  xdg-utils,
}:
writeShellApplication {
  name = "mdpreview";
  runtimeInputs =
    [
      coreutils
      pandoc
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [xdg-utils];
  text = lib.removePrefix "#!/usr/bin/env bash\n" (builtins.readFile ../../../bin/mdpreview);

  meta = {
    description = "Render Markdown to HTML with pandoc and open it in a browser";
    license = lib.licenses.mit;
    mainProgram = "mdpreview";
    platforms = lib.platforms.all;
  };
}
