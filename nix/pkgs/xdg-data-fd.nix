{ writeShellApplication
, fd
, gnused
, ... }:

writeShellApplication {
  name = "xdg-data-fd";
  runtimeInputs = [ fd gnused ];
  text = ''
    fd_opts=()

    for d in $(tr ':' '\n' <<<"$XDG_DATA_HOME:$XDG_DATA_DIRS"); do
      if [[ -d $d ]]; then
         fd_opts+=(--search-path="$d")
      fi
    done

    fd "''${fd_opts[@]}" "$@"
  '';
}
