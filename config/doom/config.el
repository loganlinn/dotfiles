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
(setq display-line-numbers-type t)


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

(setq delete-by-moving-to-trash t                 ; Delete files to trash
      window-combination-resize t                 ; take new window space from all other windows (not just current)
      x-stretch-cursor t                          ; Stretch cursor to the glyph width
      undo-limit 80000000                         ; Raise undo-limit to 80Mb
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…"                ; Unicode ellispis are nicer than "...", and also save /precious/ space
      password-cache-expiry nil                   ; I can trust my computers ... can't I?
      scroll-margin 2)                            ; It's nice to maintain a little margin

(after! doom
  (global-subword-mode 1) ; Iterate through CamelCase words
  (display-time-mode 1)   ; Enable time in the mode-line
  )

(after! evil
  (setq evil-want-fine-undo t
        evil-move-beyond-eol t))

;; (remove-hook 'doom-first-buffer-hook #'smartparens-global-mode) ;; remove smartparens

(add-hook! '(clojure-mode-hook
             clojurescript-mode-hook
             clojurec-mode-hook
             cider-repl-mode-hook
             emacs-lisp-mode-hook)
  (smartparens-strict-mode)
  (rainbow-delimiters-mode))

(after! smartparens
  (smartparens-global-strict-mode 1))

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
                 "[/\\\\]out\\'"
                 ))
    (push dir lsp-file-watch-ignored-directories)))

(after! lsp-ui
  (setq lsp-enable-on-type-formatting t
        lsp-enable-indentation t
        lsp-ui-doc-max-width 100
        lsp-ui-doc-max-height 30
        lsp-ui-doc-include-signature t
        lsp-ui-sideline-enable nil
        lsp-lens-enable t))

(after! treemacs
  (setq
   treemacs-project-follow-mode t
   treemacs-use-git-mode 'deferred
   treemacs-use-scope-type 'Perspectives
   treemacs-width 35))

(use-package! git-link
  :config
  (setq git-link-use-commit t))

(map! :leader "0" #'treemacs-select-window) ;; spacemacs-style treemacs binding
