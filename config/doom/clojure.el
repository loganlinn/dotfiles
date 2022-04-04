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

(setq-hook! 'clojure-mode-hook
  ;; C-c inside (comment ,,,)
  clojure-toplevel-inside-comment-form t

  ;; See: [[Idiomatic namespace aliases][https://github.com/bbatsov/clojure-style-guide#use-idiomatic-namespace-aliases]]
  cljr-magic-require-namespaces
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

(setq-hook! 'cider-mode-hook
  ;; open cider-doc directly and close it with q
  cider-prompt-for-symbol nil
  cider-save-file-on-load 'always-save)

(add-hook! 'clojure-mode-hook
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
    "C-k" 'cider-repl-previous-input)

  (defun +clojure--cider-eval-development-reload-sexp ()
    "Evaluate a fixed expression used frequently in development to start/reload system."
    (interactive)
    (cider-ensure-connected)
    (cider-interactive-eval "(require 'dev) (dev/go)"))

  (map! :map clojure-mode-map
        :desc "Reload system" "C-<f5>" #'+clojure--cider-eval-development-reload-sexp))

(after! clj-refactor
  (define-key 'clojure-refactor-map (kbd "n c") #'cljr-clean-ns))
