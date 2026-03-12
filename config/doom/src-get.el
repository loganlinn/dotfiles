;;; src-get.el --- Clone git repositories to predictable locations -*- lexical-binding: t; -*-

(defcustom src-get-home (expand-file-name "~/src")
  "Base directory for cloning repositories."
  :group 'src-get
  :type 'directory)

(defcustom src-get-clone-args '("--depth=1" "--progress")
  "Default arguments for git clone command."
  :group 'src-get
  :type '(repeat string))

(defun src-get--normalize-repo (input)
  "Normalize INPUT into a valid git repository URL."
  (cond
   ;; Full URL (https://github.com/org/repo or git@github.com:org/repo)
   ((or (string-match-p "^[^:]+://" input)
        (string-match-p "^[^@]+@[^:]+:" input))
    input)
   ;; Domain with path (github.com/org/repo)
   ((string-match-p "^[^/]+\\.[^/]+/" input)
    (concat "https://" input))
   ;; Org/repo format (org/repo)
   ((string-match-p "^[^/]+/[^/]+$" input)
    (concat "https://github.com/" input))
   ;; Single name - would need gh integration, fallback to error
   (t (error "Invalid repository format: %s" input))))

(defun src-get--repo-to-path (repo-url)
  "Convert REPO-URL to filesystem path under `src-get-home'."
  (let ((path (cond
               ;; SSH format (git@host:path)
               ((string-match "^[^@]+@\\([^:]+\\):\\(.+\\)" repo-url)
                (concat (match-string 1 repo-url) "/" (match-string 2 repo-url)))
               ;; HTTP(S) format
               ((string-match "^[^:]+://\\(.+\\)" repo-url)
                (match-string 1 repo-url))
               (t repo-url))))
    ;; Remove .git suffix if present
    (setq path (replace-regexp-in-string "\\.git$" "" path))
    (expand-file-name path src-get-home)))

(defun src-get--clone-repo (repo-url dest-path)
  "Clone REPO-URL to DEST-PATH using git."
  (unless (file-exists-p dest-path)
    (let ((parent-dir (file-name-directory dest-path)))
      (unless (file-exists-p parent-dir)
        (make-directory parent-dir t)))
    (let ((default-directory (file-name-directory dest-path))
          (args (append '("clone") src-get-clone-args (list "--" repo-url dest-path))))
      (if (zerop (apply #'call-process "git" nil "*src-get*" t args))
          (message "✅ Cloned %s to %s" repo-url dest-path)
        (error "Failed to clone %s" repo-url)))))

;;;###autoload
(defun src-get (repo-input)
  "Clone git repository from REPO-INPUT to predictable location.
Supports:
- Full URLs: https://github.com/org/repo
- SSH URLs: git@github.com:org/repo  
- Domain paths: github.com/org/repo
- GitHub shorthand: org/repo"
  (interactive "sRepository: ")
  (let* ((repo-url (src-get--normalize-repo repo-input))
         (dest-path (src-get--repo-to-path repo-url)))
    (src-get--clone-repo repo-url dest-path)
    (when (fboundp 'projectile-add-known-project)
      (projectile-add-known-project dest-path))
    (find-file dest-path)))

(provide 'src-get)
;;; src-get.el ends here