(defconst ll-javascript-packages
  '(
    add-node-modules-path
    company-flow
    eslintd-fix
    flycheck
    rjsx-mode
    ))

(defun ll-javascript/init-eslintd-fix ()
  (use-package eslintd-fix
    :defer t
    :commands eslintd-fix-mode
    :init
    (progn
      (add-hook 'rjsx-mode-hook #'eslintd-fix-mode t)
      (add-hook 'rjsx-mode-hook #'ll-javascript/set-eslintd-fix-preprocess-command t))))

(defun ll-javascript/set-eslintd-fix-preprocess-command ()
  (let ((prettier (executable-find "prettier")))
    (when prettier
      (setq-local eslintd-fix-preprocess-command
                  (concat
                   prettier
                   " --trailing-comma es5"
                   " --bracket-spacing false"
                   " --single-quote")))))

(defun ll-javascript/init-rjsx-mode ()
  (use-package rjsx-mode
    :defer t
    :init
    (progn
      (add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))

      (setq
       js2-mode-show-strict-warnings nil
       js2-mode-show-parse-errors nil
       js-indent-level 2
       js2-basic-offset 2
       js2-strict-trailing-comma-warning nil
       js2-strict-missing-semi-warning nil)

      (add-hook 'rjsx-mode-hook #'ll-javascript/eslintd-set-flycheck-executable t))
    :config
    (modify-syntax-entry ?_ "w" js2-mode-syntax-table)))

(defun ll-javascript/init-add-node-modules-path ()
  (use-package add-node-modules-path
    :defer t
    :init
    (with-eval-after-load 'rjsx-mode
      (add-hook 'rjsx-mode-hook #'add-node-modules-path))))

(defun ll-javascript/post-init-company-flow ()
  (spacemacs|add-company-backends
    :backends
    '((company-flow :with company-dabbrev-code)
      company-files)))

(defun ll-javascript/post-init-flycheck ()
  (with-eval-after-load 'flycheck
    (push 'javascript-jshint flycheck-disabled-checkers)
    (push 'json-jsonlint flycheck-disabled-checkers))

  (spacemacs/add-flycheck-hook 'rjsx-mode))
