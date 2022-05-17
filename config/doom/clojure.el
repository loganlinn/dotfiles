(defun jet-pretty ()
  (interactive)
  (shell-command-on-region
   (region-beginning)
   (region-end)
   "jet --pretty --edn-reader-opts '{:default tagged-literal}'"
   (current-buffer)
   t
   "*jet error buffer*"
   t))

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
  '(
    ("as"    . "clojure.core.async")
    ("csv"   . "clojure.data.csv")
    ("edn"   . "clojure.edn")
    ("http"  . "clj-http.client")
    ("io"    . "clojure.java.io")
    ("json"  . "cheshire.core")
    ("log"   . "clojure.tools.logging")
    ("m"     . "malli.core")
    ("mat"   . "clojure.core.matrix")
    ("nrepl" . "clojure.nrepl")
    ("p"     . "plumbing.core")
    ("pp"    . "clojure.pprint")
    ("s"     . "clojure.spec.alpha")
    ("set"   . "clojure.set")
    ("sh"    . "clojure.java.shell")
    ("spec"  . "clojure.spec.alpha")
    ("sql"   . "honey.sql")
    ("sqlh"  . "honey.sql.helpers")
    ("str"   . "clojure.string")
    ("time"  . "java-time")
    ("walk"  . "clojure.walk")
    ("xml"   . "clojure.data.xml")
    ("yaml"  . "clj-yaml.core")
    ("zip"   . "clojure.zip")

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
    ))

(add-hook! 'clojure-mode-hook
  (subword-mode +1)
  (aggressive-indent-mode +1)
  (smartparens-strict-mode +1)
  (evil-cleverparens-mode +1)

  (define-clojure-indent
    ;;
    ;; prismatic plumbing
    ;;
    (fnk :defn)
    (defnk :defn)
    (letk 1)
    (for-map 1)
    ;;
    ;; potemkin
    ;;
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

    ;;
    ;; next.jdbc
    ;;
    (on-connection 1)
    )

  ;; prismatic/schema
  ;;(put 's/defrecord 'clojure-backtracking-indent '(4 4 (2)))
  ;;(put 's/defrecord+ 'clojure-backtracking-indent '(4 4 (2)))
  ;; potemkin
  ;;(put 'potemkin/deftype+ 'clojure-backtracking-indent '(4 4 (2)))
  ;;(put 'potemkin/defrecord+ 'clojure-backtracking-indent '(4 4 (2)))
  )

(setq-hook! 'cider-mode-hook
  ;; open cider-doc directly and close it with q
  cider-prompt-for-symbol nil
  cider-save-file-on-load 'always-save)

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
  (define-key 'clojure-refactor-map (kbd "n c") #'cljr-clean-ns)
  (setq cljr-add-ns-to-blank-clj-files +1))
