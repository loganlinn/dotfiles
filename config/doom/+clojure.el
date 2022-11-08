;;; :lang clojure
(after! clojure-mode
  (setq clojure-toplevel-inside-comment-form t)

  (add-hook! 'clojure-mode-hook
             #'aggressive-indent-mode)

  (define-clojure-indent
    (match 1)
    ;; plumbing
    (fnk :defn)
    (defnk :defn)
    (letk 1)
    (for-map 1)
    ;; potemkin
    (definterface+    '(2 nil nil (1)))
    (defprotocol+     '(1 (:defn)))
    (defrecord+       '(2 nil nil (1)))
    (deftype+         '(2 nil nil (1)))
    (extend-protocol+ '(1 :defn))
    (reify+           '(:defn (1)))
    (reify-map-type   '(:defn (1)))
    (def-map-type     '(2 nil nil (1)))
    (def-derived-map  '(2 nil nil (1)))
    (try* 0)
    ;; next.jdbc
    (on-connection 1)))

(after! cider
  (setq cider-prompt-for-symbol nil
        cider-save-file-on-load 'always-save ;; don't prompt to save. just do it.
        cider-print-fn 'puget
        cider-repl-history-size 1000
        cider-known-endpoints nil
        ;;cider-repl-buffer-size-limit 200
        cider-enrich-classpath t)

  (cider-add-to-alist 'cider-jack-in-dependencies "djblue/portal" "0.29.1")

  (map! (:map clojure-mode-map
         :desc "Reload system" "C-<f5>" #'+cider-eval-dev-reload)
        ;(:map cider-repl-mode-map
        ; :n "C-j" 'cider-repl-next-input
        ; :n "C-k" 'cider-repl-previous-input)
        (:map clojure-mode-map
         "C-c M-k" #'+cider-jack-in-clj-polylith
         "C-c M-l" #'portal.api/open
         "C-c M-S-l" #'portal.api/clear))

  (defun +cider-jack-in-clj-polylith (params)
    "Start an nREPL server for the current Polylith workspace and connect to it."
    (interactive "P")
    (let ((ws-dir (locate-dominating-file (pwd) "workspace.edn")))
      (if ws-dir
          (progn
            (message "Starting nREPL server from `%s'" ws-dir)
            (cider-jack-in-clj (plist-put params :project-dir ws-dir)))
        (error "Unable to locate 'workspace.edn' in current directory or parent directory"))))

  (defun +cider-eval-dev-reload  ()
    "Evaluate a fixed expression used frequently in development to start/reload system."
    (interactive)
    (cider-ensure-connected)
    (cider-interactive-eval "(require 'dev) (dev/go)"))

  ;; def portal to the dev namespace to allow dereferencing via @dev/portal
  (defun portal.api/open ()
    (interactive)
    (cider-nrepl-sync-request:eval
     "(do (ns dev) (def portal ((requiring-resolve 'portal.api/open))) (add-tap (requiring-resolve 'portal.api/submit)) (.addShutdownHook (Runtime/getRuntime) (Thread. #((requiring-resolve 'portal.api/close)))))"))

  (defun portal.api/clear ()
    (interactive)
    (cider-nrepl-sync-request:eval "(portal.api/clear)"))

  (defun portal.api/close ()
    (interactive)
    (cider-nrepl-sync-request:eval "(portal.api/close)")))

(after! clj-refactor
  (map! :map clojure-refactor-map
        :desc "Add missing libspec" "n a" #'cljr-add-missing-libspec
        :desc "Clean ns" "n c" #'lsp-clojure-clean-ns)

  (setq cljr-add-ns-to-blank-clj-files t
        cljr-hotload-dependencies nil
        cljr-magic-require-namespaces
        '(;; Clojure
          ("as"    . "clojure.core.async")
          ("csv"   . "clojure.data.csv")
          ("edn"   . "clojure.edn")
          ("io"    . "clojure.java.io")
          ("log"   . "clojure.tools.logging")
          ("mat"   . "clojure.core.matrix")
          ("nrepl" . "clojure.nrepl")
          ("pp"    . "clojure.pprint")
          ("s"     . "clojure.spec.alpha")
          ("set"   . "clojure.set")
          ("sh"    . "clojure.java.shell")
          ("spec"  . "clojure.spec.alpha")
          ("str"   . "clojure.string")
          ("walk"  . "clojure.walk")
          ("xml"   . "clojure.data.xml")
          ("zip"   . "clojure.zip")
          ;; Others
          ("http"     . "clj-http.client")
          ("json"     . "cheshire.core")
          ("m"        . "malli.core")
          ("p"        . "plumbing.core")
          ("sql"      . "honey.sql")
          ("sqlh"     . "honey.sql.helpers")
          ("jt"       . "java-time")
          ("yaml"     . "clj-yaml.core"))))

  (use-package! evil-cleverparens
    :after evil
    :init
    (setq evil-cleverparens-use-regular-insert nil
          evil-cleverparens-swap-move-by-word-and-symbol t
          evil-want-fine-undo t
          evil-move-beyond-eol t)
    :config
    (evil-set-command-properties 'evil-cp-change :move-point t)

    (add-hook! 'emacs-lisp-mode-hook
      (evil-cleverparens-mode t)
      (smartparens-strict-mode t))

    (add-hook! 'clojure-mode-hook
      (evil-cleverparens-mode t)
      (smartparens-strict-mode t))

    (add-hook! 'cider-repl-mode-hook
      (evil-cleverparens-mode t)
      (smartparens-strict-mode t))
    )
