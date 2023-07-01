_bb() {
    # Substrate VM opts:
    #
    #   -Xmx<size>[g|G|m|M|k|K]  Set a maximum heap size (e.g. -Xmx256M to limit the heap to 256MB).
    #   -XX:PrintFlags=          Print all Substrate VM options.

    # Global opts
    _arguments \
        '-Xmx[size]' \
        '-cp[classpath]' \
        '--debug' \
        '--init[Load file after any preloads and prior to evaluation/subcommands]:source file:_path-files -g "*.clj"' \
        '--config[Replacing bb.edn with file. Relative paths are resolved relative to file]:config file:_path-files -g "*.edn"' \
        '--deps-root[Treat dir as root of relative paths in config]:dir:_path-files -/' \
        '--prn[Print result via clojure.core/prn]' \
        '-Sforce[Force recalculation of the classpath]' \
        '-Sdeps[Deps data to use as the last deps file to be merged]:edn' \
        '-i[Bind *input* to a lazy seq of lines from stdin]' \
        '-I[Bind *input* to a lazy seq of EDN values from stdin]' \
        '-o[Write lines to stdout]' \
        '-O[Write EDN values to stdout]' \
        '--stream[Stream over lines or EDN values from stdin]'

    # Help:
    #   help, -h or -?     Print this help text.
    #   version            Print the current version of babashka.
    #   describe           Print an EDN map with information about this version of babashka.
    #   doc <var|ns>       Print docstring of var or namespace. Requires namespace if necessary.
    #
    # Evaluation:
    #   -e, --eval <expr>    Evaluate an expression.
    #   -f, --file <path>    Evaluate a file.
    #   -m, --main <ns|var>  Call the -main function from a namespace or call a fully qualified var.
    #   -x, --exec <var>     Call the fully qualified var. Args are parsed by babashka CLI.

    # REPL:
    #   repl                 Start REPL. Use rlwrap for history.
    #   socket-repl  [addr]  Start a socket REPL. Address defaults to localhost:1666.
    #   nrepl-server [addr]  Start nREPL server. Address defaults to localhost:1667.

    # Tasks:
    local -a tasks
    tasks=( $(bb tasks | tail -n +3 | cut -f1 -d ' ') )
    compadd -a tasks

    # Clojure:
    #
    #   clojure [args...]  Invokes clojure. Takes same args as the official clojure CLI.

    # Packaging:
    #
    #   uberscript <file> [eval-opt]  Collect all required namespaces from the classpath into a single file. Accepts additional eval opts, like `-m`.
    #   uberjar    <jar>  [eval-opt]  Similar to uberscript but creates jar file.
    #   prepare                       Download deps & pods defined in bb.edn and cache their metadata. Only an optimization, this will happen on demand when needed.

    _files # autocomplete filenames as well
}
compdef _bb bb
