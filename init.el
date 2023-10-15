(pixel-scroll-precision-mode)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode t)

(setq backup-directory-alist `(("." . ,(expand-file-name ".tmp/backups/"
                                                         user-emacs-directory))))

;; TODOs
;; org-roam
;; better elfeed ui
;; integrate gmail into mu4e

(setq load-prefer-newer t)
(setq line-number-mode t)

(setq scroll-margin 0)
(setq auto-window-vscroll nil)
(setq scroll-preserve-screen-position 1)
(setq scroll-conservatively most-positive-fixnum)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
(setq mouse-wheel-progressive-speed nil)
(setq mouse-wheel-follow-mouse t)

;; (add-to-list 'package-archives '(("melpa" . "https://melpa.org/packages/")
;; 				 ("melpa-stable" . "https://stale.melpa.org/packages/")))
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(add-to-list 'package-pinned-packages '(telega . "melpa-stable"))

(defun garbage-collect-defer ()
  "Defer garbage collection."
  (setq gc-cons-threshold most-positive-fixnum
	gc-cons-percentage 0.6))

(defun garbage-collect-restore ()
  "Return garbage collection to normal parameters."
  (setq gc-cons-threshold (* 100 1024 1024)
        gc-cons-percentage 0.2))

(garbage-collect-defer)
(add-hook 'emacs-startup-hook #'garbage-collect-restore)

(use-package emacs
  :config
  (load-theme 'modus-vivendi))

(use-package default-text-scale
  :ensure t
  :defer t
  :bind
  (("C--" . default-text-scale-decrease)
   ("C-=" . default-text-scale-increase)))

(use-package tramp
  :config
  (let ((backup-dir (concat user-emacs-directory "backups"))
        (auto-saves-dir (concat user-emacs-directory "auto-saves")))
    (dolist (dir (list backup-dir auto-saves-dir))
      (when (not (file-directory-p dir))
        (make-directory dir t)))
    (setq backup-directory-alist `(("" . ,backup-dir))
          tramp-backup-directory-alist `(("" . ,backup-dir))
          auto-save-list-file-prefix (concat auto-saves-dir "/saves-")
          tramp-auto-save-directory auto-saves-dir))

  (setq backup-by-copying t)
  (setq delete-old-versions t)
  (setq version-control t)
  (setq kept-new-versions 5)
  (setq kept-old-versions 2)
  )

(setq treesit-language-source-alist
      '((cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (c "https://github.com/tree-sitter/tree-sitter-c")))

(dolist (lang treesit-language-source-alist)
  (unless (treesit-language-available-p (car lang))
    (treesit-install-language-grammar (car lang))))

(use-package emacs
  :config
  (setq major-mode-remap-alist
        '((yaml-mode . yaml-ts-mode)
          (bash-mode . bash-ts-mode)
	  (c++-mode . c++-ts-mode)
          (js2-mode . js-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (json-mode . json-ts-mode)
          (css-mode . css-ts-mode)
          (python-mode . python-ts-mode)))
  :hook
  ((prog-mode . electric-pair-mode)))

(use-package which-key
  :ensure t
  :config
  (which-key-mode))

(setq evil-want-C-u-scroll t)

(use-package evil
  :ensure t
  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode)
  (evil-set-initial-state 'vterm-mode 'emacs))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :defer t
  :hook
  (after-init-hool . global-evil-surround-mode))

(use-package avy
  :ensure t
  :demand t
  :bind (("C-c j" . avy-goto-line)
	 ("C-c '" . avy-goto-char-2)
	 ("s-j" . avy-goto-char-timer)))

(use-package consult
  :ensure t
  :bind (("C-x b" . consult-buffer)
	 ("M-y" . consult-yank-pop)
	 ("M-s r" . consult-ripgrep)
	 ("C-s" . consult-line))
  :config
  (setq consult-narrow-key "<"))

(use-package embark
  :ensure t
  :demand t
  :after avy
  :bind (("C-c a" . embark-act))
  :init
  (defun ld/avy-action-embark (pt)
    (unwind-protect
	(save-excursion
	  (goto-char pt)
	  (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  (setf (alist-get ?. avy-dispatch-alist) 'ld/avy-action-embark))

(use-package embark-consult
  :ensure t)

(use-package paren
  :defer t
  :init
  (show-paren-mode 1)
  :custom-face
  (show-paren-match ((t (:weight extra-bold
				 :underline t))))
  :config
  (setq show-paren-style 'parentheses)
  (setq show-paren-delay 0.00001))

(use-package rainbow-mode
  :if window-system
  :ensure t
  :defer t
  :hook
  (prog-mode-hook . rainbow-mode))

(use-package rainbow-delimiters
  :ensure t
  :defer t
  :hook
  (prog-mode-hook . rainbow-delimiters-mode))

(require 'server)
(unless (server-running-p)
  (server-start))

(use-package ivy
  :ensure t
  :defer t
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-height 15)
  (evil-define-key 'insert ivy-minibuffer-map
    (kbd "M-l") 'ivy-backward-delete-char
    (kbd "M-j") 'ivy-next-line
    (kbd "M-k") 'ivy-previous-line
    (kbd "M-l") 'ivy-alt-done)
  (evil-define-key '(normal insert) ivy-switch-buffer-map
    (kbd "M-j") 'ivy-next-line
    (kbd "M-k") 'ivy-previous-line
    (kbd "M-l") 'ivy-done
    (kbd "C-d") 'ivy-switch-buffer-kill)
  :bind
  ("C-s" . swiper-isearch)
  :hook
  (after-init-hook . ivy-mode))

(use-package counsel
  :ensure t
  :defer t
  :hook
  (after-init-hook . counsel-mode))

(use-package ivy-rich
  :ensure t
  :defer t
  :config
  ;; Increase C-x b performance
  (setq ivy-rich-project-root-cache-mode t)
  :hook
  (after-init-hook . ivy-rich-mode))

(use-package smex
  :after counsel
  :ensure t
  :defer t)

;;(use-package company
;;  :ensure t
;;  :defer t
;;  :config
;;
;;  (setq company-idle-delay 0.2)
;;  (setq company-minimum-prefix-length 1)
;;
;;  :bind (:map company-mode-map
;;              ("M-/" . company-manual-begin)
;;              :map company-active-map
;;              (("<tab>" . company-complete-common-or-cycle)
;;               ("S-TAB"  . company-select-previous)
;;               ("<backtab>" . company-select-previous)
;;               ("<return>" . company-complete)))
;;  :hook
;;  (after-init-hook . global-company-mode))
;;
;;(use-package company-box
;;  :after (company all-the-icons)
;;  :config
;;  (setq company-box-show-single-candidate t
;;        company-box-backends-colors       nil
;;        company-box-max-candidates        50
;;        company-box-icons-alist           'company-box-icons-all-the-icons
;;        company-box-icons-all-the-icons
;;        (let ((all-the-icons-scale-factor 0.8))
;;          `(
;;            <<gen-company-box-icons()>>))))

