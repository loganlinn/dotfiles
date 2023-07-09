{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, coreutils
, bash
, gawk
, libnotify
, networkmanager
, networkmanagerapplet
, qrencode
, rofi-unwrapped
}:

stdenv.mkDerivation rec {
  pname = "rofi-network-manager";
  version = "unstable-2023-06-25";

  src = fetchFromGitHub {
    owner = "P3rf";
    repo = "rofi-network-manager";
    rev = "19a3780fa3ed072482ac64a4e73167d94b70446b";
    hash = "sha256-sK4q+i6wfg9k/Zjszy4Jf0Yy7dwaDebTV39Fcd3/cQ0=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontBuild = true;

  installPhase = ''
    install -D --target-directory=$out/share/rofi \
      ./rofi-network-manager.sh \
      ./rofi-network-manager.rasi \
      ./rofi-network-manager.conf

    mkdir -p $out/bin

    ln -s -T $out/share/rofi/rofi-network-manager.sh $out/bin/${pname}
  '';

  fixupPhase = ''
    patchShebangs "$out/share/rofi"

    wrapProgram "$out/share/rofi/rofi-network-manager.sh" \
      --set-default NOTIFICATIONS true \
      --prefix PATH : "${lib.makeBinPath [
        coreutils
        gawk
        rofi-unwrapped
        qrencode
        networkmanager
        networkmanagerapplet
        libnotify
      ]}"
  '';

  meta = with lib; {
    description = "A manager for network connections using bash, rofi, nmcli, qrencode";
    homepage = "https://github.com/P3rf/rofi-network-manager.git";
    license = licenses.mit;
    mainProgram = "rofi-network-manager";
  };

}
