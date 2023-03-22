#!/usr/bin/env sh

# ~/.config/google-chrome/Default/Bookmarks
# ~/.config/google-chrome/Profile 1/Bookmarks
find_bookmarks_files() {
    find "${XDG_CONFIG_HOME-$HOME/.config}" -type f -name Bookmarks
}

parse_bookmark_file() {
    jq -r '
        def ancestors: while(. | length >= 2; del(.[-1,-2]));
        . as $in
        | paths(.url?) as $key
        | $in
        | getpath($key)
        |
        {
          name,
          url,
          path: [$key[0:-2] | ancestors as $a | $in | getpath($a) | .name?] | reverse
        }'
}
