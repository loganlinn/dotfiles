{
  lib,
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation rec {
  pname = "llama-swap";
  version = "211";

  src = fetchurl {
    url = "https://github.com/mostlygeek/llama-swap/releases/download/v${version}/llama-swap_${version}_linux_amd64.tar.gz";
    hash = "sha256-/2KqcCz2axJlRvpjwOvKbQ1rzkp4H1ys+DTi583bRGU=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 llama-swap $out/bin/llama-swap
    runHook postInstall
  '';

  meta = {
    description = "Hot-swapping proxy for multiple LLM inference servers";
    homepage = "https://github.com/mostlygeek/llama-swap";
    license = lib.licenses.mit;
    platforms = ["x86_64-linux"];
    mainProgram = "llama-swap";
  };
}
