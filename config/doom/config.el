;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Logan Linn"
      user-mail-address "logan@llinn.dev")

(setq delete-by-moving-to-trash t
      trash-directory (concat (or (getenv "XDG_DATA_HOME") "~/.local/share") "/Trash/files"))

(setq doom-theme 'doom-one
      ;;doom-font (font-spec :family "Fira Code" :size 14 :weight 'light)
      doom-font (font-spec :family "DejaVu Sans Mono" :size 14)
      ;;doom-variable-pitch-font (font-spec :family "Fira Sans")
      ;;doom-unicode-font (font-spec :family "DejaVu Sans Mono")
      ;;doom-big-font (font-spec :family "Fira Mono" :size 19)
      )

;;; :core editor
 (setq display-line-numbers-type 'relative
       fill-column 99)

;;; :core packages
;; projectile
(after! projectile

  (setq projectile-create-missing-test-files t
        projectile-project-search-path '(("~/src" . 3))
        projectile-enable-caching nil
        projectile-indexing-method 'alien)

  (defun projectile-root-poly-workspace-dir (dir)
    "Identify a project root in DIR by top-downsearch for Polylith workspace.edn in dir.
Return the first (topmost) matched directory or nil if not found."
    (locate-dominating-file dir "workspace.edn"))

  (setq projectile-project-root-functions '(projectile-root-local
                                            projectile-root-poly-workspace-dir
                                            projectile-root-bottom-up
                                            projectile-root-top-down
                                            projectile-root-top-down-recurring))


  (projectile-update-project-type 'clojure-cli
                                  :src-dir "src"
                                  :test-dir "test")
  ;; vim-projectionist (a.vim) style commands for impl<>test files
  (evil-ex-define-cmd "A"  'projectile-toggle-between-implementation-and-test)
  (evil-ex-define-cmd "AV" '(lambda ()
                              (interactive)
                              (evil-window-vsplit)
                              (windmove-right)
                              (projectile-toggle-between-implementation-and-test)))
  (evil-ex-define-cmd "AS" '(lambda ()
                              (interactive)
                              (evil-window-split)
                              (windmove-down)
                              (projectile-toggle-between-implementation-and-test))))

;;; :editor evil
;; Focus new window after splitting
(after! evil
  (setq evil-split-window-below t
        evil-vsplit-window-right t))

(map!
 ;; vim
 :nv "C-a"   #'evil-numbers/inc-at-pt
 :nv "C-S-a" #'evil-numbers/dec-at-pt

 ;; vim-projectionist (a.vim)
 (:leader
  :prefix-map ("p" . "project")
  :desc "Toggle impl/test" "A" #'projectile-toggle-between-implementation-and-test)

 ;; Intellij error nav
 (:after flycheck
  :desc "Jump to next error" [f2]   #'flycheck-next-error
  :desc "Jump to prev error" [S-f2] #'flycheck-previous-error)

 ;; Intellij rename
 (:when (featurep! :tools lsp)
  (:after lsp
   :desc "Rename" [S-f6] #'lsp-rename)))

(map! :nvi

      :desc "Expand region"
      "M-=" #'er/expand-region

      :desc "Reverse expand region"
      "M--" (lambda () (interactive) (er/expand-region -1)))

(map! :leader

      :desc "Open dotfiles"
      "f T" #'open-dotfiles

      :desc "Find file in dotfiles"
      "f t" #'find-in-dotfiles)

;; Fix evil-cleverparens in terminal (https://github.com/emacs-evil/evil-cleverparens/issues/58)

;; disable additional bindings so they aren't bound when the package loads
(setq evil-cleverparens-use-additional-bindings nil)
(after! evil-cleverparens
  ;; turn on the "additional-bindings" so that when we call `evil-cp-set-additional-bindings` it will bind keys
  (setq evil-cleverparens-use-additional-bindings t)
  (unless window-system
    ;; when we're in the terminal, delete the bindings for M-[ and M-] from the alist of additional bindings
    (setq evil-cp-additional-bindings (assoc-delete-all "M-[" evil-cp-additional-bindings))
    (setq evil-cp-additional-bindings (assoc-delete-all "M-]" evil-cp-additional-bindings)))
  ;; bind all the keys listed in evil-cp-additional-bindings
  (evil-cp-set-additional-bindings))

;;; :ui treemacs
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


;;; :tools gist
(after! gist
  (setq gist-view-gist t))


;;; :tools lsp
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

(use-package! lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable nil
        lsp-ui-peek-enable nil))
(setq-hook! 'lisp-ui
  lsp-enable-indentation t
  lsp-enable-on-type-formatting t
  lsp-ui-doc-border (doom-color 'fg)
  lsp-ui-doc-enable t
  lsp-ui-doc-include-signature t
  lsp-ui-doc-include-signature t
  lsp-ui-doc-max-height 30
  lsp-ui-doc-max-width 100
  lsp-ui-sideline-enable nil
  lsp-ui-sideline-ignore-duplicate t
  lsp-lens-enable t)

(use-package! lsp-treemacs
  :config
  (setq lsp-treemacs-error-list-current-project-only t))


;;; :ui doom-theme
(setq doom-themes-treemacs-theme "doom-colors")


;;; :ui doom-dashboard
(setq fancy-splash-image (concat doom-private-dir "splash.png"))
;; Hide the menu for as minimalistic a startup screen as possible.
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)


;;; :ui ligatures
;; Disable some of ligatures enabled by (ligatures +extra)
(let ((ligatures-to-disable '(:true :false :int :float :str :bool :list :and :or :for)))
  (dolist (sym ligatures-to-disable)
    (plist-put! +ligatures-extra-symbols sym nil)))


;;; :tools lookup
(add-to-list '+lookup-provider-url-alist '("grep.app" "https://grep.app/search?q=%s"))
(setq +lookup-provider-url-alist (assoc-delete-all "Google images" +lookup-provider-url-alist))
(setq +lookup-provider-url-alist (assoc-delete-all "Google maps" +lookup-provider-url-alist))
(setq +lookup-provider-url-alist (assoc-delete-all "DuckDuckGo" +lookup-provider-url-alist))


;;; :package which-key
(after! which-key
  (setq which-key-idle-delay 0.4))


;;; :lang org
(setq org-directory "~/org/")
(after! org-mode (require 'ol-man)) ;; enable manpage links (man:)

;;; :lang nix
(set-formatter! 'alejandra "alejandra --quiet" :modes '(nix-mode))

;;; :lang sh
;; (use-package! flymake-shellcheck
;;   :hook (sh-mode . flymake-shellcheck-load)
;;   :commands flymake-shellcheck-load
;;   :init
;;   (add-hook 'sh-mode-hook 'flymake-shellcheck-load))

(load! "+ui")
(load! "+magit")
(load! "+clojure")
;;(load! "+crystal")
