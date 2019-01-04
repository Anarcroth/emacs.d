;; -*- lexical-binding: t -*-
(setq debug-on-error t)

;;; This file bootstraps the configuration, which is divided into
;;; a number of other files.

(let ((minver "24.4"))
  (when (version< emacs-version minver)
    (error "Your Emacs is too old -- this config requires v%s or higher" minver)))
(when (version< emacs-version "25.1")
  (message "Your Emacs is old, and some functionality in this config will be disabled. Please upgrade if possible."))

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'init-benchmarking) ;; Measure startup time

(defconst *spell-check-support-enabled* nil) ;; Enable with t if you prefer
(defconst *is-a-mac* (eq system-type 'darwin))

;;----------------------------------------------------------------------------
;; Adjust garbage collection thresholds during startup, and thereafter
;;----------------------------------------------------------------------------
(let ((normal-gc-cons-threshold (* 20 1024 1024))
      (init-gc-cons-threshold (* 128 1024 1024)))
  (setq gc-cons-threshold init-gc-cons-threshold)
  (add-hook 'emacs-startup-hook
            (lambda () (setq gc-cons-threshold normal-gc-cons-threshold))))

;;----------------------------------------------------------------------------
;; Bootstrap config
;;----------------------------------------------------------------------------
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(require 'init-utils)
(require 'init-site-lisp) ;; Must come before elpa, as it may provide package.el
;; Calls (package-initialize)
(require 'init-elpa)      ;; Machinery for installing required packages
(require 'init-exec-path) ;; Set up $PATH

;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-preload-local.el"
;;----------------------------------------------------------------------------
(require 'init-preload-local nil t)

;;----------------------------------------------------------------------------
;; Load configs for specific features and modes
;;----------------------------------------------------------------------------

;; Emacs Lisp Python IDE
(package-initialize)
(elpy-enable)

(require-package 'wgrep)
(require-package 'diminish)
(require-package 'scratch)
(require-package 'command-log-mode)

(require 'init-frame-hooks)
(require 'init-xterm)
(require 'init-themes)
(require 'init-osx-keys)
(require 'init-gui-frames)
(require 'init-dired)
(require 'init-isearch)
(require 'init-grep)
(require 'init-uniquify)
(require 'init-ibuffer)
(require 'init-flycheck)

(require 'init-recentf)
(require 'init-smex)
(require 'init-ivy)
(require 'init-hippie-expand)
(require 'init-company)
(require 'init-windows)
(require 'init-sessions)
(require 'init-mmm)

(require 'init-editing-utils)
(require 'init-whitespace)

(require 'init-vc)
(require 'init-darcs)
(require 'init-git)
(require 'init-github)

(require 'init-projectile)

(require 'magit)
(require 'company)

(require 'init-compile)
(require 'init-textile)
(require 'init-markdown)
(require 'init-csv)
(require 'init-erlang)
(require 'init-javascript)
(require 'init-php)
(require 'init-org)
(require 'init-nxml)
(require 'init-html)
(require 'init-css)
(require 'init-haml)
(require 'init-http)
(require 'init-python)
(require 'init-haskell)
(require 'init-elm)
(require 'init-purescript)
(require 'init-ruby)
(require 'init-rails)
(require 'init-sql)
(require 'init-rust)
(require 'init-toml)
(require 'init-yaml)
(require 'init-docker)
(require 'init-terraform)
;;(require 'init-nix)
(maybe-require-package 'nginx-mode)

(require 'init-paredit)
(require 'init-lisp)
(require 'init-slime)
(require 'init-clojure)
(require 'init-clojure-cider)
(require 'init-common-lisp)

(when *spell-check-support-enabled*
  (require 'init-spelling))

(require 'init-misc)

(require 'init-folding)
(require 'init-dash)

;;(require 'init-twitter)
;; (require 'init-mu)
(require 'init-ledger)
;; Extra packages which don't require any configuration

(require-package 'gnuplot)
(require-package 'lua-mode)
(require-package 'htmlize)
(require-package 'dsvn)
(when *is-a-mac*
  (require-package 'osx-location))
(unless (eq system-type 'windows-nt)
  (maybe-require-package 'daemons))
(maybe-require-package 'dotenv-mode)

(when (maybe-require-package 'uptimes)
  (setq-default uptimes-keep-count 200)
  (add-hook 'after-init-hook (lambda () (require 'uptimes))))

;;----------------------------------------------------------------------------
;; Allow access from emacsclient
;;----------------------------------------------------------------------------
(add-hook 'after-init-hook
          (lambda ()
            (require 'server)
            (unless (server-running-p)
              (server-start))))

;;----------------------------------------------------------------------------
;; Variables configured via the interactive 'customize' interface
;;----------------------------------------------------------------------------
(when (file-exists-p custom-file)
  (load custom-file))

;;-----------------------+
;; Setup how emacs looks |
;;-----------------------+

;; Load atom one dark theme
(load-theme 'atom-one-dark t)

;; Set default font
(add-to-list 'default-frame-alist
             '(font . "DejaVu Sans Mono Nerd Font:antialias=1"))
(set-face-attribute 'default nil
                    :height 121
                    :weight 'normal
                    :width 'normal)

;; Set cursor type
(setq sentence-end-double-space nil)
(setq-default cursor-type '(bar . 2))

;; Set line highlighting
(global-hl-line-mode 1)

;; Set transperancy in emacs
(defun toggle-transparency ()
  (interactive)
  (let ((alpha (frame-parameter nil 'alpha)))
    (set-frame-parameter
     nil 'alpha
     (if (eql (cond ((numberp alpha) alpha)
                    ((numberp (cdr alpha)) (cdr alpha))
                    ;; Also handle undocumented (<active> <inactive>) form.
                    ((numberp (cadr alpha)) (cadr alpha)))
              100)
         '(90 . 50) '(100 . 100)))))
(global-set-key (kbd "C-c t") 'toggle-transparency)

;; Set line numbers
(global-linum-mode t)

;; Set neotree window width
(require 'neotree)
(setq neo-window-width 33)

;; Set window numbering
(setq winum-keymap
      (let ((map (make-sparse-keymap)))
        (define-key map (kbd "C-`") 'winum-select-window-by-number)
        (define-key map (kbd "C-²") 'winum-select-window-by-number)
        (define-key map (kbd "M-0") 'winum-select-window-0-or-10)
        (define-key map (kbd "M-1") 'winum-select-window-1)
        (define-key map (kbd "M-2") 'winum-select-window-2)
        (define-key map (kbd "M-3") 'winum-select-window-3)
        (define-key map (kbd "M-4") 'winum-select-window-4)
        (define-key map (kbd "M-5") 'winum-select-window-5)
        (define-key map (kbd "M-6") 'winum-select-window-6)
        (define-key map (kbd "M-7") 'winum-select-window-7)
        (define-key map (kbd "M-8") 'winum-select-window-8)
        map))
(require 'winum)
(winum-mode)

(global-visual-line-mode t)

;; Start nyan-cat mode...
(nyan-mode t)
(nyan-toggle-wavy-trail)
(setq nyan-bar-length 18)

;; Set telephone-line
(require 'telephone-line)
(setq telephone-line-primary-left-separator 'telephone-line-abs-left
      telephone-line-primary-right-separator 'telephone-line-abs-right)
(defface atom-red '((t (:foreground "#E06C75" :weight bold :background "#3E4451"))) "")
(defface atom-orange '((t (:foreground "#D19A66" :weight bold :background "#3E4451"))) "")
(defface atom-green '((t (:foreground "#98C379" :weight bold :background "#282C34"))) "")
(defface atom-cyan '((t (:foreground "#56B6C2" :weight bold :background "#282C34"))) "")
(defface atom-blue '((t (:foreground "#61AFEF" :weight bold :background "#3E4451"))) "")
(defface atom-purple '((t (:foreground "#C678DD" :weight bold :background "#3E4451"))) "")
(setq telephone-line-faces
      '((red    . (atom-red . atom-red))
        (orange . (atom-orange . atom-orange))
        (green  . (atom-green . atom-green))
        (cyan   . (atom-cyan . atom-cyan))
        (blue   . (atom-blue . atom-blue))
        (purple . (atom-purple . atom-purple))
        (accent . (telephone-line-accent-inactive . telephone-line-accent-inactive))
        (nil    . (mode-line . mode-line-inactive))))
(setq telephone-line-lhs
      '((red    . (telephone-line-window-number-segment))
        (green  . (telephone-line-vc-segment
                   telephone-line-erc-modified-channels-segment
                   telephone-line-process-segment))
        (blue   . (telephone-line-buffer-segment))
        (nil    . (telephone-line-nyan-segment))))
(setq telephone-line-rhs
      '((nil    . (telephone-line-misc-info-segment))
        (orange . (telephone-line-atom-encoding-segment))
        (cyan   . (telephone-line-major-mode-segment))
        (purple . (telephone-line-airline-position-segment))))
(telephone-line-mode 1)

;; Change window size
(global-set-key (kbd "C-s-m") 'shrink-window-horizontally)
(global-set-key (kbd "C-s-c") 'enlarge-window-horizontally)
(global-set-key (kbd "C-s-.") 'shrink-window)
(global-set-key (kbd "C-s-q") 'enlarge-window)
(global-set-key (kbd "C-s-g") 'balance-windows-area)

;;-----------------------+
;; Setup dev environment |
;;-----------------------+

;; Bracket complete mode - electric pairs
(electric-pair-mode 1)
(setq electric-pair-pairs
      '((?\` . ?\`)))

;; Vimlike code folding
(vimish-fold-global-mode 1)

;; Set company globally
(global-company-mode t)

;; Set coding styles and indents
(custom-set-variables
 '(c-default-style
   (quote
    ((other . "stroustrup")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu"))))
 '(sh-basic-offset 2)
 '(sh-indentation 2)
 '(smie-indent-basic 2)
 '(js-indent-level 4))

;; Set spellcheck
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

;; Set python interpreter environment
(setq python-shell-interpreter "python"
      python-shell-interpreter-args "-i")

;; LaTeX and AUCtex setup
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-save-query nil)
(setq TeX-PDF-mode t)
(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)

;;-------------------------+
;; Setup general utilities |
;;-------------------------+

;; Delete trailing white spaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Re-map backward-kill-word
;;(global-set-key (kbd "C-q") 'backward-kill-word)

;; Set eshell key
(global-set-key [f1] 'eshell)

;; Call todo list from register
(set-register ?t '(file . "~/org/todo.org"))

;; Associate other types of files with js-mode
(add-to-list 'auto-mode-alist '("\\.json$" . js2-mode))

;; Add js2 mode
(add-hook 'js-mode-hook 'js2-minor-mode)
(add-hook 'js2-mode-hook 'ac-js2-mode)
(setq js2-highlight-level 3)

;; Setup custom word wrappings
(wrap-region-global-mode t)
(wrap-region-add-wrapper "`" "`" nil 'markdown-mode)
(wrap-region-add-wrapper "~" "~" nil 'markdown-mode)
(wrap-region-add-wrapper "*" "*" nil 'markdown-mode)

;; Custom welcoming screen
(setq initial-scratch-message "
;;███████╗███╗   ███╗ █████╗  ██████╗███████╗    ██████╗ ██╗     ███████╗
;;██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝    ██╔══██╗██║     ╚══███╔╝
;;█████╗  ██╔████╔██║███████║██║     ███████╗    ██████╔╝██║       ███╔╝
;;██╔══╝  ██║╚██╔╝██║██╔══██║██║     ╚════██║    ██╔══██╗██║      ███╔╝
;;███████╗██║ ╚═╝ ██║██║  ██║╚██████╗███████║    ██║  ██║███████╗███████╗
;;╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚══════╝
")

;; Setup org-reveal root
(require 'ox-reveal)
(setq org-reveal-root "file:///home/anarcroth/reveal.js")

;; Move lines up and down
(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "C-s-<up>") 'move-line-up)
(global-set-key (kbd "C-s-<down>") 'move-line-down)

;; Dvorak keys mapping
(global-set-key (kbd "C-z") ctl-x-map)
(global-set-key (kbd "C-x C-h") help-map)
(global-set-key (kbd "C-h") 'backward-kill-word)
(global-set-key (kbd "C-t") 'previous-line)
(global-set-key [?\C-.] 'execute-extended-command)
(global-set-key [?\C-,] (lookup-key global-map [?\C-x]))
(global-set-key [?\C-'] 'hippie-expand)

;;------------------+
;; Org agenda setup |
;;------------------+

(global-set-key (kbd "C-c a") 'org-agenda)

(setq org-agenda-files (list "~/org"))

(setq org-highest-priority ?A)
(setq org-lowest-priority ?C)
(setq org-default-priority ?A)

(setq org-priority-faces '((?A . (:foreground "#D39276" :weight bold))
                           (?B . (:foreground "#1164AF" :weight bold))
                           (?C . (:foreground "#525E6D" :weight bold))))

(setq org-todo-keywords
      '((sequence "TODO(t)" "IN-PROGRESS(p)" "TESTING(e)" "WAITING(w)" "|" "DONE(d)" "CANCELED(c)")
        (sequence "IDEA(i)" "RE-THINK(t)" "LATER(l)" "APPOINTMENT(a)" "|")))

;;Open agenda in current window
(setq org-agenda-window-setup (quote current-window))

;;Capture todo items using C-c c t
(define-key global-map (kbd "C-c c") 'org-capture)
(setq org-capture-templates
      '(("t" "todo" entry (file+headline "~/org/todo.org" "What kind of a day do I want to have?")
         "* TODO [#A] %?")
        ("a" "appointment" entry (file+headline "~/org/todo.org" "Appointments")
         "* APPOINTMENT [#B] %?")
        ("i" "idea" entry (file+headline "~/org/ideas.org" "Ideas")
         "* IDEA [#C] %?")
        ("u" "uni" entry (file+headline "~/org/todo.org" "Uni")
         "* TODO [#A] %?")))

;; Expand org files globally
(setq org-startup-folded nil)

;; email

;;---------------------------------------+
;; Emacs X Window Manager default config |
;;---------------------------------------+

;;;; Disable menu-bar, tool-bar and scroll-bar to increase the usable space.
;;(menu-bar-mode -1)
;;(tool-bar-mode -1)
;;(scroll-bar-mode -1)
;;;; Also shrink fringes to 1 pixel.
;;(fringe-mode 1)
;;
;;;; Turn on `display-time-mode' if you don't use an external bar.
;;(setq display-time-default-load-average nil)
;;(display-time-mode t)
;;
;;;; You are strongly encouraged to enable something like `ido-mode' to alter
;;;; the default behavior of 'C-x b', or you will take great pains to switch
;;;; to or back from a floating frame (remember 'C-x 5 o' if you refuse this
;;;; proposal however).
;;;; You may also want to call `exwm-config-ido' later (see below).
;;(ido-mode 1)
;;
;;;; Emacs server is not required to run EXWM but it has some interesting uses
;;;; (see next section).
;;(server-start)
;;
;;;;;; Below are configurations for EXWM.
;;
;;;; Add paths (not required if EXWM is installed from GNU ELPA).
;;                                        ;(add-to-list 'load-path "/path/to/xelb/")
;;                                        ;(add-to-list 'load-path "/path/to/exwm/")
;;
;;;; Load EXWM.
;;(require 'exwm)
;;
;;;; Fix problems with Ido (if you use it).
;;(require 'exwm-config)
;;(exwm-config-ido)
;;
;;;; Set the initial number of workspaces (they can also be created later).
;;(setq exwm-workspace-number 4)
;;
;;;; All buffers created in EXWM mode are named "*EXWM*". You may want to
;;;; change it in `exwm-update-class-hook' and `exwm-update-title-hook', which
;;;; are run when a new X window class name or title is available.  Here's
;;;; some advice on this topic:
;;;; + Always use `exwm-workspace-rename-buffer` to avoid naming conflict.
;;;; + For applications with multiple windows (e.g. GIMP), the class names of
;;                                        ;    all windows are probably the same.  Using window titles for them makes
;;;;   more sense.
;;;; In the following example, we use class names for all windows expect for
;;;; Java applications and GIMP.
;;(add-hook 'exwm-update-class-hook
;;          (lambda ()
;;            (unless (or (string-prefix-p "sun-awt-X11-" exwm-instance-name)
;;                        (string= "gimp" exwm-instance-name))
;;              (exwm-workspace-rename-buffer exwm-class-name))))
;;(add-hook 'exwm-update-title-hook
;;          (lambda ()
;;            (when (or (not exwm-instance-name)
;;                      (string-prefix-p "sun-awt-X11-" exwm-instance-name)
;;                      (string= "gimp" exwm-instance-name))
;;              (exwm-workspace-rename-buffer exwm-title))))
;;
;;;; Global keybindings can be defined with `exwm-input-global-keys'.
;;;; Here are a few examples:
;;(setq exwm-input-global-keys
;;      `(
;;        ;; Bind "s-r" to exit char-mode and fullscreen mode.
;;        ([?\s-r] . exwm-reset)
;;        ;; Bind "s-w" to switch workspace interactively.
;;        ([?\s-w] . exwm-workspace-switch)
;;        dejav        ;; Bind "s-0" to "s-9" to switch to a workspace by its index.
;;        ,@(mapcar (lambda (i)
;;                    `(,(kbd (format "s-%d" i)) .
;;                      (lambda ()
;;                        (interactive)
;;                        (exwm-workspace-switch-create ,i))))
;;                  (number-sequence 0 9))
;;        ;; Bind "s-&" to launch applications ('M-&' also works if the output
;;        ;; buffer does not bother you).
;;        ([?\s-&] . (lambda (command)
;;                     (interactive (list (read-shell-command "$ ")))
;;                     (start-process-shell-command command nil command)))
;;        ;; Bind "s-<f2>" to "slock", a simple X display locker.
;;        ([s-f2] . (lambda ()
;;                    (interactive)
;;                    (start-process "" nil "/usr/bin/slock")))))
;;
;;;; To add a key binding only available in line-mode, simply define it in
;;;; `exwm-mode-map'.  The following example shortens 'C-c q' to 'C-q'.
;;(define-key exwm-mode-map [?\C-q] #'exwm-input-send-next-key)
;;
;;;; The following example demonstrates how to use simulation keys to mimic
;;;; the behavior of Emacs.  The value of `exwm-input-simulation-keys` is a
;;;; list of cons cells (SRC . DEST), where SRC is the key sequence you press
;;;; and DEST is what EXWM actually sends to application.  Note that both SRC
;;;; and DEST should be key sequences (vector or string).
;;(setq exwm-input-simulation-keys
;;      '(
;;        ;; movement
;;        ([?\C-b] . [left])
;;        ([?\M-b] . [C-left])
;;        ([?\C-f] . [right])
;;        ([?\M-f] . [C-right])
;;        ([?\C-p] . [up])
;;        ([?\C-n] . [down])
;;        ([?\C-a] . [home])
;;        ([?\C-e] . [end])
;;        ([?\M-v] . [prior])
;;        ([?\C-v] . [next])
;;        ([?\C-d] . [delete])
;;        ([?\C-k] . [S-end delete])
;;        ;; cut/paste.
;;        ([?\C-w] . [?\C-x])
;;        ([?\M-w] . [?\C-c])
;;        ([?\C-y] . [?\C-v])
;;        ;; search
;;        ([?\C-s] . [?\C-f])))
;;
;;;; You can hide the minibuffer and echo area when they're not used, by
;;;; uncommenting the following line.
;;                                        ;(setq exwm-workspace-minibuffer-position 'bottom)
;;
;;;; Do not forget to enable EXWM. It will start by itself when things are
;;;; ready.  You can put it _anywhere_ in your configuration.
;;(exwm-enable)
;;
;;------------------------------+
;; End of custom configurations |
;;------------------------------+

;;----------------------------------------------------------------------------
;; Locales (setting them earlier in this file doesn't work in X)
;;----------------------------------------------------------------------------
(require 'init-locales)


;;----------------------------------------------------------------------------
;; Allow users to provide an optional "init-local" containing personal settings
;;----------------------------------------------------------------------------
(require 'init-local nil t)



(provide 'init)

;; Local Variables:
;; coding: utf-8
;; no-byte-compile: t
;; End:
