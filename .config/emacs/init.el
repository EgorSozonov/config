(setq c-basic-offset 4) ; indents 4 chars
(setq tab-width 4)          ; and 4 char wide for TAB
(setq indent-tabs-mode nil) ; And force use of spaces
(setq inhibit-startup-screen t)

(setq custom-file null-device)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
;(setq-default cursor-type '(hbar . 1))
(setq default-cursor-type 'bar)
(setq column-number-mode t)

(add-to-list 'default-frame-alist '(foreground-color . "#FFFFFF"))
(add-to-list 'default-frame-alist '(background-color . "#000000"))

(require 'package)
;(add-to-list 'package-archives
;             '("elpy" . "http://jorgenschaefer.github.io/packages/"))
;(add-to-list 'package-archives
;             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/") t)
             
; list the packages you want
(setq package-list
    '(evil org magit
      ))
      
; activate all the packages
(package-initialize)

; fetch the list of packages available 
(unless package-archive-contents
    (package-refresh-contents))

; install the missing packages
(dolist (package package-list)
    (unless (package-installed-p package)
        (package-install package)))
        
(require 'evil)
(evil-mode 1)
(setq evil-insert-state-cursor '((bar . 5) "white")
      evil-normal-state-cursor '(box "purple"))

(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Remove messages from the *Messages* buffer.
(setq-default message-log-max nil)

;; Kill both buffers on startup.
(kill-buffer "*Messages*")
(kill-buffer "*scratch*")
(setq inhibit-startup-buffer-menu t)

;{{{ Keymaps

(define-key evil-insert-state-map (kbd "TAB") 'evil-normal-state)
(define-key evil-normal-state-map "\C-n" 'next-buffer)
(define-key evil-normal-state-map "\C-p" 'previous-buffer)
(define-key evil-normal-state-map "\S-l" (lambda() (interactive) (forward-char 21)))
(define-key evil-normal-state-map "\S-h" (lambda() (interactive) (backward-char 21)))
(define-key evil-normal-state-map "o" 
    (lambda()
        (interactive)
        (save-excursion
            (end-of-line)
            (open-line 1)
        )
    )
)
(define-key evil-normal-state-map "O"
    (lambda()
        (interactive)
        (save-excursion
            (end-of-line 0)
            (open-line 1)
        )
    )
) 
(define-key evil-normal-state-map " " 
    (lambda ()
        (interactive)
        (insert-char #x20)
    ) 
)
;}}}

