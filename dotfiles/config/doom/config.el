;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Highlight active window only with colored mode-line border
(custom-set-faces!
  ;; Active window: bright blue border via mode-line
  '(mode-line :box (:line-width 2 :color "#51afef"))
  ;; Inactive windows: no visible border
  '(mode-line-inactive :box (:line-width 2 :color "#1c1f24")))

;; Dim inactive buffers to make active one stand out
(use-package! auto-dim-other-buffers
  :config
  (auto-dim-other-buffers-mode t)
  (setq auto-dim-other-buffers-dim-on-switch-to-minibuffer nil))

;; ============================================================
;; EMAIL (mu4e + Gmail)
;; ============================================================
(setq user-full-name "Adam Koszalka"
      user-mail-address "hamper100@gmail.com")

(after! mu4e
  (setq mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300              ; Check mail every 5 minutes
        mu4e-compose-signature-auto-include nil
        mu4e-view-show-images t
        mu4e-view-show-addresses t)

  ;; Gmail account setup
  (set-email-account! "Gmail"
    '((mu4e-sent-folder       . "/Gmail/[Gmail]/Sent Mail")
      (mu4e-drafts-folder     . "/Gmail/[Gmail]/Drafts")
      (mu4e-trash-folder      . "/Gmail/[Gmail]/Trash")
      (mu4e-rstrash-folder    . "/Gmail/[Gmail]/Trash")
      (smtpmail-smtp-user     . "hamper100@gmail.com")
      (smtpmail-smtp-server   . "smtp.gmail.com")
      (smtpmail-smtp-service  . 587)
      (smtpmail-stream-type   . starttls))
    t))

;; ============================================================
;; POMODORO TIMER
;; ============================================================
(use-package! org-pomodoro
  :after org
  :config
  (setq org-pomodoro-length 25              ; 25 min work
        org-pomodoro-short-break-length 5   ; 5 min short break
        org-pomodoro-long-break-length 15   ; 15 min long break
        org-pomodoro-long-break-frequency 4 ; long break after 4 pomodoros
        org-pomodoro-play-sounds t
        org-pomodoro-keep-killed-pomodoro-time t)

  ;; Keybinding: SPC m p to start pomodoro
  (map! :leader
        :desc "Pomodoro" "m p" #'org-pomodoro))

;; ============================================================
;; PDF TOOLS
;; ============================================================
(after! pdf-tools
  (setq pdf-view-display-size 'fit-width
        pdf-annot-activate-created-annotations t) ; auto-open annotation popup
  ;; Better scrolling
  (setq pdf-view-resize-factor 1.1))

;; ============================================================
;; MAGIT (Git)
;; ============================================================
(after! magit
  (setq magit-save-repository-buffers 'dontask
        magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1
        git-commit-summary-max-length 72))

;; ============================================================
;; TREEMACS (Project sidebar)
;; ============================================================
(after! treemacs
  (setq treemacs-width 30
        treemacs-position 'left
        treemacs-follow-mode t
        treemacs-filewatch-mode t
        treemacs-fringe-indicator-mode 'always)

  ;; Show only current project
  (treemacs-project-follow-mode t))

;; ============================================================
;; ZEN MODE (Distraction-free writing)
;; ============================================================
(after! writeroom-mode
  (setq writeroom-width 100
        writeroom-mode-line t               ; keep mode-line visible
        writeroom-global-effects
        '(writeroom-set-alpha
          writeroom-set-menu-bar-lines
          writeroom-set-tool-bar-lines
          writeroom-set-vertical-scroll-bars
          writeroom-set-bottom-divider-width)))

