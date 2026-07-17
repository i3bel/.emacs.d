;;; init-org.el --- Org-mode config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Lots of stuff from http://doc.norang.ca/org-mode.html
(setup org
  (:idle)
  (keymap-global-set "C-c L"       'org-store-link)
  (keymap-global-set "C-c C-o"     'org-open-at-point)
  (keymap-global-set "C-M-<up>"    'org-up-element)
  ;; 一般这个函数都是在 org 启动后调用，如果 org 没有启动则会报错。
  ;; Wrong type argument: commandp, dired-copy-images-links
  (keymap-global-set "C-c n m"     'dired-copy-images-links)
  (keymap-global-set "C-c b"       'org-cite-insert)
  (:idle org-agenda org-habit org-clock ob-core)
  (:when-loaded
  (:also-load lib-org)
  

  
  (setopt org-directory ORG-PATH
          org-image-actual-width nil
          org-src-content-indentation 0
          org-goto-interface 'outline-path-completion
          org-log-done 'time
          org-edit-timestamp-down-means-later t
          org-hide-emphasis-markers t
          org-fold-catch-invisible-edits 'show
          org-export-coding-system 'utf-8
          org-fast-tag-selection-single-key 'expert
          org-tags-column 80
          org-todo-keywords
          '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
            (sequence "PROJECT(p)" "|" "DONE(d!/!)" "CANCELLED(c/!)")
            (sequence "WAITING(w/!)" "DELEGATED(e!)" "HOLD(h)" "|" "CANCELLED(c/!)"))
          org-todo-repeat-to-state "NEXT"
          org-todo-keyword-faces
          '(("NEXT" :inherit warning)
            ("PROJECT" :inherit font-lock-string-face)))
    ;; emphasis
    (setq org-emphasis-regexp-components '("-[:space:]('\"{[:nonascii:]"
                                           "-[:space:].,:!?;'\")}\\[[:nonascii:]"
                                           "[:space:]"
                                           "."
                                           1)
          org-match-substring-regexp (concat
                                      "\\([0-9a-zA-Zα-γΑ-Ω]\\)\\([_^]\\)\\("
                                      "\\(?:" (org-create-multibrace-regexp "{" "}" org-match-sexp-depth) "\\)"
                                      "\\|"
                                      "\\(?:" (org-create-multibrace-regexp "(" ")" org-match-sexp-depth) "\\)"
                                      "\\|"
                                      "\\(?:\\*\\|[+-]?[[:alnum:].,\\]*[[:alnum:]]\\)\\)")
          )
    (:with-mode org-mode
      (:hook (lambda () (electric-pair-local-mode -1)))
      (:hook org-indent-mode)
      (:hook visual-line-mode)
      (:hook (lambda () (setq truncate-lines nil))))
    (:with-hook org-after-todo-state-change-hook
      (:hook log-todo-next-creation-date)
      (:hook org-copy-todo-to-today))
    (+org-emphasize-bindings)
    (org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)
    (org-element-update-syntax)))

(setup org-refile
  (:when-loaded
    (setopt org-refile-use-cache nil
            org-refile-targets '((nil :maxlevel . 5)
                                 (org-agenda-files :maxlevel . 5))
            ;; Allow refile to create parent tasks with confirmation
            org-refile-allow-creating-parent-nodes 'confirm
            ;; Targets start with the file name - allows creating level 1 tasks
            ;; org-refile-use-outline-path (quote file))
            org-refile-use-outline-path 'file
            org-outline-path-complete-in-steps nil
            ;; Exclude DONE state tasks from refile targets
            org-refile-target-verify-function
            (lambda ()
              (not (member
                    (nth 2 (org-heading-components))
                    org-done-keywords))))
    (:advice org-refile :after #'gtd-save-org-buffers)))

(setup org-archive
  (:when-loaded
    (:also-load lib-org-archive-hierachical)
    (setopt org-archive-mark-done nil
            org-archive-location "%s_archive::* Archive"
            org-archive-default-command 'org-archive-subtree-hierarchical)))

(setup org-clock
  (keymap-global-set "C-c o j" 'org-clock-goto)
  (keymap-global-set "C-c o l" 'org-clock-in-last)
  (keymap-global-set "C-c o i" 'org-clock-in)
  (keymap-global-set "C-c o o" 'org-clock-out)
  (:when-loaded
    (setopt org-clock-persist t
            org-clock-in-resume t
            ;; Save clock data and notes in the LOGBOOK drawer
            org-clock-into-drawer t
            ;; Save state changes in the LOGBOOK drawer
            org-log-into-drawer t
            ;; Removes clocked tasks with 0:00 duration
            org-clock-out-remove-zero-time-clocks t)
    (org-clock-persistence-insinuate)))

(setup ob-core
  (:when-loaded
    (:also-load ob-plantuml
                ob-python
                ob-latex
                )
    (setopt org-plantuml-jar-path
            (expand-file-name (concat ORG-PATH "/plantuml/plantuml.jar"))
            ;; 这里应该就是 .zshrc 里面配置的 python
            org-babel-python-command "python")
    (org-babel-do-load-languages
     'org-babel-load-languages '((plantuml . t)
                                 (python . t)
                                 (shell . t)
                                 (sql . t)
                                 (latex . t)))))

(setup denote
  (:idle)
  (:idle denote-journal)
  (:when-loaded
    (keymap-global-set "C-c n n" 'denote-open-or-create)
    (keymap-global-set "C-c n d" 'denote-sort-dired)
    (keymap-global-set "C-c n l" 'denote-link)
    (keymap-global-set "C-c n L" 'denote-add-links)
    (keymap-global-set "C-c n b" 'denote-backlinks)
    (keymap-global-set "C-c n r" 'denote-rename-file)
    (keymap-global-set "C-c n R" 'denote-rename-file-using-front-matter)
    (setopt denote-directory (expand-file-name "denote" ORG-PATH)
            denote-save-buffers nil
            denote-known-keywords '("emacs" "private")
            denote-infer-keywords t
            denote-sort-keywords t
            denote-prompts '(title file-type keywords)
            denote-excluded-directories-regexp nil
            denote-excluded-keywords-regexp nil
            denote-rename-confirmations '(rewrite-front-matter modify-file-name)
            denote-date-prompt-use-org-read-date t)
    (setq denote-org-front-matter
          "#+title:      %s
#+date:       %s
#+filetags:   %s
#+identifier: %s
#+signature:  %s
#+startup: indent
\n")
    (denote-rename-buffer-mode 1)))

(setup denote-journal
  (:when-loaded
    
    (setopt denote-journal-directory (expand-file-name "daily" denote-directory)
            denote-journal-title-format 'day-date-month-year)
    (keymap-global-set "C-c c" 'org-capture)
    (:with-feature org-capture
      (setq org-capture-templates
            '(("d" "Default           ||" entry
               (file+headline
                denote-journal-path-to-new-or-existing-entry
                get-today-heading)
               "%<%H:%M> %?\n" :kill-buffer t)
              ("p" "Prod              ||" entry
               (file+headline
                denote-journal-path-to-new-or-existing-entry
                get-today-heading)
               "%<%H:%M> %? :prod:\n" :kill-buffer t)
              ("t" "Tasks             || org-agenda" plain
               (file+olp
                denote-journal-path-to-new-or-existing-entry
                org-capture-heading-tasks)
               "*** TODO %?" :kill-buffer t)
              ("n" "Notes with source ||" entry
               (file+olp
                denote-journal-path-to-new-or-existing-entry
                org-capture-heading-notes)
               "** %?\n%U\n%a\n" :kill-buffer t)
              ("f" "Fleeting Notes    ||" entry
               (file+olp
                denote-journal-path-to-new-or-existing-entry
                org-capture-heading-notes)
               "** %?\n" :kill-buffer t)
              ("i" "Interesting Finds ||" entry
               (file+olp
                denote-journal-path-to-new-or-existing-entry
                org-capture-heading-finds)
               "** %?\n" :kill-buffer t)
              ("c" "Media Consumption || Book, Film, TV, Podcast etc." entry
               (file+olp
                denote-journal-path-to-new-or-existing-entry
                org-capture-heading-consume)
               "** %?\n" :kill-buffer t)
              
              ("a" "Tasks             || copying to journal" plain
               (file+olp
                denote-journal-path-to-new-or-existing-entry
                org-capture-heading-tasks)
               "" :kill-buffer t)))
      (:with-hook org-capture-before-finalize-hook
        (:hook org-sort-second-level-entries-by-time)))))



(setup org-agenda
  (keymap-global-set "C-c a" 'org-agenda)
  (:when-loaded
    (setopt
     org-agenda-sort-notime-is-late nil
     ;; 时间显示为两位数(9:30 -> 09:30)
     org-agenda-time-leading-zero t
     ;; 过滤掉 dynamic
     ;; org-agenda-hide-tags-regexp (regexp-opt '("dynamic"))
     org-agenda-files (file-expand-wildcards (concat ORG-PATH "/agenda/*.org"))
     org-agenda-compact-blocks t
     org-agenda-sticky t
     org-agenda-start-on-weekday nil
     org-agenda-span 'day
     org-agenda-include-diary nil
     org-agenda-current-time-string (concat "◀┈┈┈┈┈┈┈┈┈┈┈┈┈ ⏰")
     org-agenda-window-setup 'current-window
     org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3)
     org-agenda-custom-commands
     `(("N" "Notes" tags "NOTE"
        ((org-agenda-overriding-header "Notes")
         (org-tags-match-list-sublevels t)))
       ("g" "GTD"
        ((agenda "" nil)
         (tags-todo "-inbox"
                    ((org-agenda-overriding-header "Next Actions")
                     (org-agenda-tags-todo-honor-ignore-options t)
                     (org-agenda-todo-ignore-scheduled 'future)
                     (org-agenda-skip-function
                      (lambda ()
                        (or (org-agenda-skip-subtree-if 'todo '("HOLD" "WAITING"))
                            (org-agenda-skip-entry-if 'nottodo '("NEXT")))))
                     (org-tags-match-list-sublevels t)
                     (org-agenda-sorting-strategy
                      '(todo-state-down effort-up category-keep))))
         (tags-todo "-reading/PROJECT"
                    ((org-agenda-overriding-header "Project")
                     (org-agenda-prefix-format "%-11c%5(org-todo-age) ")
                     (org-tags-match-list-sublevels t)
                     (org-agenda-sorting-strategy
                      '(category-keep))))
         (tags-todo "+reading/PROJECT"
                    ((org-agenda-overriding-header "Reading")
                     (org-agenda-prefix-format "%-11c%5(org-todo-age) ")
                     (org-tags-match-list-sublevels t)
                     (org-agenda-sorting-strategy
                      '(category-keep))))
         (tags-todo "/WAITING"
                    ((org-agenda-overriding-header "Waiting")
                     (org-agenda-tags-todo-honor-ignore-options t)
                     (org-agenda-todo-ignore-scheduled 'future)
                     (org-agenda-sorting-strategy
                      '(category-keep))))
         (tags-todo "/DELEGATED"
                    ((org-agenda-overriding-header "Delegated")
                     (org-agenda-tags-todo-honor-ignore-options t)
                     (org-agenda-todo-ignore-scheduled 'future)
                     (org-agenda-sorting-strategy
                      '(category-keep))))
         (tags-todo "-inbox"
                    ((org-agenda-overriding-header "On Hold")
                     (org-agenda-skip-function
                      (lambda ()
                        (or (org-agenda-skip-subtree-if 'todo '("WAITING"))
                            (org-agenda-skip-entry-if 'nottodo '("HOLD")))))
                     (org-tags-match-list-sublevels nil)
                     (org-agenda-sorting-strategy
                      '(category-keep))))
         ))
       ("v" "Orphaned Tasks"
        ((agenda "" nil)
         (tags "inbox"
               ((org-agenda-overriding-header "Inbox")
                (org-agenda-prefix-format "%-11c%5(org-todo-age) ")
                (org-tags-match-list-sublevels nil)))
         (tags-todo "+book&-reading/PROJECT"
                    ((org-agenda-overriding-header "Book Plan")
                     (org-agenda-prefix-format "%-11c%5(org-todo-age) ")
                     (org-tags-match-list-sublevels t)
                     (org-agenda-sorting-strategy
                      '(category-keep))))
         (tags-todo "-inbox/-NEXT"
                    ((org-agenda-overriding-header "Orphaned Tasks")
                     (org-agenda-tags-todo-honor-ignore-options t)
                     (org-agenda-prefix-format "%-11c%5(org-todo-age) ")
                     (org-agenda-todo-ignore-scheduled 'future)
                     (org-agenda-skip-function
                      (lambda ()
                        (or (org-agenda-skip-subtree-if 'todo '("PROJECT" "HOLD" "WAITING" "DELEGATED"))
                            (org-agenda-skip-subtree-if 'nottododo '("TODO")))))
                     (org-tags-match-list-sublevels t)
                     (org-agenda-sorting-strategy
                      '(category-keep))))))))

    (:also-load lib-org-agenda)
    (add-to-list 'org-agenda-after-show-hook 'org-show-entry)
    ;; Re-align tags when window shape changes
    (:with-mode org-agenda-mode
      (lambda () (add-hook 'window-configuration-change-hook 'org-agenda-align-tags nil t)))))

(setup org-habit
  (:when-loaded
    (setopt org-habit-following-days 1
            org-habit-preceding-days 7
            org-habit-show-all-today t
            org-habit-graph-column 57
            org-habit-today-glyph ?○
            org-habit-completed-glyph ?●
            org-habit-show-done-always-green t)
    (:with-feature org-agenda
      (:also-load org-habit)
      (let ((agenda-sorting-strategy (assoc 'agenda org-agenda-sorting-strategy)))
        (setcdr agenda-sorting-strategy (remove 'habit-down (cdr agenda-sorting-strategy)))))))



(setup org-modern
  (:with-mode org-mode
      (:hook org-modern-mode)
      (:hook (lambda ()
               "Beautify Org Checkbox Symbol"
               (push '("[ ]" . "☐") prettify-symbols-alist)
               (push '("[X]" . "☑" ) prettify-symbols-alist)
               (push '("[-]" . #("□–" 0 2 (composition ((2))))) prettify-symbols-alist)
               (prettify-symbols-mode))))
  (:when-loaded
    (setopt org-modern-star 'replace
            org-modern-replace-stars "❑❍❑❍❑❍"
            org-modern-list '((?+ . "◦")
                              (?- . "•"))
            org-hide-emphasis-markers t
            org-tags-column 0
            org-modern-block-fringe 2
            org-fold-catch-invisible-edits 'show-and-error
            org-special-ctrl-a/e t
            org-insert-heading-respect-content t
            org-modern-table-vertical 0
            org-modern-table-horizontal 0.2
            org-modern-checkbox nil
            org-ellipsis "[+]")
    ;; 美化 checkbox，unchecked 和 checked 分别继承 TODO 的 TODO 和 DONE 的颜色。
    ;; https://emacs.stackexchange.com/questions/45291/change-color-of-org-mode-checkboxes
    (defface org-checkbox-todo-text
      '((t (:foreground unspecified :inherit org-todo)))
      "Face for the text part of an unchecked org-mode checkbox.")

    (defface org-checkbox-done-text
      '((t (:foreground unspecified :inherit org-done :strike-through t)))
      "Face for the text part of a checked org-mode checkbox.")

    (defface org-checkbox-partial-text
      '((t (:foreground unspecified :inherit org-todo)))
      "Face for the text part of a partially checked org-mode checkbox.")

    (font-lock-add-keywords
     'org-mode
     `(("^[ \t]*\\(?:[-+*]\\|[0-9]+[).]\\)[ \t]+\\(\\(?:\\[@\\(?:start:\\)?[0-9]+\\][ \t]*\\)?\\[ \\][^\n]*\n\\)"
        1 'org-checkbox-todo-text prepend)
       ("^[ \t]*\\(?:[-+*]\\|[0-9]+[).]\\)[ \t]+\\(\\(?:\\[@\\(?:start:\\)?[0-9]+\\][ \t]*\\)?\\[X\\][^\n]*\n\\)"
        1 'org-checkbox-done-text prepend)
       ("^[ \t]*\\(?:[-+*]\\|[0-9]+[).]\\)[ \t]+\\(\\(?:\\[@\\(?:start:\\)?[0-9]+\\][ \t]*\\)?\\[-\\][^\n]*\n\\)"
        1 'org-checkbox-partial-text prepend))
     'append)))


(provide 'init-org)
;;; init-org.el ends here
