;; -*- no-byte-compile: t; -*-
;;; ~/.config/doom/packages.el

(package! synosaurus)

(package! aggressive-indent)
(package! button-lock)
;;(package! cider :pin "11156e7b0cab470f4aab39d3af5ee3cb1e0b09d0 " :recipe (:host github :repo "clojure-emacs/cider" :files ("*.el" (:exclude ".dir-locals.el") "cider-pkg.el")))
(package! evil-cleverparens)
(package! magit-delta)
(package! neil :recipe (:host github :repo "babashka/neil" :files ("*.el")))
(package! zprint-mode)

(package! protobuf-mode)

(unpin! lsp-treemacs)
(unpin! lsp-ui)
(unpin! treemacs)
(unpin! hover)

;; (package! flymake-shellcheck)

;; (package! just-mode)
;; (package! justl)

;;; ~/.config/doom/packages.el ends here
