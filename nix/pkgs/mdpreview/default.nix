{
  lib,
  pandoc,
  python3,
  ripgrep,
  stdenv,
  writeShellApplication,
  xdg-utils,
}:
writeShellApplication {
  name = "mdpreview";
  runtimeInputs =
    [
      pandoc
      ripgrep
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [xdg-utils];
  text = ''
    exec ${lib.getExe python3} ${../../../lib/mdpreview}/cli.py "$@"
  '';

  meta = {
    description = "Preview Markdown files and directories in a browser";
    license = lib.licenses.mit;
    mainProgram = "mdpreview";
    platforms = lib.platforms.unix;
  };
}
