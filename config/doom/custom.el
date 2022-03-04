(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(treepy))
 '(safe-local-variable-values
   '((cljr-warn-on-eval nil)
     (cider-repl-init-code "(dev)")
     (cider-clojure-cli-global-options . "-A:dev:test:+default")
     (cider-repl-init-code "(start)")
     (cider-ns-refresh-after-fn . "dev-extras/resume")
     (cider-ns-refresh-before-fn . "dev-extras/suspend")
     (cljr-clojure-test-declaration "[clojure.test :as t :refer [deftest is testing]"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
