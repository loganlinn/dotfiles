;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

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

(setq display-line-numbers-type 'relative)


;; Org
(setq org-directory "~/org/")
(after! org-mode (require 'ol-man)) ;; enable manpage links (man:)

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

;; which-key
(setq which-key-idle-delay 0.4)

;; Bindings I've become acustom to from other editors...
(map!
 ;; vim
 :nv "C-a" #'evil-numbers/inc-at-pt
 :nv "C-S-a" #'evil-numbers/dec-at-pt
 ;; Intellij
 (:after flycheck
  :desc "Jump to next error" [f2]   #'flycheck-next-error
  :desc "Jump to prev error" [S-f2] #'flycheck-previous-error)
 (:when (featurep! :tools lsp)
  (:after lsp
   :desc "Rename" [S-f6] #'lsp-rename))
 ;; Spacemacs
 (:when (featurep! :ui treemacs)
  :leader
  :desc "Focus sidebar" "0" #'treemacs-select-window))

(use-package! treemacs
  :defer t
  :init
  (setq +treemacs-git-mode 'deferred) ;; hack: should be in :config, but placed here to utilize logic in doom-emacs/modules/ui/treemacs (https://github.com/hlissner/doom-emacs/blob/aed2972d7400834210759727117c50de34826db9/modules/ui/treemacs/config.el#L32)
  :config
  (treemacs-project-follow-mode +1)
  (map! :map treemacs-mode-map
        :desc "Expand" [mouse-1] #'treemacs-single-click-expand-action
        :desc "Rename file" [f2] #'treemacs-rename-file
        :desc "Refresh" [f5] #'treemacs-refresh))

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

(setq-hook! 'projectile-mode-hook
  projectile-project-search-path '(("~/src" . 3))
  projectile-enable-caching nil
  projectile-indexing-method 'alien)

;; Disable some of ligatures enabled by (ligatures +extra)
(let ((ligatures-to-disable '(:true :false :int :float :str :bool :list :and :or)))
  (dolist (sym ligatures-to-disable)
    (plist-put! +ligatures-extra-symbols sym nil)))

(load! "clojure.el")

(load! "magit.el")