(use-package vertico
  :ensure t
  :init
  ;; You'll want to make sure that e.g. fido-mode isn't enabled
  (vertico-mode))

(use-package vertico-directory
  :after vertico
  :bind (:map vertico-map
              ("M-DEL" . vertico-directory-delete-word)))

;; Marginalia: annotations for minibuffer
(use-package marginalia
  :ensure t
  :config
  (marginalia-mode))

;; Popup completion-at-point
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :bind
  (:map corfu-map
        ("SPC" . corfu-insert-separator)
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous)))

;; Part of corfu
(use-package corfu-popupinfo
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(0.25 . 0.1))
  (corfu-popupinfo-hide nil)
  :config
  (corfu-popupinfo-mode))

;; Make corfu popup come up in terminal overlay
(use-package corfu-terminal
  :if (not (display-graphic-p))
  :ensure t
  :config
  (corfu-terminal-mode))

;; Pretty icons for corfu
(use-package kind-icon
  :if (display-graphic-p)
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package eshell
  :bind (("C-r" . consult-history)))

(use-package magit
  :ensure t
  :bind (("C-c g" . magit-status)))

(use-package eglot
  ;; no :ensure t here because it's built-in

  ;; Configure hooks to automatically turn-on eglot for selected modes
  ; :hook
  ; (((python-mode ruby-mode elixir-mode) . eglot))
  :bind
  (("C-c c a" . eglot-code-actions))

  :custom
  (eglot-send-changes-idle-time 0.1)

  :config
  (fset #'jsonrpc--log-event #'ignore)  ; massive perf boost---don't log every event
  ;; Sometimes you need to tell Eglot where to find the language server
  ; (add-to-list 'eglot-server-programs
  ;              '(haskell-mode . ("haskell-language-server-wrapper" "--lsp")))
  )

;; Orderless: powerful completion style
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless)))

