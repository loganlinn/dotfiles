{writeShellApplication}:
writeShellApplication {
  name = "i3-shmlog";
  text = ''
    usage() {
      echo "Usage: $(basename "$0") [-h | --help] <command> [<args>]"
      echo
      echo "COMMANDS"
      echo "    on     Turns on the i3 SHM log."
      echo "    off    Turns off the i3 SHM log."
      echo "    dump   Turns on, dumps, and turns off the i3 SHM log. See: i3-dump-log(1)."
      echo
    }

    action=dump

    while (($#)); do
      case $1 in
      -h | --help)
        usage
        exit 0
        ;;
      -*)
        echo "$(basename "$0"): unknown option: $1" >&2
        exit 1
        ;;
      *)
        action=$1
        shift
        ;;
      esac
    done

    case "$action" in
    on | enable)
      i3-msg -q shmlog on
      ;;

    off | disable)
      i3-msg -q shmlog off
      ;;

    dump)
      i3-msg -q shmlog on
      trap 'i3-msg -q shmlog off' EXIT
      i3-dump-log "$@"
      ;;

    *)
      echo "$(basename "$0"): unknown command: $1" >&2
      exit 1
      ;;
    esac
  '';
}
