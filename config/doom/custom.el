(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((cljr-magic-require-namespaces
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
