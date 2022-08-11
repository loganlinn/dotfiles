;;;; ~/.config/doom/+ui.el

;;; :ui hl-todo
(use-package! hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config
  (add-to-list 'hl-todo-keyword-faces '("OPTIMIZE" font-lock-keyword-face bold)))


(after! button-lock
  ;;
  ;; [[PAT-123]]
  ;;
  (button-lock-set-button "PAT-[0-9]+"
                          (lambda ()
                            (interactive)
                            (browse-url (concat "https://linear.app/patch-tech/issue/"
                                                (buffer-substring
                                                 (previous-single-property-change (point) 'mouse-face)
                                                 (next-single-property-change (point) 'mouse-face)))))
                          :face             'link
                          :face-policy      'prepend
                          :keyboard-binding "RET"
                          )
  )
