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
(setq doom-font (font-spec :family "Menlo" :size 14 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Menlo" :size 13))
;;
(map! "M-g f" #'consult-flycheck)
(map! "M-g r" #'consult-recent-file)
(map! "M-g m" #'consult-mark)
(map! "M-g o" #'consult-outline)
(map! "M-o" #'other-window)
(map! "C-x ;" #'comment-line)
(map! "C-x k" #'ill-current-buffer)

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-Iosvkem)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
(setq lsp-eslint-server-command '("vscode-eslint-language-server" "--stdio"))
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
;; ~/.doom.d/config.el

(use-package! minuet
  :init
  (add-hook 'prog-mode-hook 'minuet-auto-suggestion-mode)
  :bind
  (
   ("M-=" . #'minuet-complete-with-minibuffer) ;; use minibuffer for completion
   ("M-i" . #'minuet-show-suggestion) ;; use overlay for completion
   ("C-c m" . #'minuet-configure-provider)

   :map minuet-active-mode-map
   ("M-p" . #'minuet-previous-suggestion) ;; invoke completion or cycle to next completion
   ("M-n" . #'minuet-next-suggestion) ;; invoke completion or cycle to previous completion
   ("M-A" . #'minuet-accept-suggestion) ;; accept whole completion
   ("M-a" . #'minuet-accept-suggestion-line)
   ("M-e" . #'minuet-dismiss-suggestion)
   )

  :config
  (setq minuet-provider 'gemini)
  (defvar minuet-gemini-options    `(:model "gemini-2.5-flash"
                                     :api-key "AIzaSyD22jMeZ1_9LZchl71IoJermwB8fbU4ugw"
                                     :system
                                     (:template minuet-default-system-template
                                      :prompt minuet-default-prompt-prefix-first
                                      :guidelines minuet-default-guidelines
                                      :n-completions-template minuet-default-n-completion-template)
                                     :fewshots minuet-default-fewshots-prefix-first
                                     :chat-input
                                     (:template minuet-default-chat-input-template-prefix-first
                                      :language-and-tab minuet--default-chat-input-language-and-tab-function
                                      :context-before-cursor minuet--default-chat-input-before-cursor-function
                                      :context-after-cursor minuet--default-chat-input-after-cursor-function)
                                     :optional nil)
    "config options for Minuet Gemini provider")
  )

(use-package! lsp-java
  :init
  (setq lombok-library-path (concat user-emacs-directory "lombok.jar"))
  (unless (file-exists-p lombok-library-path)
    (url-copy-file "https://projectlombok.org/downloads/lombok.jar" lombok-library-path))

  (setq lsp-java-vmargs (list
                         "-Xmx1G"
                         "-XX:+UseG1GC"
                         "-XX:+UseStringDeduplication"
                         (concat "-javaagent:" (expand-file-name lombok-library-path))))
  )
(use-package! prodigy
  :bind (("C-c P" . prodigy))
  :config
  (prodigy-define-service
    :name "Backend"
    :command "make"
    :args '("run")
    :cwd "~/.workspace/repos/phoenix/phoenix-core"
    :tags '(work)
    :stop-signal 'kill
    :kill-process-buffer-on-stop t)
  (prodigy-define-service
    :name "Frontend"
    :command "ng"
    :args '("serve")
    :cwd "~/.workspace/repos/phoenix/phoenix-frontend"
    :tags '(work)
    :stop-signal 'kill
    :kill-process-buffer-on-stop t)
  (prodigy-define-service
    :name "Swagger"
    :command "make"
    :args '("swagger")
    :cwd "~/.workspace/repos/phoenix"
    :tags '(work)
    :stop-signal 'kill
    :kill-process-buffer-on-stop t)
  )

(add-hook 'makefile-mode-hook 'makefile-executor-mode)


(use-package! meow
  :config
  (setq meow-cursor-type-normal 'box
        meow-cursor-type-insert 'bar
        meow-cursor-type-beacon 'block
        meow-cursor-type-default 'box
        blink-cursor-delay 0 ; start blinking immediately
        blink-cursor-blinks 0 ; blink forever
        blink-cursor-interval 0.15)

  ) ; blink time period

(map! :map doom-leader-code-map "l" lsp-command-map)


(use-package! beacon
  :config
  (beacon-mode 1))


(use-package! claude-code
  :config
  :config
  (claude-code-mode)
  )
