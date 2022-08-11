;;; ~/.config/doom/autoload/logan.el -*- lexical-binding: t; -*-

;;;###autoload
(defun find-in-dotfiles ()
  "Open a file somewhere in ~/.dotfiles via a fuzzy filename search."
  (interactive)
  (doom-project-find-file (expand-file-name "~/.dotfiles")))

;;;###autoload
(defun browse-dotfiles ()
  "Browse the files in ~/.dotfiles."
  (interactive)
  (doom-project-browse (expand-file-name "~/.dotfiles")))

;;;###autoload
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

