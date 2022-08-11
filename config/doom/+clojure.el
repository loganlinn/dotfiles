;;; :lang clojure
(after! clojure-mode
  (setq clojure-toplevel-inside-comment-form t)
  (define-clojure-indent
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
        cider-save-file-on-load 'always-save
        cider-repl-buffer-size-limit 100
        cider-enrich-classpath t)
  (map! (:map cider-mode-map
         :desc "Reload system" "C-<f5>" #'+clojure--cider-eval-development-reload-sexp)
        (:map cider-repl-mode-map
         :n "C-j" 'cider-repl-next-input
         :n "C-k" 'cider-repl-previous-input))
  (defun +clojure--cider-eval-development-reload-sexp ()
    "Evaluate a fixed expression used frequently in development to start/reload system."
    (interactive)
    (cider-ensure-connected)
    (cider-interactive-eval "(require 'dev) (dev/go)")))

(after! clj-refactor
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
          ("p.a.eql"  . "com.wsscode.pathom3.interface.async.eql")
          ("p.cache"  . "com.wsscode.pathom3.cache")
          ("p.eql"    . "com.wsscode.pathom3.interface.eql")
          ("p.error"  . "com.wsscode.pathom3.error")
          ("p.path"   . "com.wsscode.pathom3.path")
          ("p.plugin" . "com.wsscode.pathom3.plugin")
          ("pbip"     . "com.wsscode.pathom3.connect.built-in.plugins")
          ("pbir"     . "com.wsscode.pathom3.connect.built-in.resolvers")
          ("pcf"      . "com.wsscode.pathom3.connect.foreign")
          ("pci"      . "com.wsscode.pathom3.connect.indexes")
          ("pco"      . "com.wsscode.pathom3.connect.operation")
          ("pcot"     . "com.wsscode.pathom3.connect.operation.transit")
          ("pcp"      . "com.wsscode.pathom3.connect.planner")
          ("pcr"      . "com.wsscode.pathom3.connect.runner")
          ("pf.eql"   . "com.wsscode.pathom3.format.eql")
          ("psm"      . "com.wsscode.pathom3.interface.smart-map")
          ("sql"      . "honey.sql")
          ("sqlh"     . "honey.sql.helpers")
          ("jt"       . "java-time")
          ("yaml"     . "clj-yaml.core")))

        ;; (defun +cljr-align-clj-dependencies ()
        ;;   (interactive "P")
        ;;   (let* ((project-file (cljr--project-file))
        ;;          (deps (cljr--project-with-deps-p project-file)))
        ;;     (debug)
        ;;     (cljr--update-file project-file
        ;;       (goto-char (point-min))
        ;;       (when deps
        ;;         (re-search-forward ":deps")
        ;;         (forward-sexp)
        ;;         (backward-char)
        ;;         (clojure-align))
        ;;       (cljr--post-command-message "Aligned :deps of %s" project-file))))

        (map! :map clojure-refactor-map
              :desc "Add missing libspec" "n a" #'cljr-add-missing-libspec
              ;; :desc "Clean ns" "n c" #'cljr-clean-ns
              :desc "Clean ns" "n c" #'lsp-clojure-clean-ns))

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
    (evil-cleverparens-mode +1)
    (add-hook! 'clojure-mode-hook
      (subword-mode +1)
      (aggressive-indent-mode +1)
      (smartparens-strict-mode +1)
      (evil-cleverparens-mode +1))
    (add-hook! 'cider-repl-mode-hook
      (subword-mode +1)
      (aggressive-indent-mode -1)
      (smartparens-strict-mode +1)
      (evil-cleverparens-mode +1)))

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
  (cider-nrepl-sync-request:eval "(portal.api/close)"))

(map! :map clojure-mode-map
      ;; cmd  + o
      :n "C-S-l" #'portal.api/open
      ;; ctrl + l
      :n "C-l" #'portal.api/clear)

;; (setq cider-clojure-cli-global-options "-A:portal")