(use-package elfeed
  :ensure t)

(setq elfeed-feeds
      '(("https://lemire.me/blog/feed" code blog)
	("http://nullprogram.com/feed/" code blog)
	("https://old.reddit.com/r/rust" code)

	;; Emacs
	("https://planet.emacslife.com/atom.xml" blog emacs)
	("http://www.masteringemacs.org/feed" blog emacs)
	("https://old.reddit.com/r/emacs" emacs)

	;; News feeds
	("https://hnrss.org/frontpage" news)
	;; ("https://feeds.nos.nl/nosnieuwsalgemeen" news)

	;; F1
	;; ("https://old.reddit.com/r/formula1.rss" news f1)
	("https://old.reddit.com/r/f1technical.rss" f1)))

(use-package ace-window
  :ensure t
  :bind (:map global-map
	      ("M-o" . ace-window)))

(use-package browse-kill-ring
  :ensure t)

(setq org-directory "~/Documents/org/")
(setq org-agenda-files '("inbox.org" "work.org"))
(setq org-tag-alist '(
		      (:startgroup)
		      ("home" . ?h)
		      ("work". ?w)
		      (:endgroup)
		      (:newline)
		      (:startgroup)
		      ("one-shot" . ?o)
		      ("project" . ?j)
		      ("tiny" . ?t)
		      (:endgroup)))
(setq org-refile-targets 'FIXME)

(use-package org
  :hook ((org-mode . visual-line-mode)
	 (org-mode . flyspell-mode))

  :bind (:map global-map
	      ("C-c l s" . org-store-link)
	      ("C-c l i" . org-insert-link-global))

  :config
  (require 'oc-csl)
  (add-to-list 'org-export-backends 'md)

  (setf (cdr (assoc 'file org-link-frame-setup)) 'find-file)

  (setq org-export-with-smart-quotes t)

  ;; Instead of just two states (TODO, DONE) we set up a few different states
  ;; that a task can be in.
  (setq org-todo-keywords
        '((sequence "TODO(t)" "WAITING(w@/!)" "STARTED(s!)" "|" "DONE(d!)" "OBSOLETE(o@)")))

  ;; Refile configuration
  (setq org-outline-path-complete-in-steps nil)
  (setq org-refile-use-outline-path 'file)

  (setq org-capture-templates
        '(("c" "Default Capture" entry (file "inbox.org")
           "* TODO %?\n%U\n%i")
          ;; Capture and keep an org-link to the thing we're currently working with
          ("r" "Capture with Reference" entry (file "inbox.org")
           "* TODO %?\n%U\n%i\n%a")
          ;; Define a section
          ("w" "Work")
          ("wm" "Work meeting" entry (file+headline "work.org" "Meetings")
           "** TODO %?\n%U\n%i\n%a")
          ("wr" "Work report" entry (file+headline "work.org" "Reports")
           "** TODO %?\n%U\n%i\n%a")))

    (setq org-agenda-custom-commands
          '(("n" "Agenda and All Todos"
             ((agenda)
              (todo)))
            ("w" "Work" agenda ""
             ((org-agenda-files '("work.org")))))))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/org/roam/")))

(use-package smartparens
  :ensure t
  ;; :straight (smartparens :build t
  ;;                        :type git
  ;;                        :host github
  ;;                        :repo "Fuco1/smartparens")
  :hook (prog-mode . smartparens-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(elfeed-feeds '("https://lemire.me/blog/feed"))
 '(package-selected-packages
   '(smartparens org-roam default-text-scale browse-kill-ring eglot ace-window rainbow-identifiers visual-fill-column elfeed rust-mode company-box orderless kind-icon corfu-terminal corfu marginalia vertico which-key smex rainbow-mode rainbow-delimiters ivy-rich evil-surround evil-collection embark-consult counsel company avy))
 '(warning-suppress-types '((comp) (comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
