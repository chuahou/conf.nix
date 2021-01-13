;; enable local evil mode
(setq evil-want-C-i-jump nil) ;; <C-i> prevents <TAB> from working in terminal
(require 'evil)
(evil-mode 1)
(define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
(define-key evil-visual-state-map (kbd "C-u") 'evil-scroll-up)

;; org-mode settings
(require 'org)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c j") 'org-next-link)
(global-set-key (kbd "C-c k") 'org-previous-link)
(global-set-key (kbd "C-c h")
                (lambda () (interactive)(find-file "~/org/index.org")))
(global-set-key (kbd "C-c 0")
                (lambda () (interactive)(find-file "~/org/index.org")))
(global-set-key (kbd "C-c 1")
                (lambda () (interactive)(find-file "~/org/acad.org")))
(global-set-key (kbd "C-c 2")
                (lambda () (interactive)(find-file "~/org/main.org")))
(global-set-key (kbd "C-c 3")
                (lambda () (interactive)(find-file "~/org/universe.org")))
(global-set-key (kbd "C-c 4")
                (lambda () (interactive)(find-file "~/org/zz_archive.org")))
(setq org-agenda-files '("~/org/" "~/org/gcal/"))
(setq org-todo-keywords
      '((sequence "HOLD" "KIV?" "TODO" "NEXT" "|" "DONE")))
(setq org-todo-keyword-faces
      '(("HOLD" . (:foreground "yellow"))
        ("KIV?" . (:foreground "yellow"))
        ("TODO" . (:foreground "red"       :weight bold))
        ("NEXT" . (:foreground "brightred" :weight bold :underline t))
        ("DONE" . (:foreground "green"     :weight bold))))
(setq org-fontify-done-headline t)
(setq org-link-frame-setup '((file . find-file)))
(setq org-agenda-span 14)
(setq org-agenda-start-on-weekday nil)
(setq org-agenda-time-grid
      '((weekly today remove-match)
        (800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000 2100 2200)
        "......" "----------------"))
(setq org-log-done 'time)
(setq safe-local-variable-values '((eval org-content 2)))
(setq org-startup-indented t)
(setq org-loop-over-headlines-in-active-region t)

;; evil-org
(require 'evil-org)
(add-hook 'org-mode-hook 'evil-org-mode)
(evil-org-set-key-theme '(navigation insert textobjects additional calendar))
(require 'evil-org-agenda)
(evil-org-agenda-set-keys)
(evil-define-key 'motion org-agenda-mode-map
                 (kbd "C-u") 'evil-scroll-up)

;; other settings
(menu-bar-mode -1)                  ;; remove menu bar
(xterm-mouse-mode 1)                ;; set mouse mode
(setq-default mode-line-format nil) ;; remove statusline
(global-set-key (kbd "<mouse-4>") 'scroll-down-line)
(global-set-key (kbd "<mouse-5>") 'scroll-up-line)

;; disable autosave/backup files
(setq auto-save-default nil)
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

;; customize colours
(set-face-foreground 'calendar-month-header     "magenta")
(set-face-foreground 'calendar-weekday-header   "blue")
(set-face-foreground 'calendar-weekend-header   "red")
(set-face-foreground 'link                      "cyan")
(set-face-foreground 'minibuffer-prompt         "brightred")
(set-face-foreground 'org-agenda-calendar-event "blue")
(set-face-foreground 'org-agenda-current-time   "yellow")
(set-face-foreground 'org-agenda-date           "brightblue")
(set-face-foreground 'org-agenda-done           "white")
(set-face-foreground 'org-agenda-structure      "magenta")
(set-face-foreground 'org-date                  "white")
(set-face-foreground 'org-headline-done         "white")
(set-face-foreground 'org-hide                  "brightblack")
(set-face-foreground 'org-level-1               "brightblue")
(set-face-foreground 'org-level-2               "blue")
(set-face-foreground 'org-level-3               "color-66")
(set-face-foreground 'org-level-4               "color-66")
(set-face-foreground 'org-link                  "cyan")
(set-face-foreground 'org-meta-line             "red")
(set-face-foreground 'org-scheduled             'unspecified)
(set-face-foreground 'org-scheduled-today       'unspecified)
(set-face-foreground 'org-scheduled-previously  "brightred")
(set-face-foreground 'org-special-keyword       "brightwhite")
(set-face-foreground 'org-time-grid             "white")
(set-face-foreground 'org-upcoming-deadline     "brightred")
(set-face-foreground 'org-verbatim              "white")
(set-face-foreground 'org-warning               "brightred")
(set-face-foreground 'region                    "brightwhite")
(set-face-background 'region                    "brightblack")
