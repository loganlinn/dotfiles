{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    grpcurl
    protobuf
    buf
  ];
}
