{ ... }:

{
  security = {
    pam.enableSudoTouchIdAuth = true;
    pki.certificates = [];
  };
}
