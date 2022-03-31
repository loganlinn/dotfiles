;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Logan Linn"
      user-mail-address "logan@llinn.dev")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq delete-by-moving-to-trash t
      ;; https://specifications.freedesktop.org/trash-spec/trashspec-1.0.html
      trash-directory (concat (or (getenv "XDG_DATA_HOME") "~/.local/share") "/Trash/files"))

(after! org-mode
  ;; enable manpage links (man:)
  (require 'ol-man))


;; i want my ~~mtv~~ intellij...
(map! (:after flycheck
       :desc "Jump to next error" [f2]   #'flycheck-next-error
       :desc "Jump to prev error" [S-f2] #'flycheck-previous-error)
      (:when (featurep! :tools lsp)
       (:after lsp
        :desc "Rename" [S-f6] #'lsp-rename)))

(use-package! flycheck
  :defer t
  :config
  (setq-default flycheck-disabled-checkers
                ;; Most of these elisp warnings assume that I'm writing a proper package
                ;; with full documentation. This is usually not the case, so just
                ;; disable them.
                '(emacs-lisp-checkdoc)))

(use-package! treemacs
  :defer t
  :init
  (message "treemacs :init")
  (setq +treemacs-git-mode 'deferred)
  (map! :leader
        :desc "Treemacs"
        "0" #'treemacs-select-window)
  (map! :map treemacs-mode-map
        [mouse-1] #'treemacs-single-click-expand-action)
  :config
  (message "treemacs :config")
  (treemacs-project-follow-mode +1))

(use-package! evil-cleverparens
  :after evil
  :init
  (setq evil-cleverparens-use-regular-insert nil
        evil-cleverparens-swap-move-by-word-and-symbol t
        evil-want-fine-undo t
        evil-move-beyond-eol t)
  :config
  (evil-set-command-properties 'evil-cp-change :move-point t)
  (smartparens-strict-mode +1)
  (evil-cleverparens-mode +1))


(after! lsp-mode
  (setq lsp-log-io nil
        lsp-file-watch-threshold 8264
        lsp-headerline-breadcrumb-enable nil)
  (dolist (dir '("[/\\\\]\\.ccls-cache\\'"
                 "[/\\\\]\\.mypy_cache\\'"
                 "[/\\\\]\\.pytest_cache\\'"
                 "[/\\\\]\\.cache\\'"
                 "[/\\\\]\\.clwb\\'"
                 "[/\\\\]__pycache__\\'"
                 "[/\\\\]bazel-bin\\'"
                 "[/\\\\]bazel-code\\'"
                 "[/\\\\]bazel-genfiles\\'"
                 "[/\\\\]bazel-out\\'"
                 "[/\\\\]bazel-testlogs\\'"
                 "[/\\\\]third_party\\'"
                 "[/\\\\]third-party\\'"
                 "[/\\\\]buildtools\\'"
                 "[/\\\\]out\\'"))
    (push dir lsp-file-watch-ignored-directories)))

(setq-hook! 'lisp-ui
  lsp-enable-on-type-formatting t
  lsp-enable-indentation t
  lsp-ui-doc-max-width 100
  lsp-ui-doc-max-height 30
  lsp-ui-doc-include-signature t
  lsp-ui-sideline-enable nil
  lsp-lens-enable t)

(setq-hook! 'cider-mode-hook
  ;; open cider-doc directly and close it with q
  cider-prompt-for-symbol nil
  cider-save-file-on-load 'always-save)

(setq-hook! 'clojure-mode-hook
  clojure-toplevel-inside-comment-form t)

(add-hook! '(lisp-mode-hook emacs-lisp-mode-hook clojure-mode-hook)
  (subword-mode +1)
  (aggressive-indent-mode +1)
  (smartparens-strict-mode +1)
  (evil-cleverparens-mode +1))

(add-hook! 'cider-repl-mode-hook
  (subword-mode +1)
  (aggressive-indent-mode -1)
  (smartparens-strict-mode +1)
  (evil-cleverparens-mode +1))

(after! cider-mode
  (evil-define-key 'normal cider-repl-mode-map
    "C-j" 'cider-repl-next-input
    "C-k" 'cider-repl-previous-input))

(add-hook! '(cider-connected-hook
             cider-disconnected-hook
             cider-mode-hook)
  (defun +clojure--cider-eval-development-reload-sexp ()
    "Evaluate a fixed expression used frequently in development to start/reload system."
    (interactive)
    (cider-interactive-eval
     (format "(require 'dev) (dev/go)" (cider-last-sexp))))
  (map! (:map (clojure-mode-map clojurescript-mode-map clojurec-mode-map)
         "C-<f5>" #'+clojure--cider-eval-development-reload-sexp)))

(after! clj-refactor
  ;;  Idiomatic namespace aliases [[https://github.com/bbatsov/clojure-style-guide#use-idiomatic-namespace-aliases]]
  (setq cljr-magic-require-namespaces
        '(("io"    . "clojure.java.io")
          ("as"    . "clojure.core.async")
          ("csv"   . "clojure.data.csv")
          ("edn"   . "clojure.edn")
          ("mat"   . "clojure.core.matrix")
          ("nrepl" . "clojure.nrepl")
          ("pp"    . "clojure.pprint")
          ("s"     . "clojure.spec.alpha")
          ("set"   . "clojure.set")
          ("spec"  . "clojure.spec.alpha")
          ("str"   . "clojure.string")
          ("walk"  . "clojure.walk")
          ("xml"   . "clojure.data.xml")
          ("zip"   . "clojure.zip")
          ("json"  . "cheshire.core")
          ("time"  . "java-time")
          ("http"  . "clj-http.client")
          ("log"   . "clojure.tools.logging")
          ("sql"   . "honey.sql")
          ("sqlh"  . "honey.sql.helpers")
          ("yaml"  . "clj-yaml.core")
          ("sh"    . "clojure.java.shell")))
  (define-key 'clojure-refactor-map (kbd "n c") #'cljr-clean-ns))

(after! magit
  (setq magit-diff-refine-hunk 'all
        magit-repository-directories '(("~/src" . 3)))
  (add-hook! 'after-save-hook #'magit-after-save-refresh-status))

(after! forge
  (setq  forge-topic-list-limit '(100 . -10)
         forge-owned-accounts '(("loganlinn"
                                 "patch-tech"
                                 "plumatic"
                                 "omcljs"))))

;; (use-package! org-noter
;;   :commands org-noter)
