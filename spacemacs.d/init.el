;; -*- mode: emacs-lisp; lexical-binding: t -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

(defun dotspacemacs/layers ()
  "Layer configuration:
This function should only modify configuration layer settings."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs

   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused

   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t

   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()

   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(javascript

     (auto-completion :disabled-for org markdown
                      :variables
                      auto-completion-enable-help-tooltip t
                      auto-completion-enable-snippets-in-popup t
                      auto-completion-enable-sort-by-usage t
                      auto-completion-idle-delay 0.0
                      auto-completion-complete-with-key-sequence "fd")

     ;; To have auto-completion on as soon as you start typing
     ;; (auto-completion :variables auto-completion-idle-delay nil)

     better-defaults

     (clojure :variables
              ;; clojure-backend 'cider               ;; use cider and disable lsp
              ;; clojure-enable-linters 'clj-kondo    ;; clj-kondo included in lsp
              cider-overlays-use-font-lock t
              cider-pprint-fn 'fipp                   ;; fast pretty printing
              cider-repl-buffer-size-limit 100        ;; limit lines shown in REPL buffer
              cider-repl-display-help-banner nil      ;; disable help banner
              cider-result-overlay-position 'at-point ;; results shown right after expression
              clojure-align-forms-automatically t
              clojure-indent-style 'align-arguments
              clojure-toplevel-inside-comment-form t  ;; evaluate expressions in comment as top level
              enable-fancify-symbols t
              clojure-enable-clj-refactor t
              cider-repl-buffer-size-limit 100        ;; limit lines shown in REPL buffer
              )

     ;; Nyan cat indicating relative position in current buffer
     ;; :variables colors-enable-nyan-cat-progress-bar (display-graphic-p)
     colors

     ;; SPC a L displays key and command history in a separate buffer
     command-log

     csv

     elm

     emacs-lisp

     emoji

     ;; helm-follow-mode sticky - remembers use of C-c C-f
     ;; - follow mode previews when scrolling through a helm list
     (helm :variables
           helm-follow-mode-persistent t)

     html

     ;; SPC g s opens Magit git client full screen (q restores previous layout)
     ;; show word-granularity differences in current diff hunk
     (git :variables
          git-magit-status-fullscreen t
          magit-diff-refine-hunk t
          git-enable-magit-todos-plugin t)

     ;; SPC g h to use GitHub repositories
     ;; SPC g g to use GitHub Gists
     github

     ;; graphviz - open-source graph declaration system
     ;; Used to generated graphs of Clojure project dependencies
     ;; https://develop.spacemacs.org/layers/+lang/graphviz/README.html
     graphviz

     go

     java

     json

     ;; Language server protocol with minimal visual impact
     ;; https://practicalli.github.io/spacemacs/install-spacemacs/clojure-lsp/lsp-variables-reference.html
     (lsp :variables
          ;; Formatting and indentation - use Cider instead
          lsp-enable-on-type-formatting t
          ;; Set to nil to use CIDER features instead of LSP UI
          lsp-enable-indentation t
          lsp-enable-snippet t  ;; to test again

          ;; symbol highlighting - `lsp-toggle-symbol-highlight` toggles highlighting
          ;; subtle highlighting for doom-gruvbox-light theme defined in dotspacemacs/user-config
          lsp-enable-symbol-highlighting t

          ;; Show lint error indicator in the mode line
          lsp-modeline-diagnostics-enable t
          ;; lsp-modeline-diagnostics-scope :workspace

          ;; popup documentation boxes
          ;; lsp-ui-doc-enable nil          ;; disable all doc popups
          lsp-ui-doc-show-with-cursor nil   ;; doc popup for cursor
          ;; lsp-ui-doc-show-with-mouse t   ;; doc popup for mouse
          ;; lsp-ui-doc-delay 2                ;; delay in seconds for popup to display
          lsp-ui-doc-include-signature t    ;; include function signature
          ;; lsp-ui-doc-position 'at-point  ;; top bottom at-point
          lsp-ui-doc-alignment 'window      ;; frame window

          ;; code actions and diagnostics text as right-hand side of buffer
          lsp-ui-sideline-code-actions-prefix " "
          lsp-ui-sideline-enable nil
          lsp-ui-sideline-show-code-actions nil
          ;; lsp-ui-sideline-delay 500
          ;; lsp-ui-sideline-show-hover nil
          ;; lsp-ui-sideline-show-diagnostics nil

          ;; reference count for functions (assume their maybe other lenses in future)
          lsp-lens-enable t

          ;; Efficient use of space in treemacs-lsp display
          treemacs-space-between-root-nodes nil

          ;; Optimization for large files
          lsp-file-watch-threshold 10000
          lsp-log-io nil

          lsp-rust-server 'rust-analyzer
          lsp-rust-analyzer-server-display-inlay-hints t
          )

     (markdown :variables
               markdown-live-preview-engine 'vmd)

     ;; Editing multiple lines of text concurrently
     ;; `g r' menu in Emacs normal state
     multiple-cursors

     ;; Spacemacs Org mode
     (org :variables
          org-enable-github-support t
          org-enable-bootstrap-support t
          org-enable-reveal-js-support t
          org-enable-hugo-support t
          org-enable-valign t
          org-want-todo-bindings t
          org-enable-org-journal-support t
          org-journal-dir "~/journal/"
          org-journal-file-format "%Y-%m-%d"
          org-journal-date-prefix "#+TITLE: "
          org-journal-date-format "%A, %B %d %Y"
          org-journal-time-prefix "* "
          org-journal-time-format ""
          org-journal-carryover-items "TODO=\"TODO\"|TODO=\"DOING\"|TODO=\"BLOCKED\"|TODO=\"REVIEW\""
          org-projectile-file "notes.org")

     (plantuml :variables
               plantuml-jar-path "~/.local/share/plantuml/plantuml.jar"
               org-plantuml-jar-path "~/.local/share/plantuml/plantuml.jar")

     protobuf

     ;; ruby

     (rust :variables
           rust-format-on-save t)

     (shell :variables
            shell-default-shell 'eshell
            shell-default-height 30
            shell-default-position 'bottom)

     sql
     ;; spacemacs-layouts layer added to set variables
     ;; SPC TAB restricted to current layout buffers
     ;; Kill buffers when killing layer - SPC l x
     (spacemacs-layouts :variables
                        spacemacs-layouts-restrict-spc-tab t
                        persp-autokill-buffer-on-remove 'kill-weak)

     ;; Configuration: https://github.com/seagle0128/doom-modeline#customize
     (spacemacs-modeline :variables
                         doom-modeline-height 12
                         doom-modeline-major-mode-color-icon t
                         doom-modeline-buffer-file-name-style 'relative-to-project
                         doom-modeline-display-default-persp-name t
                         doom-modeline-minor-modes nil
                         doom-modeline-modal-icon nil)

     ;; Spell as you type with Flyspell package,
     ;; requires external command - ispell, hunspell, aspell
     ;; SPC S menu, SPC S s to check current word
     spell-checking

     ;; Use original flycheck fringe bitmaps
     (syntax-checking :variables
                      syntax-checking-use-original-bitmaps t)

     ;; Visual file manager - `SPC p t'
     ;; treemacs-no-png-images t removes file and directory icons
     (treemacs :variables
               treemacs-indentation 1
               treemacs-use-filewatch-mode t
               treemacs-use-follow-mode t
               ;; treemacs-use-git-mode 'deferred
               )

     ;; Customise the Spacemacs themes
     ;; https://develop.spacemacs.org/layers/+themes/theming/README.html
     ;; Code in dotspacemacs/user-init to reduce size of modeline
     theming

     ;; Support font ligatures (fancy symbols) in all modes
     ;; 'prog-mode for only programming languages
     ;; including text-mode may cause issues with org-mode and magit
     (unicode-fonts :variables
                    unicode-fonts-enable-ligatures t
                    unicode-fonts-ligature-modes '(prog-mode))

     ;; Highlight changes in buffers
     ;; SPC g . transient state for navigating changes
     (version-control :variables
                      version-control-diff-tool 'diff-hl
                      version-control-global-margin t)

     yaml

     ) ;; End of dotspacemacs-configuration-layers

   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   dotspacemacs-additional-packages '(editorconfig
                                      jq-mode
                                      nord-theme
                                      org-cliplink
                                      ox-clip
                                      protobuf-mode
                                      shfmt
                                      keycast
                                      )
   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()

   ;; A list of packages that will not be installed and loaded.
   dotspacemacs-excluded-packages '()

   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and deletes any unused
   ;; packages as well as their unused dependencies. `used-but-keep-unused'
   ;; installs only the used packages but won't delete unused ones. `all'
   ;; installs *all* packages supported by Spacemacs and never uninstalls them.
   ;; (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization:
This function is called at the very beginning of Spacemacs startup,
before layer configuration.
It should only modify the values of Spacemacs settings."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non-nil then enable support for the portable dumper. You'll need
   ;; to compile Emacs 27 from source following the instructions in file
   ;; EXPERIMENTAL.org at to root of the git repository.
   ;; (default nil)
   dotspacemacs-enable-emacs-pdumper nil

   ;; Name of executable file pointing to emacs 27+. This executable must be
   ;; in your PATH.
   ;; (default "emacs")
   dotspacemacs-emacs-pdumper-executable-file "emacs"

   ;; Name of the Spacemacs dump file. This is the file will be created by the
   ;; portable dumper in the cache directory under dumps sub-directory.
   ;; To load it when starting Emacs add the parameter `--dump-file'
   ;; when invoking Emacs 27.1 executable on the command line, for instance:
   ;;   ./emacs --dump-file=$HOME/.emacs.d/.cache/dumps/spacemacs-27.1.pdmp
   ;; (default (format "spacemacs-%s.pdmp" emacs-version))
   dotspacemacs-emacs-dumper-dump-file (format "spacemacs-%s.pdmp" emacs-version)

   ;; If non-nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t

   ;; Maximum allowed time in seconds to contact an ELPA repository.
   ;; (default 5)
   dotspacemacs-elpa-timeout 5

   ;; Set `gc-cons-threshold' and `gc-cons-percentage' when startup finishes.
   ;; This is an advanced option and should not be changed unless you suspect
   ;; performance issues due to garbage collection operations.
   ;; (default '(100000000 0.1))
   dotspacemacs-gc-cons '(100000000 0.1)

   ;; Set `read-process-output-max' when startup finishes.
   ;; This defines how much data is read from a foreign process.
   ;; Setting this >= 1 MB should increase performance for lsp servers
   ;; in emacs 27.
   ;; (default (* 1024 1024))
   dotspacemacs-read-process-output-max (* 1024 1024)

   ;; If non-nil then Spacelpa repository is the primary source to install
   ;; a locked version of packages. If nil then Spacemacs will install the
   ;; latest version of packages from MELPA. Spacelpa is currently in
   ;; experimental state please use only for testing purposes.
   ;; (default nil)
   dotspacemacs-use-spacelpa nil

   ;; If non-nil then verify the signature for downloaded Spacelpa archives.
   ;; (default t)
   dotspacemacs-verify-spacelpa-archives t

   ;; If non-nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil

   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'. (default 'emacs-version)
   dotspacemacs-elpa-subdirectory 'emacs-version

   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim

   ;; If non-nil show the version string in the Spacemacs buffer. It will
   ;; appear as (spacemacs version)@(emacs version)
   ;; (default t)
   dotspacemacs-startup-buffer-show-version t

   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'random
   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `recents-by-project' `bookmarks' `projects' `agenda' `todos'.
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   ;; The exceptional case is `recents-by-project', where list-type must be a
   ;; pair of numbers, e.g. `(recents-by-project . (7 .  5))', where the first
   ;; number is the project limit and the second the limit on the recent files
   ;; within a project.
   dotspacemacs-startup-lists '((projects . 7)
                                (todos . 5)
                                (bookmarks . 10)
                                (recents . 5))

   ;; True if the home buffer should respond to resize events. (default t)
   dotspacemacs-startup-buffer-responsive t

   ;; Show numbers before the startup list lines. (default t)
   dotspacemacs-show-startup-list-numbers t

   ;; The minimum delay in seconds between number key presses. (default 0.4)
   dotspacemacs-startup-buffer-multi-digit-delay 0.4

   ;; Default major mode for a new empty buffer. Possible values are mode
   ;; names such as `text-mode'; and `nil' to use Fundamental mode.
   ;; (default `text-mode')
   dotspacemacs-new-empty-buffer-major-mode 'org-mode

   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'org-mode

   ;; If non-nil, *scratch* buffer will be persistent. Things you write down in
   ;; *scratch* buffer will be saved and restored automatically.
   dotspacemacs-scratch-buffer-persistent t

   ;; If non-nil, `kill-buffer' on *scratch* buffer
   ;; will bury it instead of killing.
   dotspacemacs-scratch-buffer-unkillable t

   ;; Initial message in the scratch buffer, such as "Welcome to Spacemacs!"
   ;; (default nil)
   dotspacemacs-initial-scratch-message nil

   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press `SPC T n' to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(nord
                         doom-gruvbox-light
                         spacemacs-dark
                         spacemacs-light)

   ;; Set the theme for the Spaceline. Supported themes are `spacemacs',
   ;; `all-the-icons', `custom', `doom', `vim-powerline' and `vanilla'. The
   ;; first three are spaceline themes. `doom' is the doom-emacs mode-line.
   ;; `vanilla' is default Emacs mode-line. `custom' is a user defined themes,
   ;; refer to the DOCUMENTATION.org for more info on how to create your own
   ;; spaceline theme. Value can be a symbol or list with additional properties.
   ;; (default '(spacemacs :separator wave :separator-scale 1.5))
   ;;dotspacemacs-mode-line-theme '(spacemacs :separator wave :separator-scale 1.5)
   dotspacemacs-mode-line-theme '(doom)

   ;; If non-nil the cursor color matches the state color in GUI Emacs.
   ;; (default t)
   dotspacemacs-colorize-cursor-according-to-state t
   ;; Default font, or prioritized list of fonts. `powerline-scale' allows to
   ;; quickly tweak the mode-line size to make separators look not too crappy.
   ;;dotspacemacs-default-font '("SauceCodePro Nerd Font"
   ;;                            :size 13
   ;;                            :weight normal
   ;;                            :width normal
   ;;                            :powerline-scale 1.1)
   dotspacemacs-default-font '("Fira Code"
                               :size 12.0
                               :weight normal
                               :width normal)

   ;; The leader key
   dotspacemacs-leader-key "SPC"

   ;; The key used for Emacs commands `M-x' (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"

   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"

   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"

   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","

   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m" for terminal mode, "<M-return>" for GUI mode).
   ;; Thus M-RET should work as leader key in both GUI and terminal modes.
   ;; C-M-m also should work in terminal mode, but not in GUI mode.
   dotspacemacs-major-mode-emacs-leader-key (if window-system "<M-return>" "C-M-m")

   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs `C-i', `TAB' and `C-m', `RET'.
   ;; Setting it to a non-nil value, allows for separate commands under `C-i'
   ;; and TAB or `C-m' and `RET'.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil

   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Global"

   ;; If non-nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout t

   ;; If non-nil then the last auto saved layouts are resumed automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts t

   ;; If non-nil, auto-generate layout name when creating new layouts. Only has
   ;; effect when using the "jump to layout by number" commands. (default nil)
   dotspacemacs-auto-generate-layout-names nil

   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1

   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache

   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5

   ;; If non-nil, the paste transient-state is enabled. While enabled, after you
   ;; paste something, pressing `C-j' and `C-k' several times cycles through the
   ;; elements in the `kill-ring'. (default nil)
   dotspacemacs-enable-paste-transient-state t

   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4

   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom

   ;; Control where `switch-to-buffer' displays the buffer. If nil,
   ;; `switch-to-buffer' displays the buffer in the current window even if
   ;; another same-purpose window is available. If non-nil, `switch-to-buffer'
   ;; displays the buffer in a same-purpose window even if the buffer can be
   ;; displayed in the current window. (default nil)
   dotspacemacs-switch-to-buffer-prefers-purpose nil

   ;; If non-nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t

   ;; If non-nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup nil

   ;; If non-nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil

   ;; If non-nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil

   ;; If non-nil the frame is undecorated when Emacs starts up. Combine this
   ;; variable with `dotspacemacs-maximized-at-startup' in OSX to obtain
   ;; borderless fullscreen. (default nil)
   dotspacemacs-undecorated-at-startup nil

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 100

   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90

   ;; If non-nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t

   ;; If non-nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t

   ;; If non-nil unicode symbols are displayed in the mode line.
   ;; If you use Emacs as a daemon and wants unicode characters only in GUI set
   ;; the value to quoted `display-graphic-p'. (default t)
   dotspacemacs-mode-line-unicode-symbols t

   ;; If non-nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t

   ;; Show the scroll bar while scrolling. The auto hide time can be configured
   ;; by setting this variable to a number. (default t)
   dotspacemacs-scroll-bar-while-scrolling t

   ;; Control line numbers activation.
   ;; If set to `t', `relative' or `visual' then line numbers are enabled in all
   ;; `prog-mode' and `text-mode' derivatives. If set to `relative', line
   ;; numbers are relative. If set to `visual', line numbers are also relative,
   ;; but only visual lines are counted. For example, folded lines will not be
   ;; counted and wrapped lines are counted as multiple lines.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :visual nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; When used in a plist, `visual' takes precedence over `relative'.
   ;; (default nil)
   dotspacemacs-line-numbers '(:visual t :disabled-for-modes dired-mode doc-view-mode pdf-view-mode :size-limit-kb 1000)

   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'vimish

   ;; If non-nil and `dotspacemacs-activate-smartparens-mode' is also non-nil,
   ;; `smartparens-strict-mode' will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode t

   ;; If non-nil smartparens-mode will be enabled in programming modes.
   ;; (default t)
   dotspacemacs-activate-smartparens-mode t

   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc...
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis t

   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all

   ;; If non-nil, start an Emacs server if one is not already running.
   ;; (default nil)
   dotspacemacs-enable-server t

   ;; Set the emacs server socket location.
   ;; If nil, uses whatever the Emacs default is, otherwise a directory path
   ;; like \"~/.emacs.d/server\". It has no effect if
   ;; `dotspacemacs-enable-server' is nil.
   ;; (default nil)
   dotspacemacs-server-socket-dir nil

   ;; If non-nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server t

   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `rg', `ag', `pt', `ack' and `grep'.
   ;; (default '("rg" "ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("rg" "ag" "pt" "ack" "grep")

   ;; Format specification for setting the frame title.
   ;; %a - the `abbreviated-file-name', or `buffer-name'
   ;; %t - `projectile-project-name'
   ;; %I - `invocation-name'
   ;; %S - `system-name'
   ;; %U - contents of $USER
   ;; %b - buffer name
   ;; %f - visited file name
   ;; %F - frame name
   ;; %s - process status
   ;; %p - percent of buffer above top of window, or Top, Bot or All
   ;; %P - percent of buffer above bottom of window, perhaps plus Top, or Bot or All
   ;; %m - mode name
   ;; %n - Narrow if appropriate
   ;; %z - mnemonics of buffer, terminal, and keyboard coding systems
   ;; %Z - like %z, but including the end-of-line format
   ;; If nil then Spacemacs uses default `frame-title-format' to avoid
   ;; performance issues, instead of calculating the frame title by
   ;; `spacemacs/title-prepare' all the time.
   ;; (default "%I@%S")
   dotspacemacs-frame-title-format nil

   ;; Format specification for setting the icon title format
   ;; (default nil - same as frame-title-format)
   dotspacemacs-icon-title-format nil

   ;; Show trailing whitespace (default t)
   dotspacemacs-show-trailing-whitespace t

   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed' to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup 'all

   ;; If non-nil activate `clean-aindent-mode' which tries to correct
   ;; virtual indentation of simple modes. This can interfere with mode specific
   ;; indent handling like has been reported for `go-mode'.
   ;; If it does deactivate it here.
   ;; (default t)
   dotspacemacs-use-clean-aindent-mode t

   ;; Accept SPC as y for prompts if non-nil. (default nil)
   dotspacemacs-use-SPC-as-y nil

   ;; If non-nil shift your number row to match the entered keyboard layout
   ;; (only in insert state). Currently supported keyboard layouts are:
   ;; `qwerty-us', `qwertz-de' and `querty-ca-fr'.
   ;; New layouts can be added in `spacemacs-editing' layer.
   ;; (default nil)
   dotspacemacs-swap-number-row nil

   ;; Either nil or a number of seconds. If non-nil zone out after the specified
   ;; number of seconds. (default nil)
   dotspacemacs-zone-out-when-idle nil

   ;; Run `spacemacs/prettify-org-buffer' when
   ;; visiting README.org files of Spacemacs.
   ;; (default nil)
   dotspacemacs-pretty-docs t

   ;; If nil the home buffer shows the full path of agenda items
   ;; and todos. If non-nil only the file name is shown.
   dotspacemacs-home-shorten-agenda-source nil

   ;; If non-nil then byte-compile some of Spacemacs files.
   dotspacemacs-byte-compile nil))

(defun dotspacemacs/user-env ()
  "Environment variables setup.
This function defines the environment variables for your Emacs session. By
default it calls `spacemacs/load-spacemacs-env' which loads the environment
variables declared in `~/.spacemacs.env' or `~/.spacemacs.d/.spacemacs.env'.
See the header of this file for more information."
  (spacemacs/load-spacemacs-env))

(defun dotspacemacs/user-init ()
  "Initialization for user code:
This function is called immediately after `dotspacemacs/init', before layer
configuration.
It is mostly for variables that should be set before packages are loaded.
If you are unsure, try setting them in `dotspacemacs/user-config' first."

  ;; custom theme modification
  ;; spacemacs - overriding default height of modeline
  ;; doom-gruvbox - subtle lsp symbol highlight
  (setq-default
   theming-modifications
   '((spacemacs-light
      (mode-line :height 0.92)
      (mode-line-inactive :height 0.92))
     (doom-solarized-light
      (mode-line :height 0.92)
      (mode-line-inactive :height 0.92))
     (doom-gruvbox-light
      (lsp-face-highlight-read :background nil :weight bold)
      (command-log-command :foreground "firebrick")
      (command-log-key :foreground "dark magenta"))))

  )  ;; End of dotspacemacs/user-int


(defun dotspacemacs/user-load ()
  "Library to load while dumping.
This function is called only while dumping Spacemacs configuration. You can
`require' or `load' the libraries of your choice that will be included in the
dump.")


(defun dotspacemacs/user-config ()
  "Configuration function for user code.
This function is called at the very end of Spacemacs initialization after
layers configuration.
This is the place where most of your configurations should be done. Unless it is
explicitly specified that a variable should be set before a package is loaded,
you should place your code here."

  ;; (setq ns-use-srgb-colorspace nil) ;; needed?

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; LSP
  (setq lsp-ui-sideline-enable nil)
  (setq lsp-modeline-diagnostics-scope :workspace)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Helm
  (setq history-delete-duplicates t)
  (setq extended-command-history
        (delq nil (delete-dups extended-command-history)))

  (setq evil-want-fine-undo t)
  (setq vc-follow-symlinks t) ;; automatically follow symlink to version-controlled file (ex. this file)
  ;; Make Spacemacs use helm-project-do-ag directly when pressing SPC / without preselecting the symbol under the cursor.
  (evil-leader/set-key "/" 'spacemacs/helm-project-do-ag)
  ;; (setq helm-ag-base-command "rg --vimgrep --no-heading --line-number --smart-case")

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; nREPL
  ;; Connecting to a reomote nREPL server
  (setq nrepl-use-ssh-fallback-for-remote-hosts t)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Keycast - show Emacs commands in mode line
  (use-package keycast
    :commands keycast-mode
    :config
    (define-minor-mode keycast-mode
      "Show current command and its key binding in the mode line."
      :global t
      (if keycast-mode
          (progn
            (add-hook 'pre-command-hook 'keycast-mode-line-update t)
            (add-to-list 'mode-line-misc-info '("" mode-line-keycast "    "))
            )
        (remove-hook 'pre-command-hook 'keycast-mode-line-update)
        (setq global-mode-string (remove '("" mode-line-keycast " ") mode-line-misc-info)))))

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Emacs text rendering optimizations
  ;; https://200ok.ch/posts/2020-09-29_comprehensive_guide_on_handling_long_lines_in_emacs.html

  ;; Only render text left to right
  (setq-default bidi-paragraph-direction 'left-to-right)

  ;; Disable Bidirectional Parentheses Algorithm
  (if (version<= "27.1" emacs-version)
      (setq bidi-inhibit-bpa t))

  ;; Files with known long lines
  ;; SPC f l to open files literally to disable most text processing

  ;; So long mode when Emacs thinks a file would affect performance
  (if (version<= "27.1" emacs-version)
      (global-so-long-mode 1))

  ;; End of: Emacs text rendering optimizations
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Doom theme settings
  (setq doom-gruvbox-light-variant "hard")

  (defun practicalli/setup-custom-doom-modeline ()
    (doom-modeline-set-modeline 'practicalli-modeline 'default))
  ;;
  (with-eval-after-load 'doom-modeline
    (doom-modeline-def-modeline 'practicalli-modeline
                                '(workspace-name window-number modals persp-name buffer-info matches remote-host vcs)
                                '(misc-info repl lsp))
    (practicalli/setup-custom-doom-modeline))

  ;; checker = flycheck results (not working)
  ;; buffer-position
  ;; word-count - number of words in current buffer
  ;; parrot
  ;; selection-info
  ;; repl - shows status of Cloure repl (not working)
  ;; process ??
  ;; debug
  ;; misc-info  - used for keycast
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; User key bindings
  ;;
  ;; org-journal - create a new journal entry - `, j' in org-journal mode
  (spacemacs/set-leader-keys "oj" 'org-journal-new-entry)
  ;;
  ;; Toggle workspaces forward/backwards
  (spacemacs/set-leader-keys "ow" 'eyebrowse-next-window-config)
  (spacemacs/set-leader-keys "oW" 'eyebrowse-last-window-config)

  ;; Revert buffer - loads in .dir-locals.el changes
  (spacemacs/set-leader-keys "oR" 'revert-buffer)
  ;;
  ;; Keycast mode - show key bindings and commands in mode line
  (spacemacs/set-leader-keys "ok" 'keycast-mode)

  ;; Replace Emacs Tabs key bindings with Workspace key bindings
  (with-eval-after-load 'evil-maps
    (when (featurep 'tab-bar)
      (define-key evil-normal-state-map "gt" nil)
      (define-key evil-normal-state-map "gT" nil)))
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Override Spacemacs defaults
  ;;
  ;; Set new location for file bookmarks, SPC f b
  ;; Default: ~/.emacs.d/.cache/bookmarks
  (setq bookmark-default-file "~/.spacemacs.d/bookmarks")
  ;;
  ;; Set new location for recent save files
  ;; Default: ~/.emacs.d/.cache/recentf
  (setq recentf-save-file  "~/.spacemacs.d/recentf")
  ;;
  ;; native line numbers taking up lots of space?
  (setq-default display-line-numbers-width nil)
  ;;
  ;; replace / search with helm-swoop in Evil normal state
  (evil-global-set-key 'normal "/" 'helm-swoop)
  ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Magit - forge configuration
  ;;
  ;; Set the files that are searched for writing tokens
  ;; by default ~/.authinfo will be used
  ;; and write a token in unencrypted format
  (setq auth-sources '("~/.authinfo.gpg"))
  ;;
  ;; Configure number of topics show, open and closed
  ;; use negative number to toggle the view of closed topics
  ;; using `SPC SPC forge-toggle-closed-visibility'
  (setq  forge-topic-list-limit '(100 . -10))
  ;; set closed to 0 to never show closed issues
  ;; (setq  forge-topic-list-limit '(100 . 0))
  ;;
  ;; GitHub user and organization accounts owned
  ;; used by @ c f  to create a fork
  (setq forge-owned-accounts
        '(("loganlinn"
           "patch-tech"
           "plumatic"
           "omcljs")))

  ;; To blacklist specific accounts,
  ;; over-riding forge-owned-accounts
  ;; (setq forge-owned-blacklist
  ;;       '(("bad-hacks" "really-bad-hacks")))
  ;;
  ;; End of Magit - forge configuration
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Safe structural editing
  ;; for all major modes
  (spacemacs/toggle-evil-safe-lisp-structural-editing-on-register-hooks)
  ;; for clojure layer only (comment out line above)
  ;; (spacemacs/toggle-evil-safe-lisp-structural-editing-on-register-hook-clojure-mode)
  ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Version Control configuration - Git, etc
  ;;
  ;; diff-hl - diff hightlights in right gutter as you type
  (diff-hl-flydiff-mode)
  ;;
  ;; Load in magithub features after magit package has loaded
  ;; (use-package magithub
  ;;   :after magit
  ;;   :config (magithub-feature-autoinject t))
  ;;
  ;; Use Spacemacs as the $EDITOR (or $GIT_EDITOR) for git commits messages
  ;; when using git commit on the command line
  ;; (global-git-commit-mode t)
  ;;
  ;; Set locations of all your Git repositories
  ;; with a number to define how many sub-directories to search
  ;; `SPC g L' - list all Git repositories in the defined paths,
  (setq magit-repository-directories
        '(("~/.emacs.d"  . 0)
          ("~/projects/" . 2)))
  ;;
  ;; end of version control configuration
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Org-mode configuration
  ;;
  ;; I should write a toggle function to show descriptive or literate links in Org-mode
  ;;(setq org-descriptive-links nil)
  ;;
  ;; Org-reveal - define were reveal.js files can be found
  ;; (I place reveal.js files in same directory as I write the org files)
  (setq org-reveal-root "")
  ;;
  ;; Define the location of the file to hold tasks
  (with-eval-after-load 'org
    (setq org-default-notes-file "~/Dropbox/todo-list.org"))
  ;;
  ;; Define a kanban style set of stages for todo tasks
  (with-eval-after-load 'org
    (setq org-todo-keywords
         '((sequence "TODO" "DOING" "BLOCKED" "REVIEW" "|" "DONE" "ARCHIVED"))))
  ;;
  ;; The default keywords all use the same colour.
  ;; Make the states easier to distinguish by using different colours
  ;; Using X11 colour names from: https://en.wikipedia.org/wiki/Web_colors
  ;; Setting colours (faces) using the `org-todo-keyword-faces' defcustom function
  ;; https://github.com/tkf/org-mode/blob/master/lisp/org-faces.el#L376
  ;; Using `with-eval-after-load' as a hook to call this setting when org-mode is run
  ;;
  (with-eval-after-load 'org
    (setq org-todo-keyword-faces
          '(("TODO" . "SlateGray")
            ("DOING" . "DarkOrchid")
            ("BLOCKED" . "Firebrick")
            ("REVIEW" . "Teal")
            ("DONE" . "ForestGreen")
            ("ARCHIVED" .  "SlateBlue"))))
  ;;
  ;;
  ;; Set TODO keyword faces if over-ridden by theme.
  (defun practicalli/set-todo-keyword-faces ()
    (interactive)
    (setq hl-todo-keyword-faces
          '(("TODO" . "SlateGray")
            ("DOING" . "DarkOrchid")
            ("BLOCKED" . "Firebrick")
            ("REVIEW" . "Teal")
            ("DONE" . "ForestGreen")
            ("ARCHIVED" .  "SlateBlue"))))
  ;;
  ;;
  ;; Progress Logging
  ;; When a TODO item enters DONE, add a CLOSED: property with current date-time stamp
  (with-eval-after-load 'org
    (setq org-log-done 'time))

  ;; Babel
  (with-eval-after-load 'org
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((clojure . t)
       (dot . t)
       (emacs-lisp . t)
       (gnuplot . t)
       (java . t)
       (js . t)
       (python . t)
       (plantuml . t)
       (shell . t)
       (sql . t)
       (sqlite . t))))

  ;;
  ;; Add TODO files to the agenda automatically
  (with-eval-after-load 'org-agenda
    (require 'org-projectile)
    (push (org-projectile:todo-files) org-agenda-files))

  ;;
  ;;
  ;; customize org-mode's checkboxes with unicode symbols
  (add-hook
   'org-mode-hook
   (lambda ()
     "Beautify Org Checkbox Symbol"
     (push '("[ ]" . "☐") prettify-symbols-alist)
     (push '("[X]" . "☑" ) prettify-symbols-alist)
     (push '("[-]" . "❍" ) prettify-symbols-alist)
     (prettify-symbols-mode)))
  ;;
  ;; Markdown mode hook for orgtbl-mode minor mode
  ;; (add-hook 'markdown-mode-hook 'turn-on-orgtbl)
  ;;
  ;; Turn on visual-line-mode for Org-mode only
  ;; (add-hook 'org-mode-hook 'turn-on-visual-line-mode)
  ;;
  ;; use org-re-reveal instead of org-reveal (which hasnt been updated in ages and breaks org-mode 9.2)
  ;; (use-package org-re-reveal :after org)
  ;;
  ;; End of Org-mode Configuration
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Clojure configurations
  ;;
  ;; Do not indent single ; comment characters
  (add-hook 'clojure-mode-hook (lambda () (setq-local comment-column 0)))

  ;; Auto-indent code automatically
  ;; https://emacsredux.com/blog/2016/02/07/auto-indent-your-code-with-aggressive-indent-mode/
  ;; (add-hook 'clojure-mode-hook #'aggressive-indent-mode)

  ;; Lookup functions in Clojure - The Essentail Reference book
  ;; https://github.com/p3r7/clojure-essential-ref
  (spacemacs/set-leader-keys "oh" 'clojure-essential-ref)
  ;;
  ;;
  ;; toggle reader macro sexp comment
  ;; toggles the #_ characters at the start of an expression
  (defun clojure-toggle-reader-comment-sexp ()
    (interactive)
    (let* ((point-pos1 (point)))
      (evil-insert-line 0)
      (let* ((point-pos2 (point))
             (cmtstr "#_")
             (cmtstr-len (length cmtstr))
             (line-start (buffer-substring-no-properties point-pos2 (+ point-pos2 cmtstr-len)))
             (point-movement (if (string= cmtstr line-start) -2 2))
             (ending-point-pos (+ point-pos1 point-movement 1)))
        (if (string= cmtstr line-start)
            (delete-char cmtstr-len)
          (insert cmtstr))
        (goto-char ending-point-pos)))
    (evil-normal-state))
  ;;
  ;; Assign keybinding to the toggle-reader-comment-sexp function
  (define-key global-map (kbd "C-#") 'clojure-toggle-reader-comment-sexp)
  ;;
  ;;
  ;; Toggle view of a clojure `(comment ,,,) block'
  (defun clojure-hack/toggle-comment-block (arg)
    "Close all top level (comment) forms. With universal arg, open all."
    (interactive "P")
    (save-excursion
      (goto-char (point-min))
      (while (search-forward-regexp "^(comment\\>" nil 'noerror)
        (call-interactively
         (if arg 'evil-open-fold
           'evil-close-fold)))))
  ;;
  (evil-define-key 'normal clojure-mode-map
    "zC" 'clojure-hack/toggle-comment-block
    "zO" (lambda () (interactive) (clojure-hack/toggle-comment-block 'open)))
  ;;
  ;; end of clojure configuration
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Web-mode configuration
  ;;
  ;; Changing auto indent size for languages in html layer (web mode) to 2 (defaults to 4)
  (defun web-mode-indent-2-hook ()
    "Indent settings for languages in Web mode, markup=html, css=css, code=javascript/php/etc."
    (setq web-mode-markup-indent-offset 2)
    (setq web-mode-css-indent-offset  2)
    (setq web-mode-code-indent-offset 2))
  ;;
  (add-hook 'web-mode-hook  'web-mode-indent-2-hook)
  ;;
  ;; End of Web-mode configuration
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Eshell visual enhancements
  ;;
  ;; Add git status visual labels
  ;;
  (require 'dash)
  (require 's)
  ;;
  (defmacro with-face (STR &rest PROPS)
    "Return STR propertized with PROPS."
    `(propertize ,STR 'face (list ,@PROPS)))
  ;;
  (defmacro esh-section (NAME ICON FORM &rest PROPS)
    "Build eshell section NAME with ICON prepended to evaled FORM with PROPS."
    `(setq ,NAME
           (lambda () (when ,FORM
                        (-> ,ICON
                            (concat esh-section-delim ,FORM)
                            (with-face ,@PROPS))))))
  ;;
  (defun esh-acc (acc x)
    "Accumulator for evaluating and concatenating esh-sections."
    (--if-let (funcall x)
        (if (s-blank? acc)
            it
          (concat acc esh-sep it))
      acc))
  ;;
  (defun esh-prompt-func ()
    "Build `eshell-prompt-function'"
    (concat esh-header
            (-reduce-from 'esh-acc "" eshell-funcs)
            "\n"
            eshell-prompt-string))
  ;;
  ;;
  ;; Unicode icons on Emacs
  ;; `list-character-sets' and select unicode-bmp
  ;; scroll through bitmaps list to find the one you want
  ;; some bitmaps seem to change
  ;;
  (esh-section esh-dir
               "\xf07c"  ;  (faicon folder)
               (abbreviate-file-name (eshell/pwd))
               '(:foreground "olive" :bold bold :underline t))
  ;;
  (esh-section esh-git
               "\xf397"  ;  (git branch icon)
               (magit-get-current-branch)
               '(:foreground "maroon"))
  ;;
  ;; (esh-section esh-python
  ;;              "\xe928"  ;  (python icon)
  ;;              pyvenv-virtual-env-name)
  ;;
  (esh-section esh-clock
               ""  ;  (clock icon)
               (format-time-string "%H:%M" (current-time))
               '(:foreground "forest green"))
  ;;
  ;; Below I implement a "prompt number" section
  (setq esh-prompt-num 0)
  (add-hook 'eshell-exit-hook (lambda () (setq esh-prompt-num 0)))
  (advice-add 'eshell-send-input :before
              (lambda (&rest args) (setq esh-prompt-num (incf esh-prompt-num))))
  ;;
  ;;
  ;; "\xf0c9"  ;  (list icon)
  (esh-section esh-num
               "\x2130"  ;  ℰ (eshell icon)
               (number-to-string esh-prompt-num)
               '(:foreground "brown"))
  ;;
  ;; Separator between esh-sections
  (setq esh-sep " ")  ; or " | "
  ;;
  ;; Separator between an esh-section icon and form
  (setq esh-section-delim "")
  ;;
  ;; Eshell prompt header
  (setq esh-header "\n ")  ; or "\n┌─"
  ;;
  ;; Eshell prompt regexp and string. Unless you are varying the prompt by eg.
  ;; your login, these can be the same.
  (setq eshell-prompt-regexp " \x2130 ")   ; or "└─> "
  (setq eshell-prompt-string " \x2130 ")   ; or "└─> "
  ;;
  ;; Choose which eshell-funcs to enable
  ;; (setq eshell-funcs (list esh-dir esh-git esh-python esh-clock esh-num))
  ;; (setq eshell-funcs (list esh-dir esh-git esh-clock esh-num))
  (setq eshell-funcs (list esh-dir esh-git))

  ;; Enable the new eshell prompt
  (setq eshell-prompt-function 'esh-prompt-func)

  ;; End of Eshell
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Shell configuration
  ;;
  (with-eval-after-load 'shell
    (add-hook 'sh-mode-hook 'shfmt-on-save-mode))
  ;; Use zsh for default multi-term shell
  ;; (setq multi-term-program "/usr/bin/zsh")
  ;;
  ;; End of Shell configuration
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Spaceline Doom theme settings
  ;; https://seagle0128.github.io/doom-modeline/
  ;; Configuration set in layer variables
  ;;
  ;; Set height of the modeline - will resize to height of text
  ;; (setq doom-modeline-height 12)

  ;; The left hand bar in the modeline
  ;; setting to zero shows a large box outline
  ;; (setq doom-modeline-bar-width 1)

  ;; Determine style of current filename / path displayed
  ;; default: auto
  ;; (setq doom-modeline-buffer-file-name-style 'relative-to-project)

  ;; default perspective name displayed in the mode-line.
  ;; (setq doom-modeline-display-default-persp-name t)

  ;; Do not show buffer encoding
  ;; (setq doom-modeline-buffer-encoding nil)

  ;; display GitHub notifications (requires `ghub' package)
  ;; (setq doom-modeline-github t)
  ;; The interval of checking GitHub.
  ;; (setq doom-modeline-github-interval (* 30 60))

  ;; GNUs notifications - default t
  ;; (setq doom-modeline-gnus nil)

  ;; IRC notifications - default t
  ;; (setq doom-modeline-irc nil)

  ;; Environment versions - default t
  ;; (setq doom-modeline-env-version t)

  ;; Use ascii rather than icon for modal state (more specific)
  ;; Icon not changing for doom-solarized-light theme
  ;; - icon changes color for doom-gruvbox-light theme
  ;; (setq doom-modeline-modal-icon nil)
  ;; End of Spaceline Doom theme settings
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  )   ;; End of dot-spacemacs/user-config

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(fringe-mode 0 nil (fringe))
 '(package-selected-packages
   '(sql-indent org-cliplink nord-theme rvm ruby-tools ruby-test-mode rubocop rspec-mode robe rbenv rake minitest chruby bundler inf-ruby bazel-mode web-mode tagedit slim-mode scss-mode sass-mode pug-mode helm-css-scss haml-mode go-guru go-eldoc emmet-mode elm-mode reformatter company-web web-completion-data company-go go-mode company-emacs-eclim eclim adoc-mode markup-faces xterm-color unfill shell-pop ox-gfm mwim multi-term helm-company helm-c-yasnippet fuzzy eshell-z eshell-prompt-extras esh-help company-statistics company clojure-snippets auto-yasnippet ac-ispell auto-complete org-projectile org-category-capture org-present org-pomodoro alert log4e gntp org-mime org-download htmlize gnuplot yaml-mode iedit anzu evil clj-refactor inflections seq queue spinner undo-tree gnu-elpa-keyring-update multiple-cursors paredit yasnippet cider sesman parseedn parseclj clojure-mode cider-eval-sexp-fu a powerline smartparens hydra lv parent-mode projectile pkg-info epl flx highlight goto-chg f dash s bind-map bind-key packed helm avy helm-core popup async mmm-mode markdown-toc markdown-mode gh-md ws-butler winum which-key volatile-highlights vi-tilde-fringe uuidgen use-package toc-org spaceline restart-emacs request rainbow-delimiters popwin persp-mode pcre2el paradox org-plus-contrib org-bullets open-junk-file neotree move-text macrostep lorem-ipsum linum-relative link-hint indent-guide hungry-delete hl-todo highlight-parentheses highlight-numbers highlight-indentation helm-themes helm-swoop helm-projectile helm-mode-manager helm-make helm-flx helm-descbinds helm-ag google-translate golden-ratio flx-ido fill-column-indicator fancy-battery eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-search-highlight-persist evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-lisp-state evil-indent-plus evil-iedit-state evil-exchange evil-escape evil-ediff evil-args evil-anzu eval-sexp-fu elisp-slime-nav dumb-jump diminish define-word column-enforce-mode clean-aindent-mode auto-highlight-symbol auto-compile aggressive-indent adaptive-wrap ace-window ace-link ace-jump-helm-line))
 '(show-paren-mode t)
 '(tool-bar-mode nil))

(defun dotspacemacs/emacs-custom-settings ()
  "Emacs custom settings.
This is an auto-generated function, do not modify its content directly, use
Emacs customize menu instead.
This function is called at the very end of Spacemacs initialization."
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(evil-want-Y-yank-to-eol nil)
 '(fringe-mode 0 nil (fringe))
 '(package-selected-packages
   '(toml-mode tern ron-mode racer rust-mode lsp-ui lsp-origami origami lsp-java dap-mode lsp-treemacs bui helm-lsp lsp-mode flycheck-rust flycheck-pos-tip pos-tip flycheck-elm cargo sql-indent org-cliplink nord-theme rvm ruby-tools ruby-test-mode rubocop rspec-mode robe rbenv rake minitest chruby bundler inf-ruby bazel-mode web-mode tagedit slim-mode scss-mode sass-mode pug-mode helm-css-scss haml-mode go-guru go-eldoc emmet-mode elm-mode reformatter company-web web-completion-data company-go go-mode company-emacs-eclim eclim adoc-mode markup-faces xterm-color unfill shell-pop ox-gfm mwim multi-term helm-company helm-c-yasnippet fuzzy eshell-z eshell-prompt-extras esh-help company-statistics company clojure-snippets auto-yasnippet ac-ispell auto-complete org-projectile org-category-capture org-present org-pomodoro alert log4e gntp org-mime org-download htmlize gnuplot yaml-mode iedit anzu evil clj-refactor inflections seq queue spinner undo-tree gnu-elpa-keyring-update multiple-cursors paredit yasnippet cider sesman parseedn parseclj clojure-mode cider-eval-sexp-fu a powerline smartparens hydra lv parent-mode projectile pkg-info epl flx highlight goto-chg f dash s bind-map bind-key packed helm avy helm-core popup async mmm-mode markdown-toc markdown-mode gh-md ws-butler winum which-key volatile-highlights vi-tilde-fringe uuidgen use-package toc-org spaceline restart-emacs request rainbow-delimiters popwin persp-mode pcre2el paradox org-plus-contrib org-bullets open-junk-file neotree move-text macrostep lorem-ipsum linum-relative link-hint indent-guide hungry-delete hl-todo highlight-parentheses highlight-numbers highlight-indentation helm-themes helm-swoop helm-projectile helm-mode-manager helm-make helm-flx helm-descbinds helm-ag google-translate golden-ratio flx-ido fill-column-indicator fancy-battery eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-search-highlight-persist evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-lisp-state evil-indent-plus evil-iedit-state evil-exchange evil-escape evil-ediff evil-args evil-anzu eval-sexp-fu elisp-slime-nav dumb-jump diminish define-word column-enforce-mode clean-aindent-mode auto-highlight-symbol auto-compile aggressive-indent adaptive-wrap ace-window ace-link ace-jump-helm-line))
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
)
