(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((cljr-clojure-test-declaration . "[clojure.test :as test :refer [deftest is testing]]")
     (eval define-clojure-indent
           (potemkin/def-abstract-type
            '(1
              (:defn)))
           (potemkin/defprotocol+
            '(1
              (:defn)))
           (potemkin/defrecord+
            '(2 nil nil
                (:defn)))
           (potemkin/deftype+
            '(2 nil nil
                (:defn)))
           (p/def-map-type
            '(2 nil nil
                (:defn)))
           (p/defprotocol+
            '(1
              (:defn)))
           (p/defrecord+
            '(2 nil nil
                (:defn)))
           (p/deftype+
            '(2 nil nil
                (:defn)))
           (tools\.macro/macrolet
            '(1
              ((:defn))
              :form)))
     (eval put-clojure-indent 'prop/for-all 1)
     (eval put 'defprotocol+ 'clojure-doc-string-elt 2)
     (eval put 'potemkin/defprotocol+ 'clojure-doc-string-elt 2)
     (eval put 's/defn 'clojure-doc-string-elt 2)
     (clojure-docstring-fill-column . 118)
     (cider-preferred-build-tool . clojure-cli)
     (cljr-favor-prefix-notation)
     (clojure-mode
      (cider-clojure-cli-aliases . "dev:test:build:+default")
      (cider-repl-init-code "(dev)"))
     (clojure-build-tool-files quote
                               ("workspace.edn" "deps.edn" "bb.edn"))
     (cljr-magic-require-namespaces
      ("io" . "clojure.java.io")
      ("as" . "clojure.core.async")
      ("csv" . "clojure.data.csv")
      ("edn" . "clojure.edn")
      ("mat" . "clojure.core.matrix")
      ("nrepl" . "clojure.nrepl")
      ("pprint" . "clojure.pprint")
      ("s" . "clojure.spec.alpha")
      ("set" . "clojure.set")
      ("shell" . "clojure.java.shell")
      ("spec" . "clojure.spec.alpha")
      ("str" . "clojure.string")
      ("walk" . "clojure.walk")
      ("xml" . "clojure.data.xml")
      ("zip" . "clojure.zip")
      ("csk" . "camel-snake-kebab.core")
      ("cske" . "camel-snake-kebab.extras")
      ("duct" . "duct.core")
      ("fs" . "babashka.fs")
      ("ig" . "integrant.core")
      ("json" . "cheshire.core")
      ("m" . "malli.core")
      ("mi" . "malli.instrument")
      ("mr" . "malli.registry")
      ("mt" . "malli.transform")
      ("mu" . "malli.util")
      ("sql" . "honey.sql")
      ("sqlh" . "honey.sql.helpers")
      ("time" . "java-time")
      ("yaml" . "clj-yaml.core")
      ("lacinia" . "com.walmartlabs.lacinia")
      ("lacinia.executor" . "com.walmartlabs.lacinia.executor")
      ("lacinia.resolve" . "com.walmartlabs.lacinia.resolve")
      ("lacinia.schema" . "com.walmartlabs.lacinia.schema")
      ("lacinia.selection" . "com.walmartlabs.lacinia.selection")
      ("bigquery" . "patch.gcp-bigquery.interface")
      ("ex" . "patch.common-exceptions.interface")
      ("http" . "patch.common-http.interface")
      ("log" . "patch.common-log.interface")
      ("utils" . "patch.common-utils.interface"))
     (url-max-redirections . 0)
     (cider-ns-refresh-after-fn . "integrant.repl/resume")
     (cider-ns-refresh-before-fn . "integrant.repl/suspend")
     (cljr-magic-require-namespaces
      ("io" . "clojure.java.io")
      ("as" . "clojure.core.async")
      ("csv" . "clojure.data.csv")
      ("edn" . "clojure.edn")
      ("mat" . "clojure.core.matrix")
      ("nrepl" . "clojure.nrepl")
      ("pprint" . "clojure.pprint")
      ("s" . "clojure.spec.alpha")
      ("set" . "clojure.set")
      ("shell" . "clojure.java.shell")
      ("spec" . "clojure.spec.alpha")
      ("str" . "clojure.string")
      ("walk" . "clojure.walk")
      ("xml" . "clojure.data.xml")
      ("zip" . "clojure.zip")
      ("csk" . "camel-snake-kebab.core")
      ("cske" . "camel-snake-kebab.extras")
      ("fs" . "babashka.fs")
      ("ig" . "integrant.core")
      ("json" . "cheshire.core")
      ("m" . "malli.core")
      ("mi" . "malli.instrument")
      ("mr" . "malli.registry")
      ("mt" . "malli.transform")
      ("mu" . "malli.util")
      ("sql" . "honey.sql")
      ("sqlh" . "honey.sql.helpers")
      ("time" . "java-time")
      ("yaml" . "clj-yaml.core")
      ("bigquery" . "patch.gcp-bigquery.interface")
      ("ex" . "patch.common-exceptions.interface")
      ("http" . "patch.common-http.interface")
      ("log" . "patch.common-log.interface")
      ("utils" . "patch.common-utils.interface"))
     (cljr-clojure-test-declaration . "[clojure.test :as t :refer [deftest is testing]]")
     (cljr-warn-on-eval)
     (cider-repl-init-code "(dev)")
     (cider-clojure-cli-global-options . "-A:dev:test:build:+default"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
