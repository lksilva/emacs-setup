;; ――――――――――――――――――――――――――――――――――― Set up 'package' ――――――――――――――――――――――――――――――――――
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; Install 'use-package' if it is not installed.
(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)

;; ――――――――――――――――――――――――――――――――― Use better defaults ―――――――――――――――――――――――――――――――
(setq-default
 ;; Don't use the compiled code if its the older package.
 load-prefer-newer t

 ;; Do not show the startup message.
 inhibit-startup-message t

 ;; Do not put 'customize' config in init.el; give it another file.
 custom-file "~/.emacs.d/custom-file.el"

 ;; 72 is too less for the fontsize that I use.
 fill-column 90

 ;; Use your name in the frame title. :)
 frame-title-format (format "%s's Emacs" (capitalize user-login-name))

 ;; Do not create lockfiles.
 create-lockfiles nil

 ;; Don't use hard tabs
 ;; indent-tabs-mode nil

 ;; Emacs can automatically create backup files. This tells Emacs to put all backups in
 ;; ~/.emacs.d/backups. More info:
 ;; http://www.gnu.org/software/emacs/manual/html_node/elisp/Backup-Files.html
 backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))

 ;; Do not autosave.
 ;; auto-save-default nil

 ;; Allow commands to be run on minibuffers.
 enable-recursive-minibuffers t)

;; Change all yes/no questions to y/n type
(fset 'yes-or-no-p 'y-or-n-p)

;; Display column number in mode line.
(column-number-mode t)

;; Automatically update buffers if file content on the disk has changed.
(global-auto-revert-mode t)

