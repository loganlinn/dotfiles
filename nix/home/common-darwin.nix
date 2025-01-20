{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  config = mkIf pkgs.stdenv.isDarwin {

    my.shellScripts = {
      fd-app = {
        runtimeInputs = [ pkgs.fd ];
        text = ''
          exec fd --type directory --extension app --max-depth 2 --follow --search-path=/System/Applications --search-path=/Applications --search-path="$HOME/Applications" "$@"
        '';
      };

      app-id.text = ''/usr/bin/mdls -name kMDItemCFBundleIdentifier -r "''${1?}"'';

      # app-icon = {
      #   runtimeInputs = with pkgs; [
      #     gawk
      #     gum
      #   ];
      #   text = ''
      #     usage() {
      #       echo "usage: $0 [-o <$(list_formats | tr '\n' '|')>] <app>..."
      #     }
      #
      #     usage_error() {
      #       for msg; do echo "$msg" >&2; done
      #       usage >&2
      #       exit 1
      #     }
      #
      #     list_formats() {
      #       sips --formats | awk '/Writable$/ { if ($2 != "--") print $2 }'
      #     }
      #
      #     while true; do
      #       case $1 in
      #       -f|--format)
      #         [[ -n $2 ]] || usage_error "missing operand: $1"
      #         format=$2
      #         shift 2
      #         ;;
      #       -h|--help)
      #         usage
      #         exit 0
      #         ;;
      #       -*)
      #         usage_error "unrecognized option: $1"
      #         ;;
      #       --)
      #         shift
      #         break
      #         ;;
      #       *)
      #         break
      #         ;;
      #       esac
      #     done
      #
      #     [[ -n $format ]] || usage_error "missing format"
      #
      #     (( $# )) || usage_error "missing argument: app"
      #
      #     for app; do
      #       if [[ -d $app ]]; then
      #         app=$(cd "$app"; pwd)
      #       fi
      #       [[ -d $app ]] || usage_error "not a directory: $app"
      #       [[ -n $format ]] || usage_error "missing format"
      #
      #       echo "TODO resolve app path"
      #       echo 'TODO execute: sips -s format $format $app/Contents/Resources/AppIcon.icns --out $out'
      #     done
      #   '';
      # };
    };
  };
}
