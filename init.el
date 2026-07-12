;;; init.el ---  -*- lexical-binding: t -*-

  ;; Author: Kyure_A <github.com/Kyure-A>
  ;; Maintainer: Kyure_A <github.com/Kyure-A>

  ;;; Commentary:

  ;;              .mmmmmmmmmmmmmm.                   .cccccccc!                .(.
  ;;  .+eeeee.   .??:   +m<   <mm.    .aaaaaaaa.    ccC!           .+sssss{    (!!
  ;; .ee:        .mm:   +mm   .mm_   .aa>   (aaA    cCC           .ss>         1!:
  ;; .ee_        .mm:   +mm   .mm_   .aa{    aaA    ccC           .sss.        !!
  ;; .ee_ <ee    .mm:   +mm   .mm_   .aa{ .(AaaA    cCC`           .<sssss    .!:
  ;; .ee_        .mm:   +mm   .mm_   .aa{ .??aaA    cCCc......         .ss:   ..
  ;; .eee....    .<<!   ?<<   .<<`   .aa{    aaA     ?CCCCCCC!    ....(s=: .!!-
  ;;  .?eeeee`                       .AA!    AAA                  .ssss<s!   .!!

  ;;; Code:  



;; 使用清华大学 TUNA 镜像
(setq package-archives
      '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
        ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setopt use-package-always-ensure t)

(defun my/use-package-ensure-smart (name args state &optional no-refresh)
  "如果 NAME 已经是内置可用的功能/函数,就跳过安装,否则走正常的 package-install。"
  (unless (or (fboundp name) (featurep name) (locate-library (symbol-name name)))
    (use-package-ensure-elpa name args state no-refresh)))

(setopt use-package-ensure-function #'my/use-package-ensure-smart)

(require 'package)


  (defvar my/delayed-priority-low-configurations '())
  (defvar my/delayed-priority-low-configuration-timer nil)

  (setq my/delayed-priority-low-configuration-timer
          (run-with-timer
           0.3 0.001
           (lambda ()
             (if my/delayed-priority-low-configurations
                 (let ((inhibit-message t))
                   (eval (pop my/delayed-priority-low-configurations)))
               (progn
                 (cancel-timer my/delayed-priority-low-configuration-timer))))))

  (defmacro with-delayed-execution (&rest body)
    (declare (indent 0))
    `(setq my/delayed-priority-low-configurations
           (append my/delayed-priority-low-configurations ',body)))

  (require 'cl-lib t)
  (setq byte-compile-warnings '(cl-functions))

  (eval-when-compile
    (require 'use-package))

  (eval-and-compile
   ;; (setopt use-package-ensure-function #'(lambda (&rest args) t))
    (setopt use-package-always-defer t)
    (setopt use-package-compute-statistics t))


  (global-set-key (kbd "<f3>") 'dashboard-open)
  (global-set-key (kbd "RET") 'smart-newline)
  (global-set-key (kbd "C-RET") 'newline)
  (global-set-key (kbd "<backspace>") 'smart-hungry-delete-backward-char)
  (global-set-key (kbd "C-<backspace>") 'backward-delete-word)
  (global-set-key (kbd "C-<left>") 'centaur-tabs-forward)
  (global-set-key (kbd "C-<right>") 'centaur-tabs-backward)
  (global-set-key (kbd "C-<return>") 'newline)
  (global-set-key (kbd "C-SPC") 'toggle-input-method)

  (global-set-key (kbd "C-x g") 'magit-status)
  (global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)
  (global-set-key (kbd "C-x i") 'nil)
  (global-set-key (kbd "C-x i i") 'consult-yasnippet)
  (global-set-key (kbd "C-x i n") 'yas-new-snippet)
  (global-set-key (kbd "C-x u") 'nil)
  (global-set-key (kbd "C-x C-z") 'nil)
  (global-set-key (kbd "C-x C-c") 'nil)


  (global-set-key (kbd "C-c e b") 'eval-buffer)
  (global-set-key (kbd "C-c e m") 'menu-bar-mode)
  (global-set-key (kbd "C-c m") 'minuet-configure-provider)
  (global-set-key (kbd "C-c p") 'smartparens-global-mode)
  (global-set-key (kbd "C-c r") 'vr/replace)

  (global-set-key (kbd "C-l") 'eglot)

  (global-set-key (kbd "C-a") 'mwim-beginning-of-code-or-line)
  (global-set-key (kbd "C-d") 'smart-hungry-delete-backward-char)
  (global-set-key (kbd "C-e") 'mwim-end-of-code-or-line)
  (global-set-key (kbd "C-h") 'smart-hungry-delete-backward-char)
  (global-set-key (kbd "C-m") 'smart-newline)
  (global-set-key (kbd "C-o") 'nil)
  (global-set-key (kbd "C-u") 'undo-fu-only-undo)
  (global-set-key (kbd "C-r") 'undo-fu-only-redo)
  (global-set-key (kbd "C-s") 'consult-line)
  (global-set-key (kbd "C-z") 'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo)
  (global-set-key (kbd "C-/") 'other-window)
  (global-set-key (kbd "C-;") 'smart-hungry-delete-forward-char)
  (global-set-key (kbd "C-.") 'embark-act)


  (global-set-key (kbd "M-k") 'puni-backward-kill-line)
  (global-set-key (kbd "M-.") #'dumb-jump-go)
  (global-set-key (kbd "M-,") #'dumb-jump-back)

  (fset 'yes-or-no-p 'y-or-n-p)

  (setq mouse-wheel-progressive-speed nil)
  (setq scroll-preserve-screen-position 'always)

  (setq-default indent-tabs-mode nil)

  (use-package saveplace :hook (after-init-hook . save-place-mode))

  (use-package elec-pair :hook (after-init-hook . electric-pair-mode))

  (use-package delsel :hook (after-init-hook . delete-selection-mode))

  (defun auto-yes (old-fun &rest args)
    (cl-letf (((symbol-function 'y-or-n-p) (lambda (prompt) t))
               ((symbol-function 'yes-or-no-p) (lambda (prompt) t)))
      (apply old-fun args)))

  (advice-add #'async-shell-command :around #'auto-yes)

  (add-to-list 'display-buffer-alist '("*Async Shell Command*" display-buffer-no-window (nil)))

  (use-package auto-revert-mode
    :hook (after-init-hook . global-auto-revert-mode)
    :config
    (setopt auto-revert-interval 1))

  (use-package which-func :hook (after-init-hook . which-function-mode))

  (use-package recentf
    :config
    (recentf-mode t)
    (setq recentf-max-saved-items 150)
    (setq recentf-auto-cleanup 'never)
    (setq recentf-exclude '("/recentf"
   			  "COMMIT_EDITMSG"
   			  "/.?TAGS"
   			  "^/sudo:"
   			  "/\\.emacs\\.d/games/*-scores"
   			  "/\\.emacs\\.d/\\.tmp/")))

  (setq create-lockfiles nil)

  (setq backup-directory-alist '((".*" . "~/.tmp")))

  (setq auto-save-file-name-transforms '((".*" "~/.tmp/" t)))
  (setq auto-save-list-file-prefix nil)
  (setq auto-save-default nil)

  (use-package all-the-icons :ensure t)

  (use-package all-the-icons-dired
    :after dired all-the-icons
    :ensure t
    :hook
    (dired-mode . all-the-icons-dired-mode))



  (global-display-line-numbers-mode t)

  (with-delayed-execution
    (custom-set-variables '(display-line-numbers-width-start t))
    (defalias 'linum-mode 'display-line-numbers-mode))



  (use-package lambda-line
    :load-path "~/.emacs.d/site-lisp/lambda-line"
    :hook ((prog-mode-hook . lambda-line-mode)
           (text-mode-hook . lambda-line-mode)
           (dired-mode-hook . lambda-line-mode))
    :config
    (setopt lambda-line-icon-time nil) ;; requires ClockFace font (see below)
    (setopt lambda-line-clockface-update-fontset "ClockFaceRect") ;; set clock icon
    (setopt lambda-line-abbrev t) ;; abbreviate major modes
    (setopt lambda-line-hspace "  ")  ;; add some cushion
    (setopt lambda-line-prefix t) ;; use a prefix symbol
    (setopt lambda-line-prefix-padding nil) ;; no extra space for prefix 
    (setopt lambda-line-status-invert nil)  ;; no invert colors
    (setopt lambda-line-gui-ro-symbol  " [RO]")
    (setopt lambda-line-gui-mod-symbol " [M]")
    (setopt lambda-line-gui-rw-symbol  " [RW]")
    (setopt lambda-line-space-top +.30)  ;; padding on top and bottom of line
    (setopt lambda-line-space-bottom -.30)
    (setopt lambda-line-symbol-position 0.1))

  (use-package modus-themes
    :init
    (setq modus-themes-common-palette-overrides
          '((bg-main "#1a162c")
            (bg-dim "#141026")
            (bg-alt "#221c38")
            (bg-active "#2d2645")
            (bg-inactive "#16122a")
            (bg-hl-line "#261f3e")
            (bg-region "#322b4d")
            (bg-visual "#322b4d")
            (bg-visual-alt "#2a3550")
            (bg-paren-match "#3a3052")
            (fg-paren-match "#f6c7a1")
            (bg-search-current "#4a3a63")
            (bg-search-lazy "#35475a")
            (bg-search-replace "#4d3a33")
            (bg-completion "#241c36")
            (bg-completion-match-0 "#322b4d")
            (bg-completion-match-1 "#2c3756")
            (bg-completion-match-2 "#34414a")
            (bg-completion-match-3 "#422f4a")
            (bg-line-number-active "#31294a")
            (fg-line-number-active "#f9f6ff")
            (bg-line-number-inactive "#1a162c")
            (fg-line-number-inactive "#9f95b8")
            (bg-mode-line-active "#31294a")
            (fg-mode-line-active "#f9f6ff")
            (bg-mode-line-inactive "#221c38")
            (fg-mode-line-inactive "#c3b7d3")
            (border-mode-line-active "#f6c7a1")
            (border-mode-line-inactive "#2d2645")
            (bg-diff-added "#183c2c")
            (bg-diff-changed "#303a54")
            (bg-diff-removed "#412436")
            (fg-diff-added "#a6e7c9")
            (fg-diff-changed "#8bd4f6")
            (fg-diff-removed "#ff8fa3")
            (bg-prompt "#22182b")
            (fg-prompt "#f6c7a1")
            (fringe "#1a162c")
            (cursor "#f6c7a1")
            (fg-main "#f4f0ff")
            (fg-dim "#d8d0e7")
            (fg-alt "#f9e7ff")
            (comment "#a79dc6")
            (string "#b7e2aa")
            (keyword "#f6c7a1")
            (builtin "#c9b5ff")
            (constant "#f0c6ff")
            (function "#8bd4f6")
            (variable "#f4f0ff")
            (type "#9fe4c4")
            (number "#ffd08a")
            (warning "#ffd08a")
            (err "#ff8fa3")
            (info "#9fe4c4")
            (success "#a6e7c9")
            (link "#8bd4f6")
            (link-visited "#f0c6ff")
            (accent-0 "#c9b5ff")
            (accent-1 "#f6c7a1")
            (accent-2 "#9fe4c4")
            (accent-3 "#8bd4f6")
            (bg-tab-bar "#1a162c")
            (bg-tab-current "#31294a")
            (bg-tab-other "#221c38")))
    (setq modus-themes-vivendi-palette-overrides modus-themes-common-palette-overrides)
    :hook (after-init-hook . (lambda () (load-theme 'modus-vivendi t))))

  (use-package nerd-icons :ensure t)

  (use-package nerd-icons-corfu
    :after nerd-icons
    :ensure t
    :commands (nerd-icons-corfu-formatter)
    :init (with-eval-after-load 'corfu
    (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)))



  (with-delayed-execution
    (show-paren-mode t)
    (with-eval-after-load 'show-paren-mode
      (set-face-underline-p 'show-paren-match-face "#ffffff")
      (setq show-paren-delay 0)
      (setq show-paren-style 'expression)))

  (use-package rainbow-delimiters
    :ensure t
    :hook
    (prog-mode-hook . rainbow-delimiters-mode))



  (defconst my/cpp-modes '(c++-mode c++-ts-mode))

  (defun my/eglot-cpp-compile-command (file)
    (when-let* ((g++ (executable-find "g++")))
      `(:workingDirectory ,(file-name-directory file)
        :compilationCommand [,g++ "-std=c++20" "-c" ,file])))

  (defun my/eglot-cpp-compilation-database-changes (server)
    (let ((root (project-root (eglot--project server)))
          (changes (make-hash-table :test 'equal)))
      (dolist (buffer (buffer-list))
        (with-current-buffer buffer
          (when (and buffer-file-name
                     (memq major-mode my/cpp-modes)
                     (file-in-directory-p buffer-file-name root))
            (when-let* ((command (my/eglot-cpp-compile-command buffer-file-name)))
              (puthash buffer-file-name command changes)))))
      (unless (= (hash-table-count changes) 0)
        changes)))

  (defvar my/eglot-workspace-configuration-base nil)

  (defun my/eglot-workspace-configuration (server)
    (let* ((base (if (functionp my/eglot-workspace-configuration-base)
                     (funcall my/eglot-workspace-configuration-base server)
                   my/eglot-workspace-configuration-base))
           (changes (my/eglot-cpp-compilation-database-changes server)))
      (cond
       ((null changes) base)
       ((or (null base) (keywordp (car-safe base)))
        (plist-put (copy-sequence base) :compilationDatabaseChanges changes))
       ((consp (car-safe base))
        (setf (alist-get 'compilationDatabaseChanges base nil nil #'equal) changes)
        base)
       (t
        `(:compilationDatabaseChanges ,changes)))))

  (defun my/eglot-cpp-server (_)
    (let* ((g++ (executable-find "g++"))
           (args '("clangd"
                   "--background-index"
                   "--header-insertion=never"))
           (init `(:fallbackFlags ["-xc++" "-std=c++20"])))
      (when g++
        (setq args
              (append args
                      (list (concat "--query-driver=" g++))))
        (when-let* ((command (and buffer-file-name
                                 (my/eglot-cpp-compile-command buffer-file-name))))
          (setq init
                (plist-put init :compilationDatabaseChanges
                           (let ((changes (make-hash-table :test 'equal)))
                             (puthash buffer-file-name command changes)
                             changes)))))
      (append args
              (list :initializationOptions init))))

  (defun my/eglot-refresh-cpp-compilation-database ()
    (when (memq major-mode my/cpp-modes)
      (when-let* ((server (eglot-current-server)))
        (eglot-signal-didChangeConfiguration server))))

  (with-eval-after-load 'eglot
    (setq my/eglot-workspace-configuration-base eglot-workspace-configuration)
    (setopt eglot-workspace-configuration #'my/eglot-workspace-configuration)
    (add-to-list 'eglot-server-programs
                 '((c-mode c-ts-mode)
                   . ("clangd"
                      "--background-index"
                      "--header-insertion=never")))
    (add-to-list 'eglot-server-programs
                 '((c++-mode c++-ts-mode) . my/eglot-cpp-server))
    (add-hook 'eglot-managed-mode-hook #'my/eglot-refresh-cpp-compilation-database)
    (dolist (hook '(c-mode-hook c-ts-mode-hook c++-mode-hook c++-ts-mode-hook))
      (add-hook hook #'eglot-ensure)))

  (defun my/eglot-csharp-server (_)
    (or (when-let* ((cmd (executable-find "omnisharp")))
          (list cmd "-lsp"))
        (when-let* ((cmd (executable-find "OmniSharp")))
          (list cmd "-lsp"))
        (when-let* ((cmd (executable-find "csharp-ls")))
          (list cmd))))

  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((csharp-mode csharp-ts-mode) . my/eglot-csharp-server))
    (dolist (hook '(csharp-mode-hook csharp-ts-mode-hook))
      (add-hook hook #'eglot-ensure)))




  (defun my/eglot-ruby-server (_)
    (or (when-let* ((cmd (executable-find "ruby-lsp")))
          (list cmd))
        (when-let* ((cmd (executable-find "solargraph")))
          (list cmd "stdio"))))

  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((ruby-mode ruby-ts-mode) . my/eglot-ruby-server))
    (dolist (hook '(ruby-mode-hook ruby-ts-mode-hook))
      (add-hook hook #'eglot-ensure)))


  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs '(satysfi-mode . ("satysfi-language-server")))
    
    (add-hook 'satysfi-mode-hook #'eglot-ensure)
    )

  (defun project-root* ()
    (when-let* ((proj (project-current nil)))
      (project-root proj)))

  (defun project-has-file-p (&rest names)
    (when-let* ((root (project-root*)))
      (seq-some (lambda (f)
                  (file-exists-p (expand-file-name f root)))
                names)))

  (defun deno-project-p () (project-has-file-p "deno.json" "deno.jsonc"))
  (defun node-project-p () (project-has-file-p "package.json"))
  (defun bun-project-p  () (project-has-file-p "bun.lockb"))



  (defun es-server-program (_)
    (cond ((deno-project-p)
           '("deno" "lsp" :initializationOptions (:enable t :lint t)))
          ((or (node-project-p) (bun-project-p))
           '("typescript-language-server" "--stdio"))))



  (setopt treesit-language-source-alist
        '((astro "https://github.com/virchau13/tree-sitter-astro")
          (c "https://github.com/tree-sitter/tree-sitter-c")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
          (csharp "https://github.com/tree-sitter/tree-sitter-c-sharp")
          (moonbit "https://github.com/moonbitlang/tree-sitter-moonbit")
          (ruby "https://github.com/tree-sitter/tree-sitter-ruby")
          ))



  (use-package eldoc
    :hook ((emacs-lisp-mode-hook . turn-on-eldoc-mode)
           (lisp-interaction-mode-hook . turn-on-eldoc-mode)))

  (define-key lisp-interaction-mode-map (kbd "C-j") #'eval-print-last-sexp)

 


  (use-package csharp-mode
    :mode (("\\.cs$" . csharp-mode))
    :init
    (when (and (fboundp 'treesit-available-p)
               (treesit-available-p))
      (add-to-list 'major-mode-remap-alist
                   '(csharp-mode . csharp-ts-mode))))






  (use-package powershell
    :mode (("\\.ps1$" . powershell-mode))
    :ensure t)

  (use-package ruby-mode
    :mode (("\\.rb\\'" . ruby-mode)
           ("\\.rake\\'" . ruby-mode)
           ("\\.gemspec\\'" . ruby-mode)
           ("\\(?:Gem\\|Rake\\|Cap\\|Guard\\)file\\'" . ruby-mode)
           ("config\\.ru\\'" . ruby-mode))
    :init
    (when (and (fboundp 'treesit-available-p)
               (treesit-available-p)
               (fboundp 'treesit-language-available-p)
               (treesit-language-available-p 'ruby))
      (add-to-list 'major-mode-remap-alist
                   '(ruby-mode . ruby-ts-mode)))
    :config
    (setopt ruby-indent-level 2)
    (setopt ruby-insert-encoding-magic-comment nil))

  (use-package inf-ruby
    :ensure t
    :hook ((ruby-mode-hook . inf-ruby-minor-mode)
           (ruby-ts-mode-hook . inf-ruby-minor-mode)))



  (use-package markdown-mode
    :mode (("\\.md$" . gfm-mode)
           ("\\.markdown$" . gfm-mode))
    :ensure t
    :config
    (setq markdown-command "github-markup")
    (setq markdown-command-needs-filename t))


  (use-package org
    :config
    (setq org-directory "~/document/org")
    (setq org-startup-truncated nil)
    (setq org-enforce-todo-dependencies t)
    (setq org-support-shift-select t)
    (setq org-latex-default-class "bxjsarticle")
    (setq org-latex-pdf-process
        '("tectonic -Z shell-escape -Z continue-on-errors \
                    --synctex --outdir=%o %f"))
    (setq org-preview-latex-process-alist
      '((tectonic
         :programs ("tectonic" "dvisvgm")
         :image-input-type "xdv"
         :image-output-type "svg"
         :latex-compiler     ("tectonic --outfmt xdv --outdir %o %f")
         :image-converter     ("dvisvgm %f -n -b1 -c 1.15,1.15 -o %O"))))
    (setq org-preview-latex-default-process 'tectonic)
    (with-eval-after-load 'ox-latex
      (add-to-list 'org-latex-classes
                 '("bxjsarticle"
                   "\\documentclass[ja=standard,xelatex]{bxjsarticle}"
                   ("\\section{%s}"        . "\\section*{%s}")
                   ("\\subsection{%s}"     . "\\subsection*{%s}")
                   ("\\subsubsection{%s}"  . "\\subsubsection*{%s}")
                   ("\\paragraph{%s}"      . "\\paragraph*{%s}")
                   ("\\subparagraph{%s}"   . "\\subparagraph*{%s}")))))

  (use-package org-modern
    :ensure t
    :after org
    :hook
    (org-mode-hook . org-modern-mode)
    (org-agenda-finalize-hook . org-modern-agenda))

  (use-package org-roam
    :ensure t
    :after org
    :hook
    (org-roam-mode-hook . org-roam-ui-mode))

 ;; (use-package org-tempo :after org)



  (use-package yaml-mode
    :ensure t
    :hook (yaml-mode-hook . flycheck-mode)
    :init
    (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
    (add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode)))

  (use-package flymake-shellcheck
    :ensure t
    :init
    (add-hook 'sh-mode-hook #'flymake-shellcheck-load))

 

  (defun my/add-to-path (dir)
    (when (and (stringp dir)
               (file-directory-p dir))
      (let ((path-items (split-string (or (getenv "PATH") "") path-separator t)))
        (unless (member dir path-items)
          (setenv "PATH" (concat dir path-separator (or (getenv "PATH") "")))))
      (add-to-list 'exec-path dir)))

  ;; GUI launch (e.g. from Emacs.app) may miss system and Nix profile paths.
  (dolist (dir (list "/usr/bin"
                     "/bin"
                     "/usr/sbin"
                     "/sbin"
                     (expand-file-name "~/.nix-profile/bin")
                     (format "/etc/profiles/per-user/%s/bin" (user-login-name))
                     "/run/current-system/sw/bin"
                     "/nix/var/nix/profiles/default/bin"))
    (my/add-to-path dir))



  (use-package ace-window :ensure t)

  (use-package avy
    :ensure t
    :config
    (setq avy-all-windows nil)
    (setq avy-background t))

  (use-package aggressive-indent
    :ensure t
    :commands (global-aggressive-indent-mode)
    :hook (after-init-hook . (lambda ()
                               (run-with-idle-timer 1 nil #'global-aggressive-indent-mode))))

  (use-package cape
    :ensure t
    :init
    (add-to-list 'completion-at-point-functions #'cape-dabbrev)
    (add-to-list 'completion-at-point-functions #'cape-file)
    (add-to-list 'completion-at-point-functions #'cape-elisp-block)
    (add-to-list 'completion-at-point-functions #'cape-history))

  (use-package centaur-tabs
    :ensure t
    :commands (centaur-tabs-mode centaur-tabs-local-mode)
    :hook (after-init-hook . centaur-tabs-mode)
    :init
    (setq centaur-tabs-set-icons nil
          centaur-tabs-icon-type nil)
    :config
    (defun toggle-centaur-tabs-local-mode()
      (interactive)
      (call-interactively 'centaur-tabs-local-mode)
      (call-interactively 'centaur-tabs-local-mode))
    (defun my/centaur-tabs-buffer-directory ()
      (cond
       (buffer-file-name
        (file-name-directory (expand-file-name buffer-file-name)))
       ((and default-directory
             (file-directory-p default-directory))
        (file-name-as-directory (expand-file-name default-directory)))))

    (defun my/centaur-tabs-project-root (dir)
      (let ((default-directory dir))
        (or (when (fboundp 'projectile-project-root)
              (ignore-errors (projectile-project-root)))
            (when (require 'project nil t)
              (when-let* ((project (project-current nil)))
                (project-root project))))))

    (defun my/centaur-tabs-project-group-name ()
      (let* ((dir (my/centaur-tabs-buffer-directory))
             (root (and dir (my/centaur-tabs-project-root dir))))
        (cond
         (root
          (file-name-nondirectory (directory-file-name root)))
         (dir
          (abbreviate-file-name (directory-file-name dir)))
         (t
          "Emacs"))))

    (defun my/centaur-tabs-low-priority-output-buffer-p ()
      (let ((case-fold-search t)
            (name (buffer-name)))
        (or (string-prefix-p " " name)
            (string-match-p
             "\\(?:stderr\\|stdout\\|Async Shell Command\\)"
             name))))

    (defun my/centaur-tabs-buffer-groups ()
      (list (if (my/centaur-tabs-low-priority-output-buffer-p)
                "Output"
              (my/centaur-tabs-project-group-name))))

    (setq centaur-tabs-buffer-groups-function #'my/centaur-tabs-buffer-groups)
    (centaur-tabs-headline-match)
    (centaur-tabs-enable-buffer-reordering)
    (centaur-tabs-change-fonts "arial" 90)
    (setopt centaur-tabs-height 30)
    (setopt centaur-tabs-hide-tabs-hooks nil)
    (setopt centaur-tabs-set-bar 'under)
    (setopt x-underline-at-descent-line t)
    (setopt centaur-tabs-style "box")
    (setopt centaur-tabs-set-modified-marker t)
    (setopt centaur-tabs-show-navigation-buttons t)
    (setopt centaur-tabs-adjust-buffer-order t)
    (setopt centaur-tabs-cycle-scope 'groups)
    (run-with-idle-timer
     1 nil
     (lambda ()
       (when (require 'all-the-icons nil t)
         (setq centaur-tabs-set-icons t
               centaur-tabs-icon-type 'all-the-icons)
         (force-window-update t)))))

  (use-package consult :ensure t)

  (use-package corfu
    :ensure t
    :commands (global-corfu-mode corfu-mode)
    :hook (after-init-hook . global-corfu-mode)
    :config
    (setopt corfu-auto t)
    (setopt corfu-auto-delay 0.1)
    (setopt corfu-cycle t)
    (setopt corfu-on-exact-match nil)
    (setopt tab-always-indent 'complete))

  (defvar dashboard-recover-layout-p nil
    "Whether recovers the layout.")

  (defun dashboard-goto-recent-files ()
    "Go to recent files."
    (interactive)
    (dashboard--goto-section-by-index 2))

  (defun open-dashboard ()
    "Open the *dashboard* buffer and jump to the first widget."
    (interactive)
    (setq dashboard-recover-layout-p t)
    ;; Display dashboard in maximized window
    (delete-other-windows)
    ;; Refresh dashboard buffer
    (dashboard-open)
    ;; Jump to the first section
    (dashboard-goto-recent-files))

  (defun quit-dashboard ()
    "Quit dashboard window."
    (interactive)
    (quit-window t)
    (and dashboard-recover-layout-p
         (and (bound-and-true-p winner-mode) (winner-undo))
         (setq dashboard-recover-layout-p nil)))

  (use-package projectile
    :ensure t
    :config
    (projectile-mode t))

  (with-eval-after-load 'dashboard-widgets
    (defun my/dashboard-remote-file-p (file)
      (and (stringp file)
           (string-match-p "\\`/[^/|:]+:" file)))

    (defun my/dashboard-local-file-p (file)
      (not (my/dashboard-remote-file-p file)))

    (defun my/dashboard-insert-local-recents (orig-fun list-size)
      (let ((recentf-list (cl-remove-if-not #'my/dashboard-local-file-p recentf-list)))
        (funcall orig-fun list-size)))

    (defun my/dashboard-bookmark-filename (name)
      (cdr (assq 'filename (cdr (assoc name bookmark-alist)))))

    (defun my/dashboard-format-bookmark (name)
      (let ((path (my/dashboard-bookmark-filename name)))
        (if path
            (format dashboard-bookmarks-item-format
                    name
                    (if (my/dashboard-remote-file-p path)
                        path
                      (abbreviate-file-name path)))
          name)))

    (defun my/dashboard-insert-bookmarks (list-size)
      (require 'bookmark)
      (bookmark-maybe-load-default-file)
      (let ((dashboard-set-file-icons nil))
        (dashboard-insert-section
         "Bookmarks:"
         (dashboard-subseq (bookmark-all-names) list-size)
         list-size
         'bookmarks
         (dashboard-get-shortcut 'bookmarks)
         `(lambda (&rest _) (bookmark-jump ,el))
         (my/dashboard-format-bookmark el))))

    (advice-add #'dashboard-insert-recents :around #'my/dashboard-insert-local-recents)
    (advice-add #'dashboard-insert-bookmarks :override #'my/dashboard-insert-bookmarks))

  (use-package dashboard
    :ensure t
    :hook (after-init-hook . open-dashboard)
    :config
    (setq dashboard-items '((bookmarks . 5)
                            (recents  . 5)
                            (projects . 5)))
    (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*")))
    (setq dashboard-center-content t)
    (setq dashboard-set-heading-icons t)
    (setq dashboard-set-file-icons t)
    (setq dashboard-banner-logo-title "NEWGAMACS!")
    (setq dashboard-footer-messages '("「今日も一日がんばるぞい！」 - 涼風青葉"
                                      "「なんだかホントに入社した気分です！」 - 涼風青葉"
                                      "「そしてそのバグの程度で実力も知れるわけです」- 阿波根うみこ"
                                      "「えーー！なるっちの担当箇所がバグだらけ！？」 - 桜ねね"
                                      "「C++ を完全に理解してしまったかもしれない」 - 桜ねね"
                                      "「これでもデバッグはプロ級だし 今はプログラムの知識だってあるんだからまかせてよね！」 - 桜ねね"))
    (setq dashboard-startup-banner (if (or (eq window-system 'x) (eq window-system 'ns) (eq window-system 'w32)) "~/.config/emacs/assets/banner.png" "~/.config/emacs/assets/banner.txt"))
    (dashboard-setup-startup-hook)
    (define-key dashboard-mode-map (kbd "<f3>") #'quit-dashboard)
    (define-key dashboard-mode-map (kbd "p") #'previous-line)
    (define-key dashboard-mode-map (kbd "n") #'next-line)
    (define-key dashboard-mode-map (kbd "b") #'backward-char)
    (define-key dashboard-mode-map (kbd "f") #'forward-char))

  (with-eval-after-load 'dired
    (setq dired-recursive-copies 'always)
    (put 'dired-find-alternate-file 'disabled nil)
    (define-key dired-mode-map (kbd "RET") #'dired-open-in-accordance-with-situation)
    (define-key dired-mode-map (kbd "<left>") #'dired-up-directory)
    (define-key dired-mode-map (kbd "<right>") #'dired-open-in-accordance-with-situation))




  (defun dired-open-in-accordance-with-situation ()
    (interactive)
    (let ((file (dired-get-filename)))
      (if (file-directory-p file)
          (dired-find-alternate-file)
        (dired-find-file))))

  (use-package dired-toggle-sudo :ensure t)

  (use-package dirvish
    :ensure t
    :after nerd-icons
    :hook (after-init-hook . dirvish-override-dired-mode)
    :config
    (dirvish-override-dired-mode)
    (setq dirvish-preview-dispatchers (cl-substitute 'pdf-preface 'pdf dirvish-preview-dispatchers))
    (setq dirvish-attributes '(vc-state subtree-state nerd-icons collapse git-msg file-time file-size))
    (setq dirvish-subtree-state-style 'nerd)
    (setq dirvish-path-separators (list
                                   (format "  %s " (nerd-icons-codicon "nf-cod-home"))
                                   (format "  %s " (nerd-icons-codicon "nf-cod-root_folder"))
                                   (format " %s " (nerd-icons-faicon "nf-fa-angle_right")))))

  (use-package dumb-jump
    :ensure t
    :config
    (setq dumb-jump-force-searcher 'rg))

  (use-package editorconfig
    :ensure t
    :hook (after-init-hook . (lambda ()
                               (run-with-idle-timer 1 nil #'editorconfig-mode))))

  (use-package embark :ensure t)

  (use-package embark-consult
    :ensure t
    :hook (embark-collect-mode . consult-preview-at-point-mode))

  (use-package flycheck
    :ensure t
    :hook (prog-mode-hook . flycheck-mode)
    :config
    (setopt flycheck-idle-change-delay 0))

  (use-package gcmh
    :ensure t
    :hook (after-init-hook . gcmh-mode)
    :config
    (setopt gcmh-verbose t))

  (use-package hydra :ensure t)

  (use-package marginalia
    :ensure t
    :hook (window-startup-hook . marginalia-mode))

  (use-package multiple-cursors :ensure t)

  (use-package mwim :ensure t)



  (use-package puni
    :ensure t
    :hook ((after-init-hook . puni-global-mode)
           (lisp-mode-hook . puni-disable-puni-mode)
           (emacs-lisp-mode-hook . puni-disable-puni-mode)
           (lisp-interaction-mode-hook . puni-disable-puni-mode)))

  (use-package posframe :ensure t)

  (use-package smart-hungry-delete :ensure t)

  (use-package smart-newline :ensure t)

  (use-package sublimity
    :ensure t
    :config
    (sublimity-mode t))

  (use-package sublimity-attractive
    :after sublimity
    :config
    (setopt sublimity-attractive-centering-width 200))

  (use-package sublimity-scroll
    :after sublimity
    :config
    (setopt sublimity-scroll-weight 15)
    (setopt sublimity-scroll-drift-length 10))

  (use-package undo-fu :ensure t)

  (use-package vertico
    :ensure t
    :hook (after-init-hook . vertico-mode))

  (use-package vertico-posframe
    :commands (vertico-posframe-mode)
    :ensure t
    :hook (vertico-mode . vertico-posframe-mode))

  (use-package visual-regexp :ensure t)

  (use-package which-key
    :ensure t
    :hook (after-init-hook . which-key-mode))

  (use-package which-key-posframe
    :ensure t
    :hook (which-key-mode . which-key-posframe-mode))

  (use-package yasnippet
    :ensure t
    :config
    (yas-global-mode t)
    (setopt yas-snippet-dirs '("~/.config/emacs/snippets")))
  (use-package consult-yasnippet
    :ensure t
    :after (consult yasnippet))




  (use-package magit
    :ensure t
    :commands (global-git-commit-mode)
    :hook (magit-status-mode-hook . toggle-centaur-tabs-local-mode)
    :config
    (setopt magit-repository-directories '(("~/ghq/" . 3))))


  (use-package forge
    :ensure t
    :after magit)

  (provide 'init)

  ;; End:
  ;;; init.el ends here