;; ――――――――――――――――――――――――――― Disable unnecessary UI elements ―――――――――――――――――――――――――
(progn
  ;; Do not show menu bar.
  (menu-bar-mode -1)

  ;; Do not show tool bar.
  (when (fboundp 'tool-bar-mode)
    (tool-bar-mode -1))

  ;; Do not show scroll bar.
  (when (fboundp 'scroll-bar-mode)
    (scroll-bar-mode -1))

  ;; Highlight line on point.
  (global-hl-line-mode t))

;; ―――――――――――――――――――――――― Added functionality (Generic usecases) ―――――――――――――――――――――――
(defun toggle-comment-on-line ()
  "comment or uncomment current line"
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(defun comment-pretty ()
  "Inserts a comment with '―' (Unicode character: U+2015) on each side."
  (interactive)
  (let* ((comment (read-from-minibuffer "Comment: "))
         (comment-length (length comment))
         (current-column-pos (current-column))
         (space-on-each-side (/ (- fill-column
                                   current-column-pos
                                   comment-length
                                   (length comment-start)
                                   ;; Single space on each side of comment
                                   (if (> comment-length 0) 2 0)
                                   ;; Single space after comment syntax sting
                                   1)
                                2)))
    (if (< space-on-each-side 2)
        (message "Comment string is too big to fit in one line")
      (progn
        (insert comment-start)
        (when (equal comment-start ";")
          (insert comment-start))
        (insert " ")
        (dotimes (_ space-on-each-side) (insert "―"))
        (when (> comment-length 0) (insert " "))
        (insert comment)
        (when (> comment-length 0) (insert " "))
        (dotimes (_ (if (= (% comment-length 2) 0)
                        space-on-each-side
                      (- space-on-each-side 1)))
          (insert "―"))))))

;; ――――――――――――――――――――― Additional packages and their configurations ――――――――――――――――――――

;; Add `:doc' support for use-package so that we can use it like what a doc-strings is for
;; functions.
(eval-and-compile
  (add-to-list 'use-package-keywords :doc t)
  (defun use-package-handler/:doc (name-symbol _keyword _docstring rest state)
    "An identity handler for :doc.
     Currently, the value for this keyword is being ignored.
     This is done just to pass the compilation when :doc is included

     Argument NAME-SYMBOL is the first argument to `use-package' in a declaration.
     Argument KEYWORD here is simply :doc.
     Argument DOCSTRING is the value supplied for :doc keyword.
     Argument REST is the list of rest of the  keywords.
     Argument STATE is maintained by `use-package' as it processes symbols."

    ;; just process the next keywords
    (use-package-process-keywords name-symbol rest state)))

;; ――――――――――――――――――――― Additional packages and their configurations ――――――――――――――――――――
(setq indent-tabs-mode nil)

;; ――――――――――――――――――――――――――――――――――― Generic packages ――――――――――――――――――――――――――――――――――
(use-package recentf
  :doc "Recent buffers in a new Emacs session"
  :config
  (setq recentf-auto-cleanup 'never
        recentf-max-saved-items 1000
        recentf-save-file (concat user-emacs-directory ".recentf"))
  (recentf-mode t))

(use-package ibuffer
  :doc "Better buffer management"
  :bind ("C-x C-b" . ibuffer))

(use-package ido-completing-read+
  :doc "Allow ido usage in as many contexts as possible"
  :ensure t
  :config
  ;; This enables ido in all contexts where it could be useful, not just
  ;; for selecting buffer and file names
  (ido-mode t)
  (ido-everywhere t)
  ;; This allows partial matches, e.g. "uzh" will match "Ustad Zakir Hussain"
  (setq ido-enable-flex-matching t)
  (setq ido-use-filename-at-point nil)
  ;; Includes buffer names of recently opened files, even if they're not open now.
  (setq ido-use-virtual-buffers t))

(use-package smex
  :doc "Enhance M-x to allow easier execution of commands"
  :ensure t
  ;; Using counsel-M-x for now. Remove this permanently if counsel-M-x works better.
  :disabled t
  :config
  (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  (smex-initialize)
  :bind ("M-x" . smex))

(use-package projectile
  :doc "Project navigation"
  :ensure t
  :config
  ;; Use it everywhere
  (projectile-global-mode t)
  :bind ("C-x f" . projectile-find-file)
  :diminish nil)

(use-package magit
  :doc "Git integration for Emacs"
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package which-key
  :doc "Prompt the next possible key bindings after a short wait"
  :ensure t
  :config
  (which-key-mode t)
  :diminish nil)

(use-package ido-vertical-mode
  :doc "Show ido vertically"
  :ensure t
  :config
  (ido-vertical-mode t))

(use-package ivy
  :doc "A generic completion mechanism"
  :ensure t
  :config
  (ivy-mode t)
  (setq ivy-wrap t)
  (setq ivy-use-virtual-buffers t)
  ;; Counsel starts all prompts with the default regex `^'.
  ;; This is not needed.
  (setq ivy-initial-inputs-alist nil)
  :bind (("C-x b" . ivy-switch-buffer)
         ("C-x B" . ivy-switch-buffer-other-window))
  :diminish nil)

(use-package swiper
  :doc "A better search"
  :ensure t
  :bind (("C-s" . swiper)
         ("C-M-s" . isearch-forward-regexp)
         ("C-M-r" . isearch-backward-regexp)))

(use-package counsel
  :doc "Ivy enhanced Emacs commands"
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("C-c i" . counsel-imenu)
         ("C-c s" . counsel-ag)))

(use-package git-gutter
  :doc "Shows modified lines"
  :ensure t
  :config
  (global-git-gutter-mode t)
  (setq git-gutter:modified-sign "|")
  (set-face-foreground 'git-gutter:modified "grey")
  (set-face-foreground 'git-gutter:added "green")
  (set-face-foreground 'git-gutter:deleted "red")
  :bind (("C-x C-g" . git-gutter))
  :diminish nil)

(use-package esup
  :doc "Emacs Start Up Profiler (esup) benchmarks Emacs
        startup time without leaving Emacs."
  :ensure t)

(when (eq system-type 'darwin)
  (use-package exec-path-from-shell
    :doc "MacOS does not start a shell at login. This makes sure
          that the env variable of shell and GUI Emacs look the
          same."
    :ensure t
    :config
    (when (memq window-system '(mac ns))
      (exec-path-from-shell-initialize)
      (exec-path-from-shell-copy-envs
       '("PATH" "ANDROID_HOME" "LEIN_USERNAME" "LEIN_PASSPHRASE"
         "LEIN_JVM_OPTS" "NPM_TOKEN" "LANGUAGE" "LANG" "LC_ALL"
         "MOBY_ENV" "JAVA_8_HOME" "JAVA_7_HOME" "JAVA_HOME" "PS1"
         "NVM_DIR" "GPG_TTY")))))

(use-package diminish
  :doc "Hide minor modes from mode line"
  :ensure t)

;; ――――――――――――――――――――――――――――――――――――― Code editing ――――――――――――――――――――――――――――――――――――
(use-package company
  :doc "COMplete ANYthing"
  :ensure t
  :bind (:map
         global-map
         ("TAB" . company-complete-common-or-cycle)
         ;; Use hippie expand as secondary auto complete. It is useful as it is
         ;; 'buffer-content' aware (it uses all buffers for that).
         ("M-/" . hippie-expand)
         :map company-active-map
         ("C-n" . company-select-next-or-abort)
         ("C-p" . company-select-previous-or-abort))
  :config
  (setq company-idle-delay 0.3)
  (global-company-mode t)

  ;; Configure hippie expand as well.
  (setq hippie-expand-try-functions-list
        '(try-expand-dabbrev
          try-expand-dabbrev-all-buffers
          try-expand-dabbrev-from-kill
          try-complete-lisp-symbol-partially
          try-complete-lisp-symbol))

  :diminish nil)

(use-package paredit
  :doc "Better handling of paranthesis when writing Lisp"
  :ensure t
  :init
  (add-hook 'clojure-mode-hook #'enable-paredit-mode)
  (add-hook 'cider-repl-mode-hook #'enable-paredit-mode)
  (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
  (add-hook 'ielm-mode-hook #'enable-paredit-mode)
  (add-hook 'lisp-mode-hook #'enable-paredit-mode)
  (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
  (add-hook 'scheme-mode-hook #'enable-paredit-mode)
  :config
  (show-paren-mode t)
  :bind (("M-[" . paredit-wrap-square)
         ("M-{" . paredit-wrap-curly))
  :diminish nil)

(use-package rainbow-delimiters
  :doc "Colorful paranthesis matching"
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package highlight-symbol
  :doc "Highlight and jump to symbols"
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'highlight-symbol-mode)
  (set-face-background 'highlight-symbol-face "#a45bad")
  (setq highlight-symbol-idle-delay 0.5)
  :bind (("M-n" . highlight-symbol-next)
         ("M-p" . highlight-symbol-prev)))

;; ――――――――――――――――――――――――――――――――――――――― Clojure ――――――――――――――――――――――――――――――――――――――
;; Install all packages needed to clojure environment run properly
(setq package-selected-packages '(clojure-mode lsp-mode cider lsp-treemacs flycheck company))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (mapc #'package-install package-selected-packages))

(add-hook 'clojure-mode-hook 'lsp)
(add-hook 'clojurescript-mode-hook 'lsp)
(add-hook 'clojurec-mode-hook 'lsp)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      company-minimum-prefix-length 1)

;; ―――――――――――――――――――――――――――――――――――――――― Theme ―――――――――――――――――――――――――――――――――――――――
(use-package ewal-spacemacs-themes
  :ensure t
  :config
  (setq spacemacs-theme-comment-bg nil
        spacemacs-theme-comment-italic t)
  (load-theme 'spacemacs-dark t))

(use-package powerline
  :doc "Better mode line"
  :ensure t
  :config
  (powerline-center-theme))

(use-package "faces"
  :config
  (set-face-attribute 'default nil :height 140)

  ;; Use the 'Fira Code' if available
  (when (not (eq system-type 'windows-nt))
    (when (member "Fira Code" (font-family-list))

      ;; Fira code legatures
      (let ((alist '((33 . ".\\(?:\\(?:==\\|!!\\)\\|[!=]\\)")
                     (35 . ".\\(?:###\\|##\\|_(\\|[#(?[_{]\\)")
                     (36 . ".\\(?:>\\)")
                     (37 . ".\\(?:\\(?:%%\\)\\|%\\)")
                     (38 . ".\\(?:\\(?:&&\\)\\|&\\)")
                     ;; (42 . ".\\(?:\\(?:\\*\\*/\\)\\|\\(?:\\*[*/]\\)\\|[*/>]\\)")
                     (43 . ".\\(?:\\(?:\\+\\+\\)\\|[+>]\\)")
                     ;; Causes "error in process filter: Attempt to shape unibyte text".
                     (45 . ".\\(?:\\(?:-[>-]\\|<<\\|>>\\)\\|[<>}~-]\\)")
                     ;; Fira code page said that this causes an error in Mojave.
                     ;; (46 . ".\\(?:\\(?:\\.[.<]\\)\\|[.=-]\\)")
                     (47 . ".\\(?:\\(?:\\*\\*\\|//\\|==\\)\\|[*/=>]\\)")
                     (48 . ".\\(?:x[a-zA-Z]\\)")
                     (58 . ".\\(?:::\\|[:=]\\)")
                     (59 . ".\\(?:;;\\|;\\)")
                     (60 . ".\\(?:\\(?:!--\\)\\|\\(?:~~\\|->\\|\\$>\\|\\*>\\|\\+>\\|--\\|<[<=-]\\|=[<=>]\\||>\\)\\|[*$+~/<=>|-]\\)")
                     ;; (61 . ".\\(?:\\(?:/=\\|:=\\|<<\\|=[=>]\\|>>\\)\\|[<=>~]\\)")
                     (62 . ".\\(?:\\(?:=>\\|>[=>-]\\)\\|[=>-]\\)")
                     (63 . ".\\(?:\\(\\?\\?\\)\\|[:=?]\\)")
                     (91 . ".\\(?:]\\)")
                     (92 . ".\\(?:\\(?:\\\\\\\\\\)\\|\\\\\\)")
                     (94 . ".\\(?:=\\)")
                     (119 . ".\\(?:ww\\)")
                     (123 . ".\\(?:-\\)")
                     (124 . ".\\(?:\\(?:|[=|]\\)\\|[=>|]\\)")
                     (126 . ".\\(?:~>\\|~~\\|[>=@~-]\\)"))))
        (dolist (char-regexp alist)
          (set-char-table-range composition-function-table (car char-regexp)
                                `([,(cdr char-regexp) 0 font-shape-gstring]))))

      (set-frame-font "Fira Code Retina"))))

;; ――――――――――――――――――――――――――――――――――――― Custom setup ―――――――――――――――――――――――――――――――――――――
;; Use SHIFT+arrow to move between the windows
(windmove-default-keybindings)
(global-display-line-numbers-mode)

(defun overwrite-theme ()
    (progn
      (set-cursor-color "dark orange")
      (set-mouse-color "dark orange")))

;; change color of the current line
;; (custom-set-faces
;; '(hl-line ((t (:background "#98fb98")))))

(custom-set-faces
 '(region ((t (:background "#98fb98" :foreground "black")))))

(overwrite-theme)

(defun open-eshell ()
  (interactive)
  (let* ((lines (window-body-height))
         (new-window (split-window-vertically (floor (* 0.7 lines)))))
    (select-window new-window)
    (eshell "eshell")))

;; ――――――――――――――――――――――――――――――――――――――― Keybinds ―――――――――――――――――――――――――――――――――――――――
(global-set-key (kbd "C-;") 'toggle-comment-on-line)
(global-set-key (kbd "C-c ;") 'comment-pretty)
(global-set-key (kbd "M-s-p") 'projectile-switch-project)
(global-set-key (kbd "M-s-o") 'projectile-switch-open-project)
(global-set-key (kbd "M-s-a") 'projectile-add-known-project)
(global-set-key (kbd "M-s-f") 'projectile--find-file)
(global-set-key (kbd "M-s-c") 'cider-repl-clear-buffer)
(global-set-key (kbd "s-L") 'cider-eval-file)
(global-set-key (kbd "s-N") 'cider-repl-set-ns)
(global-set-key (kbd "C-x g") 'magit)
(global-set-key (kbd "s-C") 'paredit-copy-as-kill)
(global-set-key (kbd "C-c e") 'open-eshell)
