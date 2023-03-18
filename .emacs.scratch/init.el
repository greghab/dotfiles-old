;;; -*- lexical-binding: t -*-

(defun tangle-init ()
  "If the current buffer is 'init.org' the code-blocks are
tangled, and the tangled file is compiled."
  (when (equal (buffer-file-name)
               (expand-file-name (concat user-emacs-directory "init.org")))
    ;; Avoid running hooks when tangling.
    (let ((prog-mode-hook nil))
      (org-babel-tangle)
      (byte-compile-file (concat user-emacs-directory "init.el")))))

(add-hook 'after-save-hook 'tangle-init)

(add-hook
 'after-init-hook
 (lambda ()
   (let ((private-file (concat user-emacs-directory "private.el")))
     (when (file-exists-p private-file)
       (load-file private-file)))))

;The initial threshold value is GC_DEFAULT_THRESHOLD, defined in alloc.c. Since it's defined in word_size units, the value is 400,000 for the default 32-bit configuration and 800,000 for the 64-bit one. If you specify a larger value, garbage collection will happen less often. This reduces the amount of time spent garbage collecting, but increases total memory use. You may want to do this when running a program that creates lots of Lisp data. 
(defun ap/garbage-collect ()
  "Run `garbage-collect' and print stats about memory usage."
  (interactive)
  (message (cl-loop for (type size used free) in (garbage-collect)
                    for used = (* used size)
                    for free = (* (or free 0) size)
                    for total = (file-size-human-readable (+ used free))
                    for used = (file-size-human-readable used)
                    for free = (file-size-human-readable free)
                    concat (format "%s: %s + %s = %s\n" type used free total))))
;(setq gc-cons-threshold (* 10000 1024))
;(add-hook 'emacs-startup-hook
;          (lambda () (setq gc-cons-threshold (* 10000 1024))))


;(garbage-collect)

;;(require 'cl)     
  ;; Disable Warnings
  ;; https://stackoverflow.com/questions/5019724/in-emacs-what-does-this-error-mean-warning-cl-package-required-at-runtime
 ; (with-no-warnings
 ; (require 'cl))
 ; (require 'package)
 ; (package-initialize)

  ;(require 'use-package)
;  (use-package mu4e 
  ;:ensure t
 ; )

; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
    ; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))

    ; (add-to-list 'package-pinned-packages '(cider . "melpa-stable") t)
      ;(add-to-list 'load-path "~/.emacs.d/lisp/")
    (add-to-list 'load-path "~/.emacs.scratch/lisp/")


;https://www.emacswiki.org/emacs/LoadPath
;(let ((default-directory  "~/.emacs.d/lisp/"))
;  (normal-top-level-add-subdirs-to-load-path))
;(require 'pdf-avy-highlight)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(require 'use-package)

;; Should be placed inside init.el before anything loading org-mode 
      ;;(straight-use-package '(org :host github :repo "yantar92/org" :branch "feature/org-fold-universal-core"
      ;;                            :files (:defaults "contrib/lisp/*.el")))
      ;;(use-package org
      ;;   :straight t
      ;;  )

  ;; CASE 1: DO NOTHING
  ;; (use-package emacs-lisp-mode :straight ni
;;(use-package org :straight nil)

  ;; CASE 2: USE BUILT IN ORG PACKGAE (IGNORE STRAIGHT.EL)
  ;; THIS DOES WORK, BUT I CANNOT DO straight-pull-all - I CANT FUCKING UPDATE!!! BURH BRUH
  ;; https://github.com/radian-software/straight.el/issues/428
  (use-package org :straight (:type built-in))

  ;; CASE 3: USE SOMETHING ELSE (OTHER THAN STRAIGHT) - I'M NOT QUITE SURE - MAYBE AN ALTERNATIVE TO BUILT-IN
  ;; THIS DOES NOT FUCKING WORK (org-file-name-concat is void, errors in load - borked install)
  ;;(use-package org :straight nil)

(require 'org-mouse)

;; https://stackoverflow.com/questions/36416030/how-to-enable-org-indent-mode-by-default 
(add-hook 'org-mode-hook 'org-indent-mode)

;; https://emacs.stackexchange.com/questions/38198/automatically-preview-latex-in-org-mode-as-soon-as-i-finish-typing
(straight-use-package 'org-fragtog)

(use-package org-pdftools
  :straight t
  :hook (org-load . org-pdftools-setup-link))

(use-package org-noter-pdftools
  :straight t
  :after org-noter
  :config
  (with-eval-after-load 'pdf-annot
    (add-hook 'pdf-annot-activate-handler-functions #'org-noter-pdftools-jump-to-note)))

(straight-use-package 'org-drill)

(use-package org-noter
  :after org
  :straight t
  :config (setq org-noter-default-notes-file-names '("notes.org")
                org-noter-notes-search-path '("~/nextcloud/notes/books")
                org-noter-always-create-frame nil
                org-noter-separate-notes-from-heading t))


;; (setq org-noter-separate-notes-from-heading t)

;; (straight-use-package 
;; '(org-download
;; :ensure t
;; :defer t
;; :init
;; Add handlers for drag-and-drop when Org is loaded.
;; (with-eval-after-load 'org
;; (org-download-enable))))

(use-package org-download
  :straight t
  :config
  ;; remove the DOWNLOADED attribute above pasted images
  ;; (setq org-download-annotate-function (lambda (_link) ""))
  (setq org-download-annotate-function (lambda (_link) "\#+ATTR_ORG: :width 600\n"))
  (setq-default org-download-image-dir "./.images/")
  ;; (setq-default org-download-image-dir "~/Documents/org/.images")
  ;; (setq-default org-download-abbreviate-filename-function 'expand-file-name)
  (setq org-download-screenshot-method "xclip -selection clipboard -t image/png -o > %s")
  ;; (setq-default org-download-screenshot-method "scrot -s %s")
  ;; (setq-default org-download-screenshot-method "escrotum -s %s")
  (setq-default org-download-heading-lvl 0))

(use-package ox-clip
  :straight t
  )

(use-package good-scroll
  :straight t
  )
;;(add-hook 'org-mode-hook (lambda () (good-scroll-mode 1)))
;;(good-scroll-mode 1)

(use-package org-modern-indent
  ;; :straight or :load-path here, to taste
  :hook
  (org-indent-mode . org-modern-indent-mode))

(setq org-edit-src-content-indentation 0)

;;(hi-lock-mode 1)
(add-hook 'org-mode-hook (lambda () (hi-lock-mode 1)))

(use-package dendroam
 :straight (:host github :repo "vicrdguez/dendroam" :after org-roam))

;; doesn't work...
;;(straight-use-package
;; '(dendroam :type git :host github :repo "vicrdguez/dendroam" :after org-roam))
(setq org-roam-node-display-template "${hierarchy}.${title}")


(setq org-roam-capture-templates
      '(("d" "default" plain
         "%?"
         :if-new (file+head "${slug}.org"
                            "#+title: ${hierarchy-title}\n")
         :immediate-finish t
         :unnarrowed t)))

(setq dendroam-capture-templates
      '(("t" "Time note" entry
         "* %?"
         :if-new (file+head "${current-file}.%<%Y.%m.%d>.org"
                            "#+title: %^{title}\n"))
        ("s" "Scratch note" entry
         "* %?"
         :if-new (file+head "scratch.%<%Y.%m.%d.%.%M%S%3N>.org"
                            "#+title: %^{title}\n"))))
(defun dendroam-node-find-initial-input ()
  (interactive)
  (org-roam-node-find nil (if (buffer-file-name)
                         (file-name-base (buffer-file-name))
                         "")))

(defun gh/counsel-fzf-org-roam ()
  "Run `garbage-collect' and print stats about memory usage."
  (interactive)
  (counsel-fzf "org-roam/"))

(use-package org-transclusion
 :straight (:after org-mode))
(add-hook 'org-mode-hook (lambda () (org-transclusion-mode 1)))

(defconst help/org-special-pre "^\s*#[+]")

(defun help/org-2every-src-block (fn)
  "Visit every Source-Block and evaluate `FN'."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((case-fold-search t))
      (while (re-search-forward (concat help/org-special-pre "BEGIN_SRC") nil t)
        (let ((element (org-element-at-point)))
          (when (eq (org-element-type element) 'src-block)
            (funcall fn element)))))
    (save-buffer)))

;; (define-key org-mode-map (kbd "s-]") (lambda () (interactive)
;;                                        (help/org-2every-src-block
;;                                        'org-babel-remove-result)))

(defun removeResultBlocks () (interactive)
  (help/org-2every-src-block
   'org-babel-remove-result))

(setq comp-deferred-compilation-deny-list '())

;; (setq jit-lock-defer-time 0)
;; (setq fast-but-imprecise-scrolling t)
;; (setq mouse-wheel-scroll-amount '(20))
;; (setq mouse-wheel-progressive-speed nil)
;; (setq warning-minimum-level :emergency)


;;;;; 

;;https://old.reddit.com/r/emacs/comments/55zk2d/adjust_the_size_of_pictures_to_be_shown_inside/
;; (setq org-image-actual-width '(300));
;;(define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)
;;https://old.reddit.com/r/emacs/comments/8sw3r0/finally_scrolling_over_large_images_with_pixel/
;;(pixel-scroll-mode t)
;;(setq pixel-resolution-fine-flag t)
;;(setq mouse-wheel-scroll-amount '(20))
;;(setq fast-but-imprecise-scrolling t)
;;(setq jit-lock-defer-time 0)
;;(setq mouse-wheel-progressive-speed nil)

;; scroll one line at a time (less "jumpy" than defaults)

;; (setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
;; (setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
;; (setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse
;; (setq scroll-step 1) ;; keyboard scroll one line at a time

;; try to make dividers go away
(set-face-background 'vertical-border "gray")
(set-face-foreground 'vertical-border (face-background 'vertical-border))

;; make focus follow mouse, useful to drag and drop stuff for exwm and org-download.
;; https://github.com/ch11ng/exwm/wiki#how-to-make-focus-follow-mouse
;; (setq mouse-autoselect-window t
;;  focus-follows-mouse t)

;; (straight-use-package 'centered-window)

;; (setq cwm-use-vertical-padding t)
;; (setq cwm-frame-internal-border 20)

;; (setq default-directory "/media/peshmerga/data/data/study/CSE143Wi18/test1/" )

(setq confirm-kill-processes nil)

(add-to-list 'custom-theme-load-path "~/.emacs.scratch/themes")

(global-visual-line-mode t)   
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

(setq-default indent-tabs-mode t)

(straight-use-package 'haskell-mode)
(haskell-mode)

(require 'ob-java)

(straight-use-package 'lua-mode)

(straight-use-package 'flycheck)
(straight-use-package 'clojure-mode)
;;(use-package carp-emacs
;; :straight (:host github :repo "carp-lang/carp-emacs"))

;;(require 'carp-mode)
;;(require 'inf-carp-mode)

;; Use carp-mode for .carp files
;;(add-to-list 'auto-mode-alist '("\\.carp\\'" . carp-mode))


(require 'carp-mode)
(require 'inf-carp-mode)

;; Use carp-mode for .carp files
(add-to-list 'auto-mode-alist '("\\.carp\\'" . carp-mode))


(require 'carp-flycheck)

(add-hook 'carp-mode-hook
          (lambda ()
            (flycheck-mode 1)))

(use-package leetcode
  :straight t
  :config
  (setq leetcode-prefer-language "python3")
  (setq leetcode-prefer-sql "mysql")
  (setq leetcode-save-solutions t)
  (setq leetcode-directory "~/dev/leetcode/workedProblems")
  )

;;End of buffeeeeeeeeeeerrrrrrrrrrrr by Joseph Wilk
(defvar start-total-count 0)

(defun zone-end-of-buffer-animate (c col wend)
  (let ((fall-p nil)                    ; todo: move outward
        (o (point))                     ; for terminals w/o cursor hiding
        (p (point))
        (insert-char " ")
        (halt-char " ")
        (counter 0))

    (while (< counter 10)
      (let ((next-char     (char-after p))
            (previous-char (char-after (- p 1))))

        ;;(progn (forward-line 1) (move-to-column col) (looking-at halt-char))
        ;;          (when (< counter 50)    (move-to-column (mod counter 150)))

        (when (< (random 100) 50)  (move-to-column counter))

        (setq counter (+ 1 counter))
        (setq total-count (+ 1 total-count))

        (if (and (not (looking-at ")"))
                 (not (looking-at "("))
                 (not (looking-at "\s+"))
                 (not (looking-at "\n+")))
            (progn
              (save-excursion
                (dotimes (_ (random counter))
                  ;;(delete-char 1)
                  (insert insert-char)
                )
                ;;(goto-char o)
                (sit-for 0))
              (if (<= 5 (mod counter 10))
                  (setq p (- (point) 1))
                (setq p (+ (point) 1)))))))
    fall-p))

(defun zone-end-of-buffer ()
  (set 'truncate-lines nil)
  (setq total-count 0)
  (let* ((ww (1- (window-width)))
         (wh (window-height))
         (mc 0)                         ; miss count
         (total (* ww wh))
         (fall-p nil)
         (wend 100)
         (wbeg 1)
         (counter 0))
    (goto-char (point-min))


    (let ((nl (- wh (count-lines (point-min) (point)))))
      (when (> nl 0)
        (let ((line (concat (make-string (1- ww) ? ) "\n")))
          (do ((i 0 (1+ i)))
              ((= i nl))
          ;;  (insert line)
            ))))

    (catch 'done; ugh
      (while (not (input-pending-p))
        (goto-char (point-min))
        (let ((wbeg (window-start))
              (wend (window-end)))
          (setq mc 0)

          (goto-char (+ wbeg (random (- wend wbeg))))
          (while (looking-at "[\t\n ]") (goto-char (+ wbeg (random (- wend wbeg)))))
          ;; character animation sequence

          (setq counter (+ 1 counter))

          (let ((p (point)))
            (goto-char p)
            (when (<  counter 10000) (zone-end-of-buffer-animate (zone-cpos p) (current-column) wend))
            (when (and (> counter 4500) (< counter 10000))
              (while (re-search-forward "\\(\s+\\)" nil t 1)
                (when (< (random 100) 50) (replace-match "\\1 "))))

            (when (and (< counter -100)) (dotimes (i 1)
                                       (goto-char (+ wbeg (random (- wend wbeg))))
                                ;;       (zone-stars-animate (zone-cpos p) (current-column) wend)
                                     ;;(goto-char wbeg)
                                       (insert "\n\n")
                                       (insert "(orepl  oo    e   csm      l o l  tsound    ibbbb   s  m  code  code  lcode  rrrr   \n")
                                       (insert "(v      v n   r   o  u     i   e  i         x   b   o  u  t     t     i      r  r   \n")
                                       (insert "(elec   e  u  d   s   v    e   d  dmusic    i b     u  s  enot  enot  vive   rr r   \n")
                                       (insert "(r      r   c j   e  i     e   d  a         l   b   n  i  x     x     e      r r    \n")
                                       (insert "(tone   t    lo   iac      codes  l         angbb   dcoc  t     t     code   r   r  \n")
                                       (insert "\n\n")

                                       (sit-for 1)


                                       (goto-char (+ wbeg (- wend wbeg)))
                                       (setq fall-p (zone-fall-through-ws-re  (zone-cpos p) (current-column) wend))
                                       ))

            (when (> counter  11000) (dotimes (i 100)
                                      (goto-char (+ wbeg (random (- wend wbeg))))
                                      (while (looking-at "[\t\n ]") (goto-char (+ wbeg (random (- wend wbeg)))))
                                      (setq fall-p (zone-fall-through-ws-re  (zone-cpos p) (current-column) wend))))
            ))
        ;; assuming current-column has not changed...
        ))))


(eval-after-load "zone"
  '(unless (memq 'zone-end-of-buffer (append zone-programs nil))
     (setq zone-programs [zone-end-of-buffer])))

(defun close-all-buffers ()
  (interactive)
  (mapc 'kill-buffer (buffer-list)))

(defun coursera-delete-start ()
  (interactive)
  (flush-lines "Start transcript" nil (point-min) (point-max)))

(defun replace-period-with-newline-and-dash ()
  (interactive)
  (replace-string "." "
                                                                                                                                                                                                                                                                                                                                                                   -" nil (point-min) (point-max)))

;; https://old.reddit.com/r/emacs/comments/849ycn/is_it_possible_to_get_tomorrows_date_using/
(defun pom ()
  (interactive)
  (let* ((now (current-time))
           (pomodoro (time-add now (* 0.5 3600)))) ;; 0.5 hours * seconds
    (insert   (concat "["  (format-time-string "%H:%M" now) " - "  (format-time-string "%H:%M" pomodoro) "]: work"))))


;; Function to insert a note of a 25 minute pomodoro from your current time, into your current emacs buffer. (Usefull if you have a pomodoro on your phone, and your tracking your day in your emacs org-mode buffer).
  (defun ajahn ()
    (interactive)
    (let* ((now (current-time))
             (pomodoro (time-add now (* 25 60)))) ;; 25 min pomodoro: 25 * 60. This is local variable called pomodoro in the function.
      (insert   (concat "["  (format-time-string "%H:%M" now) " - "  (format-time-string "%H:%M" pomodoro) "]: work"))))


  (defun ajahn-sacrifice ()
    (interactive)
    (let* ((now (current-time))
             (pomodoro (time-add now (* 25 60)))) ;; 25 min pomodoro: 25 * 60. This is local variable called pomodoro in the function.
      (insert   (concat "[ ] ["  (format-time-string "%H:%M" now) " - "  (format-time-string "%H:%M" pomodoro) "]: 𒉭Sacrifice𒉭"))))

(defun ajahn-sacrifice-start-sound ()
  (interactive)
 (start-process "mplayer" nil "mplayer" "/home/greghab/Documents/org/org-roam/sounds/org.gnome.Solanum-beep.ogg")
)

(defun ajahn-sacrifice-end-sound ()
  (interactive)
 (start-process "mplayer" nil "mplayer" "/home/greghab/Documents/org/org-roam/sounds/org.gnome.Solanum-chime.ogg")
)

;; https://emacs.stackexchange.com/questions/63987/timer-runs-immediately-then-periodically
(defun ajahn-sacrifice-with-sounds ()
  (interactive)
  (ajahn-sacrifice-start-sound)
  (ajahn-sacrifice)
  (run-at-time "25 min" nil #'ajahn-sacrifice-end-sound)
  )

;; https://emacs.stackexchange.com/questions/6029/is-it-possible-to-execute-a-function-or-command-at-a-specific-time
;;(run-at-time "5 sec" nil #'test-msg)

(defun pom-msg() 
(shell-command "notify-send 'pomodoro up' -u critical -t 0"))

  (defun pom-break-msg() 
(shell-command "notify-send 'liminal space compacted' -u critical -t 0"))



  ;; https://old.reddit.com/r/emacs/comments/849ycn/is_it_possible_to_get_tomorrows_date_using/
;; https://unix.stackexchange.com/questions/197748/is-there-a-desktop-notification-that-stays-shown-until-i-click-it
        (defun pom2 ()
               (interactive)
               (let* ((now (current-time))
                        (pomodoro (time-add now (* 0.5 3600)))) ;; 0.5 hours * seconds
                 (insert   (concat "["  (format-time-string "%H:%M" now) " - "  (format-time-string "%H:%M" pomodoro) "]: work")))
               (run-at-time "30 min" nil #'pom-msg)
                (run-at-time "35 min" nil #'pom-break-msg))

(defun gh/blanket-start ()
  (interactive)
  (start-process "mpv" "foo" "mpv" "/home/greghab/Documents/org/org-roam/sounds/blanket/wind.ogg" "--loop" "0" "-volume" "60")
  (start-process "mpv" "foo" "mpv" "/home/greghab/Documents/org/org-roam/sounds/blanket/white-noise.ogg" "--loop" "0" "-volume" "60")
  (start-process "mpv" "foo" "mpv" "/home/greghab/Documents/org/org-roam/sounds/blanket/waves.ogg" "--loop" "0" "-volume" "60")
  (start-process "mpv" "foo" "mpv" "/home/greghab/Documents/org/org-roam/sounds/blanket/rain.ogg" "--loop" "0" "-volume" "60")
)

(defun gh/blanket-stop ()
  (interactive)
 (start-process "kill blanket" "foo" "killall" "mpv")
)

(defun arrayify (start end quote)
  "Turn strings on newlines into a QUOTEd, comma-separated one-liner."
  (interactive "r\nMQuote: ")
  (let ((insertion
         (mapconcat
          (lambda (x) (format "%s%s%s" quote x quote))
          (split-string (buffer-substring start end)) ", ")))
    (delete-region start end)
    (insert insertion)))

;; https://emacs.stackexchange.com/questions/12613/convert-the-first-character-to-uppercase-capital-letter-using-yasnippet
(defun capitalizeFirst (s)
  (if (> (length s) 0)
      (concat (upcase (substring s 0 1)) (substring s 1))
    nil))


(defun wordp (c) (= ?w (char-syntax c)))
(defun lowercasep (c) (and (wordp c) (= c (downcase c))))
(defun uppercasep (c) (and (wordp c) (= c (upcase c))))
(defun whitespacep (c) (= 32 (char-syntax c)))

(defvar path-name-full
  "path-name-full")
(defvar path-name-nondirectory
  "path-name-nondirectory")
(defvar path-name-nondirectory-no-filetype
  "path-name-nondirectory-no-filetype")
(defvar parent-directory-name
  "parent-directory-name")
(defvar parent-directory-name-split
  "parent-directory-name-split")
(defvar parent-directory-name-number
  "parent-directory-name-number")
(defvar parent-directory-name-text
  "parent-directory-name-text")
(defvar full-file-name
  "full-file-name")
(defvar problem-num
  "problem-num")
(defvar problem-name
  "problem-name")
(defvar problem-name-capitalized
  "problem-name-capitalized")
(defvar problem-name-capitalized-and-reversed
  "problem-name-capitalized-and-reversed")
(defvar problem-name-formatted
  "problem-name-formatted")
(defvar problem-difficulty
  "problem-difficulty")
(defvar path-name-nondirectory-no-filetype-split-on-dash
  "path-name-nondirectory-no-filetype-split-on-dash")
;; https://kitchingroup.cheme.cmu.edu/blog/2015/10/13/Line-numbers-in-org-mode-code-blocks/
(make-variable-buffer-local 'path-name-full) 
(make-variable-buffer-local 'path-name-nondirectory) 
(make-variable-buffer-local 'path-name-nondirectory-no-filetype) 
(make-variable-buffer-local 'parent-directory-name) 
(make-variable-buffer-local 'parent-directory-name-split) 
(make-variable-buffer-local 'parent-directory-name-number) 
(make-variable-buffer-local 'parent-directory-name-text) 
(make-variable-buffer-local 'full-file-name) 
(make-variable-buffer-local 'problem-num) 
(make-variable-buffer-local 'problem-name) 
(make-variable-buffer-local 'problem-name-capitalized) 
(make-variable-buffer-local 'problem-name-capitalized-and-reversed) 
(make-variable-buffer-local 'problem-name-formatted) 
(make-variable-buffer-local 'problem-difficulty) 

(defun insert-file-name-grokking ()
  "Insert the file name (nondirectory), with .org stripped, into the current buffer."
  (interactive)
  (setq path-name-full (buffer-file-name (window-buffer (minibuffer-selected-window))))
  (setq path-name-nondirectory (string-replace ".org" "" path-name-full))
  (setq path-name-nondirectory-no-filetype (file-name-nondirectory path-name-nondirectory))
  (setq parent-directory-name (file-name-nondirectory
                               (directory-file-name default-directory)))
  (setq path-name-nondirectory-no-filetype-split-on-dash (split-string path-name-nondirectory-no-filetype  "-"))  
  (setq parent-directory-name-split (split-string parent-directory-name  "-"))  
  (setq parent-directory-name-number ( nth 0 parent-directory-name-split)) 
  (setq parent-directory-name-text (capitalizeFirst ( nth 1 parent-directory-name-split)))

  (setq problem-num ( nth 0 path-name-nondirectory-no-filetype-split-on-dash)) 
  (setq problem-name ( nth 1 path-name-nondirectory-no-filetype-split-on-dash)) 
  (setq problem-name-capitalized (capitalizeFirst problem-name))
  (print (concat "problem-name-capitalized: " problem-name-capitalized))
  (setq problem-name-capitalized-and-reversed (reverse problem-name-capitalized))
  (print (concat "problem-name-capitalized-and-reversed: " problem-name-capitalized-and-reversed))
  (setq problem-difficulty ( nth 2 path-name-nondirectory-no-filetype-split-on-dash))

  (let (
        (word "") ;; word temporary (scoped) variable
        (words '()) ;; empty list of words
        (words-as-string "") ;; concat of words
        )
    ;; (seq-doseq (element problem-name) ;; iterate through string, character by character.
    (seq-doseq (element problem-name-capitalized-and-reversed) ;; iterate through string, character by character.
      (let
          (
           (elementStr (byte-to-string (string-to-number (prin1-to-string element)))) ;; define elementStr local variable
           );;https://opensource.com/article/20/3/variables-emacs
        ;;(print elementStr)

        (if (uppercasep (string-to-char elementStr))

            ;; uppercase:
            ;; - print value: (message (cons element value))
            ;; - create empty value

            ;;(print (concat "value is: " (number-to-string value)))
            (progn ;; https://emacs.stackexchange.com/questions/18351/how-execute-multiple-lists-in-a-true-statement
              ;;(print (concat "uppercase -> elementStr is: " elementStr))
              (setq word (concat elementStr word)) ;; prepend character to the word we're building.
              ;;(print (concat "word is: " word))
              
              (setq words (cons word words)) ;; add word to list of words

              (setq words-as-string (concat word " " words-as-string)) ;; add word to list of words
              
              (setq word "") ;; reset word value, as we've reached the end of that word
              )
          ;; lowercase:
          ;; - add character to value

          ;;(print (concat "value is: " value))
          (progn
            ;;(print "lowercase: ")
            ;;(print (concat "lowercase -> elementStr is: " elementStr))
            (setq word (concat elementStr word)) ;; prepend character to the word we're building.
            )
          )
        )
      )
    (print "words are:")
    (print words)
    ;; http://xahlee.info/emacs/emacs/elisp_string_functions.html
    ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Arithmetic-Operations.html
    (setq words-as-string (substring words-as-string 0 (1- (length words-as-string)))) ;; get rid of last space: "Pair With Target Sum "

    (setq problem-name-formatted (concat "" words-as-string)) ;; get rid of last space: "Pair With Target Sum "
    
    (print words-as-string)
    )
  

  ;;(setq full-file-name (concat "[" parent-directory-name "]: " "[" problem-num "] " problem-name-formatted " [" problem-difficulty "]"))  
  ;;(setq full-file-name (concat "(~" parent-directory-name "~): ~:::λ:::~ "  "(~" problem-num "~) *" problem-name-formatted "* (~" problem-difficulty "~)"))

  ;; (setq parent-directory-name-number ( nth 0 parent-directory-name-split)) 
  ;; (setq parent-directory-name-text (capitalizeFirst ( nth 1 parent-directory-name-split)))

  (setq full-file-name (concat "* (~" parent-directory-name-number "~) (~" parent-directory-name-text  "~) ~:::λ:::~ "  "(~" problem-num "~) *" problem-name-formatted "* (~" problem-difficulty "~)"))  
  
  ;;(setq full-file-name (concat "*(~" parent-directory-name "~): ~:::λ:::~ "  "(~" problem-num "~) " problem-name-formatted " (~" problem-difficulty "~)*"))  
  ;;(print full-file-name (concat "[" parent-directory-name "]: " "[" problem-num "] " problem-name-formatted " [" problem-difficulty "]"))
  (insert full-file-name))
;;(insert-file-name-greg)

;; (straight-use-package 'eyebrowse) 
;; (eyebrowse-mode t)

;; (use-package eyebrowse-restore
;;   :ensure t
;;   :straight t
;;   :config
;;   (eyebrowse-restore-mode))
;; ;;(set-frame-parameter nil 'name "Main")
;; (setq eyebrowse-restore-dir "/home/greghab/.emacs.scratch/eyebrowse-restore/temp/")

(use-package perspective
  :straight t
  :bind
  ("C-x C-b" . persp-list-buffers)         ; or use a nicer switcher, see below
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))  ; pick your own prefix key here
  :init
  (persp-mode))
(setq persp-state-default-file "~/nextcloud/dev/interviewPrep/designGurus/grokkingtheCodingInterviewPatternsforCodingQuestions/persp")

(straight-use-package 'mpv)

;; (straight-use-package 'dashboard)

;; (straight-use-package 'mini-modeline)

;; (straight-use-package 
;;  '(mini-modeline
;;    :ensure t
;;    :defer t
;;    :init
;;    (mini-modeline-mode 1)
;;    ))
;; (setq mini-modeline-right-padding 17)

;; (straight-use-package 'helm-projectile)
(straight-use-package 'helm-ag)

(straight-use-package 'ag)

;; (use-package perspective
;;   :straight t
;;   :bind ("C-x C-b" . persp-list-buffers) ; or use a nicer switcher, see below
;;   :config (persp-mode))

(straight-use-package 
 '(deft
    :ensure t
    :defer t
    ))

(setq deft-extensions '("txt" "tex" "org"))
(setq deft-directory "~/nextcloud/notes/")
(setq deft-recursive t)

(straight-use-package 'yasnippet)
(straight-use-package 'yasnippet-snippets)

;;(straight-use-package 'eaf)

(straight-use-package 'prism)

(use-package calfw
  :straight (:host github :repo "kiwanami/emacs-calfw")
  :config
  (with-eval-after-load 'calfw
    (use-package calfw-ical
      :straight (:host github :repo "kiwanami/emacs-calfw"))
    (use-package calfw-org
      :straight (:host github :repo "kiwanami/emacs-calfw"))
    (use-package calfw-cal
      :straight (:host github :repo "kiwanami/emacs-calfw"))))

;; (use-package org-roam
;;       ;;:straight (:type git :host github :repo "org-roam/org-roam")
;;   ;;:straight t
;;   :hook
;;       (after-init . org-roam-mode)
;;       :init
;;       (setq org-roam-v2-ack t) ;; disable v2 upgrade warning
;;       :custom
;;       (org-roam-directory "~/Documents/org/org-roam/")
;;       (org-roam-setup)
;;       :bind (:map org-roam-mode-map
;;                   (("C-c n l" . org-roam)
;;                    ("C-c n f" . org-roam-find-file)
;;                    ("C-c n g" . org-roam-show-graph))
;;                   :map org-mode-map
;;                   (("C-c n i" . org-roam-insert))
;;                   (("C-c n I" . org-roam-insert-immediate))))
;;   (use-package org-roam
;;   :ensure t
;;   :straight t
;;   :init
;;   (setq org-roam-v2-ack t) ;; disable v2 upgrade warning
;;   :custom
;;   (org-roam-directory (file-truename "~/Documents/org/org-roam/"))
;;   :bind (("C-c n l" . org-roam-buffer-toggle)
;;          ("C-c n f" . org-roam-node-find)
;;          ("C-c n g" . org-roam-graph)
;;          ("C-c n i" . org-roam-node-insert)
;;          ("C-c n c" . org-roam-capture)
;;          ;; Dailies
;;          ("C-c n j" . org-roam-dailies-capture-today))
;;   :config
;;   (org-roam-db-autosync-mode)
;;   ;; If using org-roam-protocol
;;   (require 'org-roam-protocol))

(require 'bind-key)
(use-package org-roam
  :ensure t
  :straight  (:host github :repo "org-roam/org-roam")
  :after org
  :init
  (setq org-roam-v2-ack t) ;; disable v2 upgrade warning
  :custom
  (org-roam-directory "~/Documents/org/org-roam/")
  ;;:bind (("C-c n l" . org-roam-buffer-toggle)
  ;;       ("C-c n f" . org-roam-node-find)
  ;;       ("C-c n i" . org-roam-node-insert))
  :config
  (org-roam-setup)
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n z" . gh/counsel-fzf-org-roam)
         ("C-c n g" . org-roam-graph)
         ("C-c n r" . counsel-rg)
         ("C-c n R" . org-roam-node-random)		    
         (:map org-mode-map
               (("C-c n i" . org-roam-node-insert)
                ("C-c n o" . org-id-get-create)
                ("C-c n t" . org-roam-tag-add)
                ("C-c n a" . org-roam-alias-add)
                ("C-c n l" . org-roam-buffer-toggle)
                )))
  )

(setq org-roam-completion-system 'vertico)
(setq org-roam-index-file "index.org")
(add-to-list 'exec-path "/etc/profiles/per-user/greghab/bin/sqlite3")

;;  (use-package objed
;;    :straight t
;;    :init
;;    (add-hook 'prog-mode-hook #'objed-local-mode)
;; (objed-mode))

;; (straight-use-package 'lsp-mode)

;; (straight-use-package 'lsp-ui)
;; (straight-use-package 'lsp-treemacs)
;; (straight-use-package 'helm-lsp)

;; (require 'lsp-mode)
;; (add-hook 'prog-mode-hook #'lsp)

;; (straight-use-package 'lsp-java)

;; (straight-use-package 'dap-mode)

(straight-use-package 'flycheck)

(straight-use-package 'company)
(straight-use-package 'company-lsp)

;; (tab-bar-mode 1)

;; (straight-use-package 'plantuml-mode)

;; Set your plantuml.jar path
;; (setq plantuml-jar-path (expand-file-name "~/nextcloud/data/extPrograms/plantuml.jar"))
;; (setq plantuml-jar-path "/home/greghab/nextcloud/data/extPrograms/plantuml.jar")

;; Change preview mode to jar
;; (setq plantuml-default-exec-mode 'jar)

;; (use-package plantuml-mode
;; :straight t
;; :init
;; (setq plantuml-java-args (list "-Djava.awt.headless=true" "-jar"))
;; (setq plantuml-default-exec-mode 'jar)
;; (setq plantuml-jar-path "/home/greghab/nextcloud/data/extPrograms/plantuml.jar")
;; (setq org-plantuml-jar-path (expand-file-name "/home/greghab/nextcloud/data/extPrograms/plantuml.jar"))
;; (setq org-startup-with-inline-images t)
;; (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
;; (org-babel-do-load-languages 'org-babel-load-languages '((plantuml . t))))

;; (use-package openwith
;;   :straight t
;;   :init
;;   (setq openwith-associations
;;         (list
;;          (list (openwith-make-extension-regexp
;;                 '("mpg" "mpeg" "mp3" "mp4"
;;                   "avi" "wmv" "wav" "mov" "flv"
;;                   "ogm" "ogg" "mkv"))
;;                "mpv"
;;                '(file))
;;          (list (openwith-make-extension-regexp
;;                 '("xbm" "pbm" "pgm" "ppm" "pnm"
;;                   "png" "gif" "bmp" "tif" "jpeg" "jpg"))
;;                "nomacs"
;;                '(file))
;;          (list (openwith-make-extension-regexp
;;                 '("doc" "docx" "xls" "ppt" "odt" "ods" "odg" "odp"))
;;                "libreoffice"
;;                '(file))
;;          '("\\.lyx" "lyx" (file))
;;          '("\\.chm" "kchmviewer" (file))
;;          (list (openwith-make-extension-regexp
;;                 '("pdf" "ps" "ps.gz" "dvi"))
;;                "evince"
;;                '(file))
;;          ))
;;   (openwith-mode)
;;   )

(setq large-file-warning-threshold nil)

;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Drag-and-Drop.html
(setq mouse-drag-and-drop-region t)

(use-package anki-editor
  :straight t
  :config
  (setq anki-editor-create-decks t)
  )

(straight-use-package 'hydra)

(straight-use-package 'websocket)
(defun my/twitch-message (text)
  (interactive "MText: ")
  (with-current-buffer
      (get-buffer-create "Twitch message")
    (erase-buffer)
    (insert text)
    (goto-char (point-min))))
(use-package obs-websocket
  :straight  (:host github :repo "sachac/obs-websocket-el")
  :config
  (defhydra my/obs-websocket (:exit t)
    "Control Open Broadcast Studio"
    ("c" (obs-websocket-connect) "Connect")
    ("d" (obs-websocket-send "SetCurrentScene" :scene-name "Desktop") "Desktop")
    ("e" (obs-websocket-send "SetCurrentScene" :scene-name "Emacs") "Emacs")
    ("i" (obs-websocket-send "SetCurrentScene" :scene-name "Intermission") "Intermission")
    ("v" (browse-url "https://twitch.tv/sachachua"))
    ("m" my/twitch-message "Message")
    ("t" my/twitch-message "Message")
    ("<f8>" my/twitch-message "Message") ;; Then I can just f8 f8
    ("sb" (obs-websocket-send "StartStreaming") "Stream - begin")
    ("se" (obs-websocket-send "StopStreaming") "Stream - end")
    ("rb" (obs-websocket-send "StartRecording") "Recording - begin"))
  (global-set-key (kbd "<f8>") #'my/obs-websocket/body))

(setq obs-websocket-url "ws://10.113.211.134:4455")
(setq obs-websocket-password "lmsENUYPBOTneS2W")

(use-package avy
   :straight t
   )

(use-package ivy-posframe 
  :straight t
  :init
  (setq ivy-posframe-parameters '((parent-frame nil)))
  (setq ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-bottom-left)))
  (ivy-posframe-mode 1))

(use-package vertico
  :straight t
  :init
  (vertico-mode 1))

(use-package vertico-posframe
  :straight t
  :init
  (require 'vertico-posframe)
  (vertico-posframe-mode 1))

(straight-use-package 'deadgrep)

;; (use-package helm-posframe
;;  :straight t
;;  :init
;;  (setq helm-posframe-parameters '((parent-frame nil)))
;;  (setq helm-posframe-display-functions-alist '((t . helm-posframe-display-at-frame-bottom-left)))
;;  (helm-posframe-enable)
;;  )

;;   (use-package ivy-rich
;; :straight t
;;    :init   
;;    (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)
;;
;;       (defun ivy-rich-switch-buffer-icon (candidate)
;;         (with-current-buffer
;;             (get-buffer candidate)
;;           (let ((icon (all-the-icons-icon-for-mode major-mode)))
;;            (if (symbolp icon)
;;                (all-the-icons-icon-for-mode 'fundamental-mode)
;;             icon))));

;;
;;       (setq ivy-rich-display-transformers-list
;;             '(ivy-switch-buffer
;;               (:columns
;;               ((ivy-rich-switch-buffer-icon (:width 2))
;;                (ivy-rich-candidate (:width 30))
;;                (ivy-rich-switch-buffer-size (:width 7))
;;               (ivy-rich-switch-buffer-indicators (:width 4 :face error :align right))
;;                (ivy-rich-switch-buffer-major-mode (:width 12 :face warning))
;;                (ivy-rich-switch-buffer-project (:width 15 :face success))
;;               (ivy-rich-switch-buffer-path (:width (lambda (x) (ivy-rich-switch-buffer-shorten-path x (ivy-rich-minibuffer-width 0.3))))))
;;                :predicate
;;                (lambda (cand) (get-buffer cand)))))
;;       (ivy-rich-mode 1)
;;      (ivy-rich-mode 0)
;;      (ivy-rich-mode 1)
;;      )

(straight-use-package 'ess)

(straight-use-package 'sudo-edit)

(straight-use-package 'projectile)
;; (projectile-mode +1)
;; (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
;; (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

(straight-use-package 'auctex)

(straight-use-package 'counsel)

(straight-use-package 'buffer-move)

(straight-use-package 'evil)
(straight-use-package 'evil-magit)

(use-package xah-fly-keys
  :straight t
  :config
  ;; (xah-fly-keys 1)
  (xah-fly-keys-set-layout 'programer-dvorak) ;; required
  )

(straight-use-package 'helm)
(straight-use-package 'helm-exwm)

(straight-use-package 'all-the-icons)

(use-package doom-modeline
  :straight t
  :init (doom-modeline-mode 1))

(straight-use-package 'erlang)

(straight-use-package 'nix-mode)

(straight-use-package 'meow)
(require 'meow) ;; https://github.com/meow-edit/meow/issues/162
(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-dvp)
  (meow-leader-define-key
   '("?" . meow-cheatsheet))
  (meow-motion-overwrite-define-key
   ;; custom keybinding for motion state
   '("<escape>" . ignore))
  (meow-normal-define-key
   '("?" . meow-cheatsheet)
   '("*" . meow-expand-0)
   '("=" . meow-expand-9)
   '("!" . meow-expand-8)
   '("[" . meow-expand-7)
   '("]" . meow-expand-6)
   '("{" . meow-expand-5)
   '("+" . meow-expand-4)
   '("}" . meow-expand-3)
   '(")" . meow-expand-2)
   '("(" . meow-expand-1)
   '("1" . digit-argument)
   '("2" . digit-argument)
   '("3" . digit-argument)
   '("4" . digit-argument)
   '("5" . digit-argument)
   '("6" . digit-argument)
   '("7" . digit-argument)
   '("8" . digit-argument)
   '("9" . digit-argument)
   '("0" . digit-argument)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("<" . meow-beginning-of-thing)
   '(">" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-line)
   '("E" . meow-goto-line)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-join)
   '("k" . meow-kill)
   '("l" . meow-till)
   '("m" . meow-mark-word)
   '("M" . meow-mark-symbol)
   '("n" . meow-next)
   '("N" . meow-next-expand)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-prev)
   '("P" . meow-prev-expand)
   '("q" . meow-quit)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-search)
   '("t" . meow-right)
   '("T" . meow-right-expand)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-next-word)
   '("W" . meow-next-symbol)
   '("x" . meow-save)
   '("X" . meow-sync-grab)
   '("y" . meow-yank)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

;;(meow-global-mode 1)

;; (use-package elpy
;; :straight t
;; :init
;; (elpy-enable))

(straight-use-package 'vterm)
(straight-use-package 'multi-vterm)

(use-package rustic
  :straight t
  :custom
  (rustic-analyzer-command '("rustup" "run" "stable" "rust-analyzer")))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rustic-mode))

(add-hook 'rust-mode-hook 'lsp-deferred)



;;                       ;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 100 1024 1024)) ;; 100 MB
(setq read-process-output-max (* 1 1024 1024)) ;; 1 MB
(setq python-shell-interpreter "python3")

;;                    (straight-use-package 'no-littering)

;;                     ;; no-littering doesn't set this by default so we must place
;;                     ;; auto save files in the same path as it uses for sessions
;;                     (setq auto-save-file-name-transforms
;;                           `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(use-package lsp-mode
  :straight t
  :commands (lsp lsp-deferred)
  :hook 
  (lsp-mode . lsp-enable-which-key-integration)
  :custom
  (lsp-diagnostics-provider :capf)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-headerline-breadcrumb-segments '(project file symbols))
  (lsp-lens-enable nil)
  (lsp-disabled-clients '((python-mode . pyls)))
  :init
  (setq lsp-keymap-prefix "C-c l") ;; Or 'C-l', 's-l'
  :config
  )

(use-package lsp-ivy
  :straight t
  :after lsp-mode
  )

(use-package lsp-ui
  :straight t
  :hook (lsp-mode . lsp-ui-mode)
  :after lsp-mode
  :custom
  (lsp-ui-doc-show-with-cursor nil)
  :config
  (setq lsp-ui-doc-position 'bottom)
  )

(use-package lsp-treemacs
  :straight t
  :after (lsp-mode treemacs)
  )


(use-package lsp-pyright
  :straight t
  :hook
  (python-mode . (lambda ()
                   (require 'lsp-pyright)
                   (lsp-deferred))))

(use-package blacken
  :straight t
  :init
  (setq-default blacken-fast-unsafe t)
  (setq-default blacken-line-length 80)
  )

;;(use-package pyvenv
;; :straight t
;;   :ensure t
;;   :init
;;   (setenv "WORKON_HOME" "~/.venvs/")
;;   :config
;;   ;; (pyvenv-mode t)

;;   ;; Set correct Python interpreter
;;   (setq pyvenv-post-activate-hooks
;;         (list (lambda ()
;;                 (setq python-shell-interpreter (concat pyvenv-virtual-env "bin/python")))))
;;   (setq pyvenv-post-deactivate-hooks
;;         (list (lambda ()
;;                 (setq python-shell-interpreter "python3")))))

;;       (use-package python-mode
;;   :straight t
;;         :hook
;;         (python-mode . pyvenv-mode)
;;         (python-mode . flycheck-mode)
;;         (python-mode . company-mode)
;;         (python-mode . blacken-mode)
;;         (python-mode . yas-minor-mode)
;;         :custom
;;         ;; NOTE: Set these if Python 3 is called "python3" on your system!
;;         (python-shell-interpreter "python3")
;;         :config
;;         )

;;(lsp-register-client
;;(make-lsp-client :new-connection
;;    (lsp-stdio-connection '("R" "--slave" "-e" "languageserver::run()"))
;;    :major-modes '(ess-r-mode inferior-ess-r-mode)
;;    :server-id 'lsp-R))



;; Reddit stuff (missing pyenv local package to get it to work):

;;      (use-package blacken
;;        :straight t
;;        :delight
;;        :hook (python-mode . blacken-mode)
;;        :custom (blacken-line-length 79))


;;      (use-package dap-mode
;;        :straight t 
;;        :after lsp-mode
;;        :config
;;        (dap-mode t)
;;        (dap-ui-mode t))

;; (use-package lsp-pyright
;;   :ensure t
;;   :recipe (:host github :repo "emacs-lsp/lsp-mode"))

;;  ;    (use-package lsp-pyre
;;  ;      :straight t
;;  ;      : after python
;;  ;      :hook (python-mode . (lambda ()
;; ;			      (require 'lsp-pyre)
;; ;			      (lsp))))

;;      (use-package py-isort
;;        :straight t
;;        :after python
;;        :hook ((python-mode . pyvenv-mode)
;;               (before-save . py-isort-before-save)))

;;      (use-package pyenv-mode
;;        :straight t
;;        :after python
;;        :hook ((python-mode . pyenv-mode)
;;               (projectile-switch-project . projectile-pyenv-mode-set))
;;        :custom (pyenv-mode-set "3.8.5")
;;        :preface
;;        (defun projectile-pyenv-mode-set ()
;;          "Set pyenv version matching project name."
;;          (let ((project (projectile-project-name)))
;;            (if (member project (pyenv-mode-versions))
;;                (pyenv-mode-set project)
;;              (pyenv-mode-unset)))))

;;      (use-package pyvenv
;;        :straight t
;;        :after python
;;        :hook (python-mode . pyvenv-mode)
;;        :custom
;;        (pyvenv-default-virtual-env-name "env")
;;        (pyvenv-mode-line-indicator '(pyvenv-virtual-env-name ("[venv:"
;;                                                               pyvenv-virtual-env-name "]"))))

;;    ;; https://vxlabs.com/2018/06/08/python-language-server-with-emacs-and-lsp-mode/

;; (use-package lsp-mode
;;   :ensure t
;;   :config

;;   ;; make sure we have lsp-imenu everywhere we have LSP
;;   (require 'lsp-imenu)
;;   (add-hook 'lsp-after-open-hook 'lsp-enable-imenu)  
;;   ;; get lsp-python-enable defined
;;   ;; NB: use either projectile-project-root or ffip-get-project-root-directory
;;   ;;     or any other function that can be used to find the root directory of a project
;;   (lsp-define-stdio-client lsp-python "python"
;;                            #'projectile-project-root
;;                            '("pyls"))

;;   ;; make sure this is activated when python-mode is activated
;;   ;; lsp-python-enable is created by macro above 
;;   (add-hook 'python-mode-hook
;;             (lambda ()
;;               (lsp-python-enable)))

;;   ;; lsp extras
;;   (use-package lsp-ui
;;     :ensure t
;;     :config
;;     (setq lsp-ui-sideline-ignore-duplicate t)
;;     (add-hook 'lsp-mode-hook 'lsp-ui-mode))

;;   (use-package company-lsp
;;     :config
;;     (push 'company-lsp company-backends))

;;   ;; NB: only required if you prefer flake8 instead of the default
;;   ;; send pyls config via lsp-after-initialize-hook -- harmless for
;;   ;; other servers due to pyls key, but would prefer only sending this
;;   ;; when pyls gets initialised (:initialize function in
;;   ;; lsp-define-stdio-client is invoked too early (before server
;;   ;; start)) -- cpbotha
;;   (defun lsp-set-cfg ()
;;     (let ((lsp-cfg `(:pyls (:configurationSources ("flake8")))))
;;       ;; TODO: check lsp--cur-workspace here to decide per server / project
;;       (lsp--set-configuration lsp-cfg)))

;;   (add-hook 'lsp-after-initialize-hook 'lsp-set-cfg))

(straight-use-package 'lsp-java)
;(require 'lsp-java)
(add-hook 'java-mode-hook #'lsp)

;; https://github.com/daviwil/emacs-from-scratch/blob/210e517353abf4ed669bc40d4c7daf0fabc10a5c/Emacs.org#debugging-with-dap-mode
(scroll-bar-mode -1)        ;; Disable visible scrollbar
(tool-bar-mode -1)          ;; Disable the toolbar
(tooltip-mode -1)           ;; Disable tooltips
(set-fringe-mode 10)        ;; Give some breathing room
(menu-bar-mode -1)            ;; Disable the menu bar
;; Set up the visible bell
(setq visible-bell t)

;; (column-number-mode)
;; (global-display-line-numbers-mode t)

;; ;; Disable line numbers for some modes
;; (dolist (mode '(org-mode-hook
;;                           term-mode-hook
;;                           shell-mode-hook
;;                                   treemacs-mode-hook
;;                           eshell-mode-hook))
;;             (add-hook mode (lambda () (display-line-numbers-mode 0))))


(use-package dap-mode
:straight t)
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;;:custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)

;;   :config
;;   ;; Set up Node debugging
;;   (require 'dap-python)
;;   (dap-python-setup) ;; Automatically installs Node debug adapter if needed

(require 'dap-python)
;;(require 'dap-java)
;; if you installed debugpy, you need to set this
;; https://github.com/emacs-lsp/dap-mode/issues/306

;; pip install --user debugpy
(setq dap-python-debugger 'debugpy)

;;   ;; Bind `C-c l d` to `dap-hydra` for easy access
;;   (general-define-key
;;     :keymaps 'lsp-mode-map
;;     :prefix lsp-keymap-prefix
;;     "d" '(dap-hydra t :wk "debugger")))

(require 'dap-lldb)
(require 'dap-gdb-lldb)

(dap-register-debug-template "Rust::GDB Run Configuration"
                             (list :type "gdb"
                                   :request "launch"
                                   :name "GDB::Run"
                           :gdbpath "rust-gdb"
                                   :target nil
                                   :cwd nil))


;; https://robert.kra.hn/posts/rust-emacs-setup/
  (dap-register-debug-template
   "Rust::LLDB Run Configuration"
   (list :type "lldb"
         :request "launch"
         :name "LLDB::Run"
	 :gdbpath "rust-lldb"
         :target nil
         :cwd nil))

;; https://gagbo.net/post/dap-mode-rust/
  (setq dap-cpptools-extension-version "1.5.1")

  (with-eval-after-load 'lsp-rust
    (require 'dap-cpptools))

  (with-eval-after-load 'dap-cpptools
    ;; Add a template specific for debugging Rust programs.
    ;; It is used for new projects, where I can M-x dap-edit-debug-template
    (dap-register-debug-template "Rust::CppTools Run Configuration"
                                 (list :type "cppdbg"
                                       :request "launch"
                                       :name "Rust::Run"
                                       :MIMode "gdb"
                                       :miDebuggerPath "rust-gdb"
                                       :environment []
                                       :program "${workspaceFolder}/target/debug/hello / replace with binary"
                                       :cwd "${workspaceFolder}"
                                       :console "external"
                                       :dap-compilation "cargo build"
                                       :dap-compilation-dir "${workspaceFolder}")))

(blink-cursor-mode 0)

;(dashboard-setup-startup-hook)
;(setq dashboard-banner-logo-title "Welcome to Emacs Dashboard")
;(setq dashboard-startup-banner "/home/greghab/data/backgrounds/stephen-snippet.png")
;(setq dashboard-center-content t)
;(setq dashboard-show-shortcuts nil)
;(setq dashboard-items '((recents  . 5)
 ;                       (bookmarks . 5)
;                        (projects . 5)
;                        (agenda . 5)
;                        (registers . 5)))
;(add-to-list 'dashboard-items '(agenda) t)
;(setq show-week-agenda-p t)

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
kept-new-versions 6
kept-old-versions 2
version-control t)

(org-babel-do-load-languages
         'org-babel-load-languages
         '(
           (latex . t)
           (lua . t)
           (python . t)
           (shell . t)
           (scheme . t)
           (sql . t)
           )
         )
   ;; https://emacs.stackexchange.com/a/41865
   ;; https://emacs.stackexchange.com/questions/39390/force-org-to-use-instead-of-begin-example-for-source-block-output
   (setq org-babel-min-lines-for-block-output 1)
(setq geiser-scheme-implementation 'guile)
           ;;https://stackoverflow.com/questions/11670654/how-to-resize-images-in-org-mode
           ;; Allows the re-sizing of attached images in org-mode
           ;(setq org-image-actual-width nil)

           (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

           ;; Dynamic TILING SETUP
           ;; https://github.com/roman/golden-ratio.el
           ;; https://old.reddit.com/r/emacs/comments/apt8fv/exwm_dynamic_tiling/
           ;;(golden-ratio-mode 1)

           ;; modeline icons
          ; (mode-icons-mode)


           ;; Uses mini-modeline
           ;; Reduces vertical spaces 
           ;; (Less vertical space + merges exwm-systray + modeline together) + adds clock
           ;; Awesome!!
           ;(setq mini-modeline-color "black")
           ;(mini-modeline-mode)

           ;; Custom Font
           ;;(set-fontset-font t 'han "dina" nil 'prepend)
         ;  (add-to-list 'default-frame-alist
         ;  '(font . "Dina-12"))

           ;; uses spaces instead of tabs when indenting
           (setq-default indent-tabs-mode nil)



           ;; Org-Babel Haskell setup
         ;  (require 'ob-haskell)


           ;(setq yas-snippet-dirs (append yas-snippet-dirs
           ;                            '("/home/toreshi/.emacs.d/snippets/latex-mode/")))

           ;(setq yas-snippet-dirs '("/~//.emacs.d/snippets/latex-mode/"))
        ;(require 'yasnippet)

;(package-initialize)
     (pdf-tools-install)

      ;; Use pdf-tools to open PDF files
     (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-source-correlate-start-server t)

        ;; Update PDF buffers after successful LaTeX runs
        (add-hook 'TeX-after-compilation-finished-functions
        #'TeX-revert-document-buffer)

        (setq backup-directory-alist `(("." . "~/.saves")))
        (setq backup-by-copying t)

        (setq delete-old-versions t
        kept-new-versions 6
        kept-old-versions 2
        version-control t)

;; Make highlight color more visible in 'midnight-mode'
;; https://github.com/politza/pdf-tools/issues/581
;; This will change the color of the annotation.
(setq pdf-annot-default-markup-annotation-properties
      '((color . "magenta")))

;; https://github.com/nicolaisingh/saveplace-pdf-view
  ;;  (straight-use-package 'saveplace-pdf-view) ;; read epubs 
  ;;(save-place-mode 1)

(straight-use-package 'pdf-view-restore)
(add-hook 'pdf-view-mode-hook 'pdf-view-restore-mode)
(setq pdf-view-restore-filename "~/.emacs.scratch/.pdf-view-restore")

(custom-set-variables
    ;; custom-set-variables was added by Custom.
    ;; If you edit it by hand, you could mess it up, so be careful.
    ;; Your init file should contain only one such instance.
    ;; If there is more than one, they won't work right.
    '(ansi-color-faces-vector
      [default default default italic underline success warning error])
    '(ansi-color-map (ansi-color-make-color-map) t)
    '(ansi-color-names-vector
      ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
    '(company-quickhelp-color-background "#4F4F4F")
    '(company-quickhelp-color-foreground "#DCDCCC")
    '(custom-enabled-themes (quote (inkpot)))
    '(custom-safe-themes
      (quote
       ("f27c3fcfb19bf38892bc6e72d0046af7a1ded81f54435f9d4d09b3bff9c52fc1" "12dd37432bb454355047c967db886769a6c60e638839405dad603176e2da366b" "3d5ef3d7ed58c9ad321f05360ad8a6b24585b9c49abcee67bdcbb0fe583a6950" "58c6711a3b568437bab07a30385d34aacf64156cc5137ea20e799984f4227265" "72a81c54c97b9e5efcc3ea214382615649ebb539cb4f2fe3a46cd12af72c7607" "ef98b560dcbd6af86fbe7fd15d56454f3e6046a3a0abd25314cfaaefd3744a9e" "cd4d1a0656fee24dc062b997f54d6f9b7da8f6dc8053ac858f15820f9a04a679" "e9776d12e4ccb722a2a732c6e80423331bcb93f02e089ba2a4b02e85de1cf00e" "02591317120fb1d02f8eb4ad48831823a7926113fa9ecfb5a59742420de206e0" "f88973210f0bde1447a84a26df012d61430024d93fcc16026e71636c4a535b24" "3cc2385c39257fed66238921602d8104d8fd6266ad88a006d0a4325336f5ee02" "fc524ddf651fe71096d0012b1c34d08e3f20b20fb1e1b972de4d990b2e793339" "c4d3cbd4f404508849e4e902ede83a4cb267f8dff527da3e42b8103ec8482008" "f9567e839389f2f0a1ede73d1c3e3bd2c9ed93adaf6bb7d13e579ea2b15fcef8" "5123a2b0f710f2646bfe8d96cb8bf13d626f51a1ea3f91d02b8ae56cb6477bbb" "3a5f04a517096b08b08ef39db6d12bd55c04ed3d43b344cf8bd855bde6d3a1ae" "5a21604c4b1f2df98e67cda2347b8f42dc9ce471a48164fcb8d3d52c3a0d10be" "77cbe2470bedee499d32762495f821adc7080a9ef16e8ba5b4b74232642b217c" "3cd28471e80be3bd2657ca3f03fbb2884ab669662271794360866ab60b6cb6e6" "7a42b7cddbc89b6f6032eb7faadf7de675e25e9d577402801575098011bcc86c" "5a51b327986b4058f5978d2d9a6a421eaac7c57b8eec5960ef34f432feff080d" "e0d42a58c84161a0744ceab595370cbe290949968ab62273aed6212df0ea94b4" "3bf336a4b70c64f133d98c0e72105b577ec13d8f6911c34ba97767ee29b0c558" "bf7f4fb05a45eae1a6bc1a009b7731b09260d945ec4c3c4ed7f5da06647a7946" "bd422ad7ab0655a122b98c1817ac5eb63cc7439831be3a225f525504dbe43431" "987b709680284a5858d5fe7e4e428463a20dfabe0a6f2a6146b3b8c7c529f08b" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "b1d7c140dfbd88361f689fd1c6be4023641dde001904add1996ab7e17618373f" "f3f85a358dc6c3642bc6e0ca335c8909a2210814e5a7d4301993822bbf7db4e6" "c48551a5fb7b9fc019bf3f61ebf14cf7c9cdca79bcb2a4219195371c02268f11" "43b0db785fc313b52a42f8e5e88d12e6bd6ff9cee5ffb3591acf51bbd465b3f4" "d74183b099f4e91052941ef3131c76697caae3fcf581f4c140216a7c6e6d71e2" "9ab46512b8b69478b057f79d0eb0faee61d19e53917a868a14e41bf357cee6d4" "96998f6f11ef9f551b427b8853d947a7857ea5a578c75aa9c4e7c73fe04d10b4" "5e1d1564b6a2435a2054aa345e81c89539a72c4cad8536cfe02583e0b7d5e2fa" "420459d6eeb45aadf5db5fbcc3d6990b65141c104911f7359454fc29fa9d87a0" "b62e6fde6217bbbff61c5f504a5205c6adfbb69ffa40153a0ff47f6a047f1008" "fa11ec1dbeb7c54ab1a7e2798a9a0afa1fc45a7b90100774d7b47d521be6bfcf" "f8cf128fa0ef7e61b5546d12bb8ea1584c80ac313db38867b6e774d1d38c73db" "b3775ba758e7d31f3bb849e7c9e48ff60929a792961a2d536edec8f68c671ca5" "9b59e147dbbde5e638ea1cde5ec0a358d5f269d27bd2b893a0947c4a867e14c1" "c725b8bfe386a69814e1f11ab52eb298862ae6b0732989bdb76d36ee29c94a7d" "e7155290782f6f7285fd8bbedc0467662bf9f4e5151a1b867430bcde94221a2d" "11c589e10111615c2273ca6fe5a089ae6176a5c267a3d4d4ca74e076deb64845" "1bb8cd5aef0f6f5747987136039c668d3f1038fb9a8b0c302ca369836e5e9406" "032d5dc72a31ebde5fae25a8c1ef48bac6ba223588a1563d10dbf3a344423879" "118e5a60fbb4e13304bc967d61345a7fbdc956a5976e3e07b2f317b3dff55a46" "c479b533582d7a96208eb2ec347d1a75499703351fde4c16a7fefa6784d7e62f" "c44056a7a2426e1229749e82508099ba427dde80290da16a409d5d692718aa11" "52974e923c79ee2e5de05b5f60950f20b25ed0a1929df7f402f59dd6db7d511f" "e5db25f43c0078e14f813981f4edf1770713b98c2151a968f465f8847322b60c" "12480cb5731d444135d26a054b3c838869c3005c82eb806a119b71b0fc4bb542" "3df0b79d328c27a8fb8115c14b98d4aa0ef4c83858a897f22a905c4df44ac542" "0ebf41626ae2af9834f2729e56e1c3d400c6edc0e1599617d953f8a46a54f1e6" "4c13cb163f65eea2566870af6283820c0bb19d1de81e142a5a931e675ff86594" "113c71650a4296f6cb12a3913a17cac4ca427ff6b0b8b18c2435c71fb1e30ba0" "998aec317c45ba985ca740770a30cfc5e2ec3a8d5c0d626c011bfcd11f7dabd0" "3b69ddebc3b1386c63e70afa0eca90d1a775c52ad144d16df932400f3afe1c30" "68b24331fa3f0b965306548a0bcf79601a02a6947eb78c66a206abab0a5fb1c5" "be6b4a800ab76dd9f3c08745b8dc88dbb87cfe0893d4edd32ad9fc1ad5f116d1" "1b50dab3a50c8ee9393e389272e6243844ffa597d17878bfef10bf6140bdc67a" "d9ebde897e742907261a4170f447dccc7f7061b13865ba5b6b9cc7a55af8abde" "6cd8802e31b8d5c169a8043f953d34b9972ee69241678a46970140c644960c7b" "d8daf85f7c4dd19fe04914394499fb867908917fce466c9cb675218f7928647e" "de084d0f1478b24e0b4dc364a146709259cac3aa0769056871933a864057dbc4" "b8bbf590fcbea735d6dbdcb5cb608228616d2d359e3c3d82e5ba99e0d0134d58" "138d69908243e827e869330c43e7abc0f70f334dfa90a589e4d8a1f98a1e29af" "4c1bea1ef3301f3a19e2f67810509e10ffd40bbb4901c743bd8698e910519623" "f87f74ecd2ff6dc433fb4af4e76d19342ea4c50e4cd6c265b712083609c9b567" "c1de07961a3b5b49bfd50080e7811eea9c949526084df8d64ce1b4e0fdc076ff" "2caab17a07a40c1427693d630adb45f5d6ec968a1771dcd9ea94a6de5d9f0838" "b1ceefa6ae7c2e6eb33ea1dd07a17ebdcd3de75c693c5ed0358f6b193d7af04d" "e0c66085db350558f90f676e5a51c825cb1e0622020eeda6c573b07cb8d44be5" default)))
                                           ;'(edwina-mode t)
    '(fci-rule-color "#4c406d")
    '(hl-paren-colors
      (quote
       ("#B9F" "#B8D" "#B7B" "#B69" "#B57" "#B45" "#B33" "#B11")))
    '(ibuffer-deletion-face (quote diredp-deletion-file-name))
    '(ibuffer-marked-face (quote diredp-flag-mark))
    '(inhibit-startup-screen t)
    '(linum-format " %5i ")
    '(nrepl-message-colors
      (quote
       ("#ee11dd" "#8584ae" "#b4f5fe" "#4c406d" "#ffe000" "#ffa500" "#ffa500" "#DC8CC3")))
    '(org-agenda-files nil)
    '(org-agenda-tags-column 40)
'(org-format-latex-options
  '(:foreground default :background "Black" :scale 1.5 :html-foreground "Black" :html-background "Transparent" :html-scale 1.0 :matchers
                ("begin" "$1" "$" "$$" "\\(" "\\[")))
    '(org-modules
      (quote
       (org-habit org-drill)))
    '(package-selected-packages
      (quote
       (libmpdee mpdel edwin avy deft org-drill xah-math-input emacs-setup vterm buffer-move exwm-edit exwm-x org-drill-table auctex-latexmk sage-shell-mode workgroups hledger-mode simple-httpd skewer-mode axiom-environment omni-quotes xml-quotes org-pomodoro exwm direx magit nov xclip all-the-icons neotree podcaster org-timeline rmsbolt yasnippet-snippets htmlize company-suggest company-irony irony bongo emms-player-mpv emms mentor elfeed-org pdf-tools checkbox org-journal calfw-org calfw org-super-agenda projectile load-relative realgud meghanada aggressive-indent creamsody-theme darktooth-theme org-noter haskell-mode ## auctex org-edna)))
    '(pdf-tools-enabled-hook (quote (pdf-view-midnight-minor-mode)))
    '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
    '(pos-tip-background-color "#1A3734")
    '(pos-tip-foreground-color "#FFFFC8")
    '(rainbow-identifiers-choose-face-function (quote rainbow-identifiers-cie-l*a*b*-choose-face))
    '(rainbow-identifiers-cie-l*a*b*-color-count 1024)
    '(rainbow-identifiers-cie-l*a*b*-lightness 80)
    '(rainbow-identifiers-cie-l*a*b*-saturation 25)
    '(vc-annotate-background "#0bafed")
    '(vc-annotate-color-map
      (quote
       ((20 . "#BC8383")
        (40 . "#ee11dd")
        (60 . "#8584ae")
        (80 . "#ffe000")
        (100 . "#efef80")
        (120 . "#b4f5fe")
        (140 . "#4c406d")
        (160 . "#4c406d")
        (180 . "#1b1a24")
        (200 . "#4c406d")
        (220 . "#65ba08")
        (240 . "#ffe000")
        (260 . "#ffa500")
        (280 . "#6CA0A3")
        (300 . "#0bafed")
        (320 . "#8CD0D3")
        (340 . "#ffa500")
        (360 . "#DC8CC3"))))
    '(vc-annotate-very-old-color "#DC8CC3"))
   ;;(package-initialize)




         ;;;
         ;;; Org Mode
         ;;;
   ;;(add-to-list 'load-path (expand-file-name "~/git/org-mode/lisp"))
   ;;(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))
   (require 'org-install)
   (require 'org-habit)
   (setq org-agenda-files '("~/nextcloud/documents/org/"))
   ;;(setq org-agenda-files '("~/Documents/org/life/"))


   ;;(package-initialize)


   ;;(load "exwm-panel.el")

   ;;(require 'exwm-panel)


   (menu-bar-mode 0)
   (column-number-mode 1)
   (tool-bar-mode 0)
   (scroll-bar-mode -1)
   ;;(global-linum-mode t)
   (setq default-tab-width 3)
   (setq tab-width 4)


                                           ; (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
                                           ; '(bold ((t (:foreground "PaleVioletRed2" :weight bold))))
                                           ; '(italic ((t (:foreground "Plum2" :slant italic))))
                                           ; '(underline ((t (:foreground "HotPink2" :underline t)))))

   ;;(require 'org-super-agenda)
   ;;(org-super-agenda-mode)

   ;;(let ((org-super-agenda-groups
   ;;       '((:auto-group t))))
   ;;  (org-agenda-list))

   ;;(require 'calfw)
   ;;(require 'calfw-org)

   ;;(org-habit-show-habits-only-for-today t)
   ;; Load elfeed-org
   ;;(require 'elfeed-org)

   ;; Initialize elfeed-org
   ;; This hooks up elfeed-org to read the configuration when elfeed
   ;; is started with =M-x elfeed=
   ;;(elfeed-org)

   ;; Optionally specify a number of files containing elfeed
   ;; configuration. If not set then the location below is used.
   ;; Note: The customize interface is also supported.
   ;;(setq rmh-elfeed-org-files (list "~/documents/zen/elfeed.org"))
   ;;(setq rmh-elfeed-org-files (list "~/.emacs.scratch/elfeed.org"))



   ;;(add-to-list 'load-path "~/dev/gl/tidal")
   ;;(require 'tidal)

   ;;(require 'package)
   ;;(add-to-list 'package-archives 
   ;;    '("marmalade" .
   ;;      "http://marmalade-repo.org/packages/"))
   ;;(package-initialize)

                                           ;(require 'package)
                                           ;(setq package-archives
                                           ;      `(,@package-archives
                                           ;        ("melpa" . "https://melpa.org/packages/")
   ;; ("marmalade" . "https://marmalade-repo.org/packages/")
                                           ;        ("org" . "https://orgmode.org/elpa/")
   ;; ("user42" . "https://download.tuxfamily.org/user42/elpa/packages/")
   ;; ("emacswiki" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/emacswiki/")
   ;; ("sunrise" . "http://joseito.republika.pl/sunrise-commander/")
                                           ;        ))

   ;; load emacs 24's package system. Add MELPA repository.
                                           ;  (when (>= emacs-major-version 24)
                                           ; (require 'package)
                                           ;(add-to-list
                                           ;'package-archives
   ;; '("melpa" . "http://stable.melpa.org/packages/") ; many packages won't show if using stable
                                           ;'("melpa" . "http://melpa.milkbox.net/packages/")
                                           ; t))

                                           ; (package-initialize)



   ;; (require 'tidal)
   ;; (setq tidal-interpreter "/usr/bin/ghci")

                                           ;(require 'org-noter)

   ;;(require 'org-bullets)
   ;;(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))



   (setq org-tag-faces
         '(("c" . (:foreground "#C83737"))
           ("lec" . (:foreground "#BEB7C8"))
           ("oh" . (:foreground "#53536C"))
           ("exam" . (:foreground "#FF8080"))
           ("tut" . (:foreground "#E9C6AF"))
           ("chem"  . (:foreground "#FFCCAA"))
           ("la"  . (:foreground "#AAEEFF"))
           ("due"  . (:foreground "#DDAFE9"))))

   (setq org-category-faces
         '(("prog" . (:foreground "#C83737"))
           ("chem"  . (:foreground "#FFCCAA"))
           ("alge"  . (:foreground "#AAEEFF"))
           ("due"  . (:foreground "#FF80E5"))))

   (add-hook 'org-agenda-finalize-hook 'org-timeline-insert-timeline :append)

   (setq org-agenda-window-setup 'current-window)

   ;;(add-hook 'after-init-hook 'org-agenda-list)
   (setq org-agenda-scheduled-leaders '("" ""))

   ;;(setq org-agenda-prefix-format "%c %s %t %s");
   (setq org-agenda-prefix-format "%c %t ");
   ;;(setq org-agenda-prefix-format "              %t ");

   ;;(setq org-agenda-hide-tags-regexp "c\\|chem\\|la\\|due")

                                           ;(require 'calfw-org)

;  (require 'smtpmail)
  
   ; smtp
 ;  (setq message-send-mail-function 'smtpmail-send-it
 ;  smtpmail-starttls-credentials
 ;  '(("mail.disroot.org" 587 nil nil))
;   smtpmail-default-smtp-server "mail.disroot.org"
;   smtpmail-smtp-server "mail.disroot.org"
;   smtpmail-smtp-service 587
;   smtpmail-debug-info t)
   
   ;;(require 'mu4e)
   
   
;;(setq mu4e-maildir (expand-file-name "~/data/appData/mu/mail/disroot-fxkrait"))

;;(setq mu4e-maildir "/home/toreshi/data/appData/mu/mail/"
  ;    mu4e-contexts
  ;  `( ,(make-mu4e-context
 ;        :name "fxkrait"
   ;      :match-func (lambda (msg) (when msg (mu4e-message-contact-field-matches msg :to "fxkrait@disroot.org")))
  ;       :vars '((mu4e-trash-folder      . "/fxkrait/Trash/")
  ;               (mu4e-sent-folder      . "/fxkrait/Sent/")
  ;               (mu4e-drafts-folder      . "/fxkrait/Drafts/")
  ;               (mu4e-get-mail-command . "mbsync fxkrait")
                 
  ;              ))
 ; ,(make-mu4e-context
 ;        :name "thisisvoid"
    ;     :match-func (lambda (msg) (when msg (mu4e-message-contact-field-matches msg :to "thisisvoid@disroot.org")))
   ;      :vars '((mu4e-trash-folder      . "/thisisvoid/Trash/")
   ;              (mu4e-sent-folder      . "/thisisvoid/Sent/")
   ;              (mu4e-drafts-folder      . "/thisisvoid/Drafts/")
   ;              (mu4e-get-mail-command . "mbsync thisisvoid")
                 
   ;             ))
;  ))
;
;; (setq mu4e-drafts-folder "/Drafts")
;; (setq mu4e-sent-folder   "/Sent")
;; (setq mu4e-trash-folder  "/Trash")
;(setq message-signature-file "~/.emacs.d/.signature") ; put your signature in this file

; get mail
;(setq mu4e-get-mail-command "mbsync -a"
  ;    mu4e-html2text-command "w3m -T text/html"
  ;    mu4e-update-interval 120
 ;     mu4e-headers-auto-update t
 ;     mu4e-compose-signature-auto-include nil)

;(setq mu4e-maildir-shortcuts
; '( ("/Archives/"          . ?a)
;    ("/inbox/"               . ?i)
 ;   ("/Sent/"   . ?s)
;    ("/Trash/"       . ?t)
;    ("/Drafts/"    . ?d)
;  ))
  
;; show images
;(setq mu4e-view-show-images t)

;; use imagemagick, if available
;(when (fboundp 'imagemagick-register-types)
 ; (imagemagick-register-types))

;; general emacs mail settings; used when composing e-mail
;; the non-mu4e-* stuff is inherited from emacs/message-mode
;(setq mu4e-compose-reply-to-address "fxkrait@disroot.org"
 ;   user-mail-address "fxkrait@disroot.org"
 ;   user-full-name  "Gregory Hablutzel")

;; don't save message to Sent Messages, IMAP takes care of this
; (setq mu4e-sent-messages-behavior 'delete)

;; spell check
;(add-hook 'mu4e-compose-mode-hook
;(defun my-do-compose-stuff ()
;"My settings for message composition."
;(set-fill-column 72)
;(flyspell-mode)))



;(setq mu4e-html2text-command "iconv -c -t utf-8 | pandoc -f html -t plain")

;(add-to-list 'mu4e-view-actions '("view in browser" . mu4e-action-view-in-browser))

;   (require 'ess-site)

;; use xetex for utf support
             ;; https://tex.stackexchange.com/questions/21200/auctex-and-xetex
             ;;(setq-default TeX-engine 'xetex)
             (setq-default TeX-engine 'xetex)

             (setq pdf-misc-print-programm-args `("-o landscape" "-o sides=two-sided-short-edge" "-o page-ranges=1-" "-P"  ,printer-name))

             (setq pdf-misc-print-programm lpr-command)
             (setq ps-lpr-command "print_preview")

          ;   (require 'yasnippet)
            ; (yas-global-mode 1)
          (setq yas-snippet-dirs
                '("~/.emacs.scratch/snippets/"                 ;; personal snippets
                  "~/.emacs.scratch/straight/repos/yasnippet-snippets/snippets/" ;; the yasmate collection
                  ))

          (yas-global-mode 1) ;; or M-x yas-reload-all if you've started YASnippet already.

     ;https://www.lvguowei.me/post/emacs-orgmode-minted-setup/
     (setq org-latex-listings 'minted
           org-latex-packages-alist '(("" "minted"))
           org-latex-pdf-process
           '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
             "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
             "pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

                                        ;Prevent src block line too long
(setq org-latex-minted-options '(("breaklines" "true")
                                 ("breakanywhere" "true")
                                 ("fontfamily" "helvetica")
                                 ("fontsize" "\\small")))

          ;(setf (nth 1 (assoc "LaTeX" TeX-command-list))
          ;      "%`%l -interaction=nonstopmode %(mode)%' -shell-escape %t -8bit")

          ;(setf (nth 1 (assoc "LaTeX" TeX-command-list))
          ;      "%`%l -interaction=nonstopmode %(mode)%' -shell-escape ")

          (defun latex-compile ()
              (interactive)
              (save-buffer)
              (TeX-command "LaTeX" 'TeX-master-file))

              ;; Set PDF-Tools as default view output for C-c
              ;;https://old.reddit.com/r/emacs/comments/3sitj4/how_can_i_configure_auctex_to_set_pdftools_as_the/
              (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
              TeX-source-correlate-start-server t)

(use-package elfeed
                    :straight t
                    )

              (setq elfeed-feeds
                        '(("https://irreal.org/blog/?feed=rss2" emacs)
                          ("https://hnrss.org/best" industry news)
                          ("https://steve-yegge.medium.com/feed" industry)
                          ("https://blog.codinghorror.com/rss/" industry)
                          ("https://ag91.github.io/rss.xml" emacs)
                          ))



;;              (setq elfeed-feeds
      ;;                  '("https://irreal.org/blog/?feed=rss2"
      ;;                    "https://hnrss.org/best"
      ;;                    "https://steve-yegge.medium.com/feed"
      ;;                    "https://blog.codinghorror.com/rss/"))
                          ;"https://news.ycombinator.com/rss"
                          ;'("https://www.phoronix.com/rss.php"
                          ;"https://old.reddit.com/r/SurfaceLinux/.rss"
                          ;"https://old.reddit.com/r/Gentoo/.rss"))

                  (setq browse-url-browser-function 'w3m-browse-url) ; w3 browser

;don't show hidden files
   (setq dired-omit-files "^\\..*$")

;;https://old.reddit.com/r/emacs/comments/ct0x2q/how_to_open_docx_xlsx_and_pdf_with_external/
(require 'dired-x)
(setq dired-guess-shell-alist-user '(("\\.mkv\\'"  "mpv")
                                     ("\\.avi\\'"  "mpv")
                                     ("\\.mp4\\'"  "mpv")
                                     ("\\.m4v\\'"  "mpv")
                                     ("\\.flv\\'"  "mpv")
                                     ("\\.wmv\\'"  "mpv")
                                     ("\\.mpg\\'"  "mpv")
                                     ("\\.mpeg\\'" "mpv")
                                     ("\\.webm\\'" "mpv")
                                     ("\\.pdf\\'"  "evince")
                                     ("\\.djvu\\'" "evince")))

;; https://depp.brause.cc/nov.el/     

(straight-use-package 'nov) ;; read epubs 
(defun my-nov-font-setup ()
  (face-remap-add-relative 'variable-pitch :family "Liberation Serif"
                           :height 1.2))
(add-hook 'nov-mode-hook 'my-nov-font-setup)
;; associate .epub's with nov
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

;; warn when opening files bigger than 100MB
;; (raise the limit for a warning prompt from emacs)
;;(setq large-file-warning-threshold 100000000)

;;(add-hook 'after-init-hook #'neotree-toggle)
;;(package-initialize)

;;(setq org-journal-dir "~/documents/zen/journal/")
             (setq org-journal-dir "~/nextcloud/documents/life/journal/")

(setq org-journal-file-type 'weekly)
                  (require 'ox-latex)
                ;(setq org-hide-emphasis-markers t)

               (setq org-hide-emphasis-markers t
                     org-fontify-done-headline t
                     org-hide-leading-stars t
                     org-pretty-entities t) ;; indent 1,2,3,4,5,...
                     ;;org-odd-levels-only t) ;; only indent 1,3,5,7,...

                  (setq org-support-shift-select t)

                  (unless (boundp 'org-latex-classes)
                 (setq org-latex-classes nil))

               (add-to-list 'org-latex-classes
                            '("assignment"
                                  "\\documentclass[25pt,a4paper]{article}
               \\usepackage[utf8]{inputenc}
                  \\newcommand{\folder}{~/school/UW-TAC/Fall-19/latex/}
                  \\input{\folder/packages}
                  \\pagenumbering{gobble}
                  \\pagenumbering{arabic}"

               ("\\paragraph{%s}" . "\\paragraph*{%s}")))

               (setq-default prettify-symbols-alist '(("#+BEGIN_SRC" . "λ")
                                                      ("#+END_SRC" . "λ")
                                                      ("#+begin_src" . "λ")
                                                      ("#+end_src" . "λ")
                                                      (">=" . "≥")
                                                      ("=>" . "⇨")))
               (setq prettify-symbols-unprettify-at-point 'right-edge)
               (add-hook 'org-mode-hook 'prettify-symbols-mode)


               (add-hook 'org-mode-hook 'org-fragtog-mode)



               ;; ; https://emacs.stackexchange.com/questions/38198/automatically-preview-latex-in-org-mode-as-soon-as-i-finish-typing
               ;; (defun my/org-render-latex-fragments ()
               ;;   (if (org--list-latex-overlays)
               ;;       (progn (org-toggle-latex-fragment)
               ;;              (org-toggle-latex-fragment))
               ;;     (org-toggle-latex-fragment)))

               ;; (add-hook 'org-mode-hook
;;           (lambda ()
               ;;             (add-hook 'after-save-hook 'my/org-render-latex-fragments nil 'make-the-hook-local)))


               (custom-theme-set-faces
                'user
                '(variable-pitch ((t (:family "Source Sans Pro" :height 120 :weight light))))
                '(fixed-pitch ((t ( :family "Consolas" :slant normal :weight normal :height 0.9 :width normal)))))

               (custom-theme-set-faces
                'user
                '(org-block                 ((t (:inherit fixed-pitch))))
                '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
                '(org-property-value        ((t (:inherit fixed-pitch))) t)
                '(org-special-keyword       ((t (:inherit (font-lock-comment-face fixed-pitch)))))
                '(org-tag                   ((t (:inherit (shadow fixed-pitch) :weight bold))))
                '(org-verbatim              ((t (:inherit (shadow fixed-pitch))))))



     ; Display inline images by default
     ;https://stackoverflow.com/questions/17621495/emacs-org-display-inline-images
     (setq org-display-inline-images t)
     (setq org-redisplay-inline-images t)
     (setq org-startup-with-inline-images "inlineimages")

(use-package org-bullets
  :straight t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (setq org-bullets-bullet-list '("◐" "◑" "◒" "◓" "◴" "◵" "◶" "◷" "⚆" "⚇" "⚈" "⚉" "♁" "⊖" "⊗" "⊘"))
;; org ellipsis options, other than the default Go to Node...
;; not supported in common font, but supported in Symbola (my fall-back font) ⬎, ⤷, ⤵
(setq org-ellipsis "☾⚇☽");; ⤵ ≫  
)

;; makes lists-in org mode use a bullet character
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([+]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "◦"))))))

;   (use-package emms
;  :ensure t
;  :config
;    (require 'emms-setup)
;    (require 'emms-player-mpd)
;    (emms-all) ; don't change this to values you see on stackoverflow questions if you expect emms to work
;    (setq emms-seek-seconds 5)
;    (setq emms-player-list '(emms-player-mpd))
;    (setq emms-info-functions '(emms-info-mpd))
;    (setq emms-player-mpd-server-name "localhost")
;    (setq emms-player-mpd-server-port "6600")
 ;; :bind
 ;;   ("s-z ." . emms)
 ;;   ("s-z b" . emms-smart-browse)
   ;; ("s-z r" . emms-player-mpd-update-all-reset-cache)
  ;;  ("<XF86AudioPrev>" . emms-previous)
  ;;  ("<XF86AudioNext>" . emms-next)
  ;;  ("s-z p" . emms-player-mpd-pause)
;;    ("<XF86AudioStop>" . emms-stop)
;)


;;; NO MPD EMMS HERE:
;   (use-package emms
;  :ensure t
;  :config
 ;   (require 'emms-setup)
 ;   (emms-all)
 ;   (emms-default-players))

 ;   (emms-mode-line 0)
  ;  (require 'helm-emms)
    


    ;(require 'sudo-edit)
    (global-set-key (kbd "C-c C-r") 'sudo-edit)
;(defun mpd/start-music-daemon ()
;  "Start MPD, connects to it and syncs the metadata cache."
;  (interactive)
;  (shell-command "mpd")
;  (mpd/update-database)
;  (emms-player-mpd-connect)
;  (emms-cache-set-from-mpd-all)
;  (message "MPD Started!"))
;(global-set-key (kbd "s-z c") 'mpd/start-music-daemon)

;(defun mpd/kill-music-daemon ()
;  "Stops playback and kill the music daemon."
;  (interactive)
;  (emms-stop)
;  (call-process "killall" nil nil nil "mpd")
;  (message "MPD Killed!"))
;(global-set-key (kbd "s-z k") 'mpd/kill-music-daemon)

;(defun mpd/update-database ()
;  "Updates the MPD database synchronously."
;  (interactive)
;  (call-process "mpc" nil nil nil "update")
;  (message "MPD Database Updated!"))
;(global-set-key (kbd "s-z u") 'mpd/update-database)

(setq-default indent-tabs-mode nil)

;;(require 'workgroups)
;;(workgroups-mode 1)

;;(require 'hide-region)

   ;; global Effort estimate values
;(setq org-global-properties
;      '(("Effort_ALL" .
;         "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")))
;;        1    2    3    4    5    6    7    8    9    0
;; These are the hotkeys ^^

(projectile-mode +1)
;; Set Default Browser
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "firefox-devedition")


(setq org-latex-inputenc-alist '(("utf8" . "utf8x")))

;;(global-xah-math-input-mode 1) ; turn on globally
;;type l, hit "Shift" + "Space" -> λ


;;(require 'zetteldeft)



;;(mpdel-mode)

;;(setq mpdel-prefix-key (kbd "C-. z"))


;;(require 'libmpdel)


;(require 'weechat)
;(require 'vterm)

;; Path to the grip binary
(setq grip-binary-path "/nix/store/gmcays7dhfhkk22hk7jxyyck1zjgdxk2-python3.8-grip-4.5.2/bin/grip")
(setq compilation-ask-about-save nil) ; don't ask to save, if I want to compile



;; get rid of smart quotes in auctex
(setq TeX-quote-after-quote t)

(straight-use-package 'exwm :ensure t)

;; ;; Load EXWM
;;  (require 'exwm)
;;  (require 'exwm-config)
;;  ;; Fix problems with Ido (if you use it).
;;  ;(exwm-config-ido)

;;  (exwm-config-default)

;;  (require 'exwm-systemtray)
;;  (exwm-systemtray-enable)

;;  ;; Disable menu-bar, tool-bar and scroll-bar to increase the usable space.
;;    (menu-bar-mode -1)
;;    (tool-bar-mode -1)
;;    (scroll-bar-mode -1)
;;  ;; Also shrink fringes to 1 pixel.
;;    (fringe-mode 1)
;;   ; (fringe-mode 0)

;;  ;; Turn on `display-time-mode' if you don't use an external bar.
;;  (setq display-time-default-load-average nil)
;;  (display-time-mode t)

;;  ;; You are strongly encouraged to enable something like `ido-mode' to alter
;;  ;; the default behavior of 'C-x b', or you will take great pains to switch
;;  ;; to or back from a floating frame (remember 'C-x 5 o' if you refuse this
;;  ;; proposal however).
;;  ;; You may also want to call `exwm-config-ido' later (see below).
;;  (ido-mode 1)

;;  ;; search
;;  ;(helm-mode 1)

;;  ;; Emacs server is not required to run EXWM but it has some interesting uses
;;  ;; (see next section).
;;  (server-start)

;;  ;;;; Below are configurations for EXWM.

;;  ;; Add paths (not required if EXWM is installed from GNU ELPA).
;;  ;(add-to-list 'load-path "/path/to/xelb/")
;;  ;(add-to-list 'load-path "/path/to/exwm/")



;; ;; ;
;;                                         ; Set the initial number of workspaces (they can also be created later).
;; (setq exwm-workspace-number 10)

;; ;; All buffers created in EXWM mode are named "*EXWM*". You may want to
;; ;; change it in `exwm-update-class-hook' and `exwm-update-title-hook', which
;; ;; are run when a new X window class name or title is available.  Here's
;; ;; some advice on this topic:
;; ;; + Always use `exwm-workspace-rename-buffer` to avoid naming conflict.
;; ;; + For applications with multiple windows (e.g. GIMP), the class names of
;; ;    all windows are probably the same.  Using window titles for them makes
;; ;;   more sense.
;; ;; In the following example, we use class names for all windows expect for
;; ;; Java applications and GIMP.
;; (add-hook 'exwm-update-class-hook
;;           (lambda ()
;;             (unless (or (string-prefix-p "sun-awt-X11-" exwm-instance-name)
;;                         (string= "gimp" exwm-instance-name))
;;               (exwm-workspace-rename-buffer exwm-class-name))))
;; (add-hook 'exwm-update-title-hook
;;           (lambda ()
;;             (when (or (not exwm-instance-name)
;;                       (string-prefix-p "sun-awt-X11-" exwm-instance-name)
;;                       (string= "gimp" exwm-instance-name))
;;               (exwm-workspace-rename-buffer exwm-title))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CUSTOΜ Scripts & Keybindings
;https://groups.google.com/forum/#!msg/gnu.emacs.help/TNqE7R7mULk/ZV6VaeIiOHQJ

(defun decrease-volume ()
  "Decrease Pulse volume by 3%."
  (interactive)
 ; (shell-command "amixer -D pulse
 ;;"set Master 3%-")
 (call-process-shell-command "amixer -D pulse sset Master 3%-" nil 0))

                                        ;(global-set-key (kbd "s-m") 'decrease-volume)


(defun increase-volume ()
  "Increase Pulse volume by 3%."
  (interactive)
  (call-process-shell-command "amixer -D pulse sset Master 3%+" nil 0))


(defun take-screenshot ()
  "Flameshot."
  (interactive)
  (call-process-shell-command "flameshot gui" nil 0))


                                        ;(defun decrease-brightness ()
                                        ;  "decrease brightness."
                                        ;  (interactive)
                                        ;   (call-process-shell-command "xbacklight -dec 10" nil 0))

(defun decrease-brightness ()
  "decrease brightness."
  (interactive)
  (call-process-shell-command "brightnessctl s 500-" nil 0))

                                        ;(defun increase-brightness ()
                                        ;  "increase brightness."
                                        ;  (interactive)
                                        ;   (call-process-shell-command "xbacklight -inc 10" nil 0))


(defun increase-brightness ()
  "increase brightness."
  (interactive)
  (call-process-shell-command "brightnessctl s 500+" nil 0))

(defun scrot-screenshot-rectangle-clipboard ()
  "clip select rectangle of screen into clipbaord"
  (interactive)
  (call-process-shell-command "scrot -s '/tmp/%F_%T_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f'" nil 0))

;;(global-set-key (kbd "s-g") (emacs --eval "(exwm-workspace-switch-to-buffer(helm-exwm))"))








;; Frame Mode 
;; (Open buffers in new frame (split), do not replace with new window)
;; (use-package frame-mode
;;   :straight t
;;   :demand t
;;   :config
;;   (progn
;;     (frame-mode +1)
;;     (frame-keys-mode +1)))


;; ;; Helm File Search
                                        ;(global-set-key (kbd "C-x C-f") 'helm-find-files)

                                        ;https://github.com/emacs-helm/helm/issues/1630
                                        ; make tab-completion work in helm
                                        ;(define-key helm-find-files-map "\t" 'helm-execute-persistent-action)

(defun suspend-computer ()
  "Suspend Computer"
  (interactive)
  (shell-command "systemctl suspend"))


(defun lock-computer ()
  "Lock Computer"
  (interactive)
  (shell-command "i3lock -i ~/data/backgrounds/4k/andre-benz-JBkwaYMuhdc-unsplash.png"))

;; Global keybindings can be defined with `exwm-input-global-keys'.
;; Here are a few examples:

                                        ;(global-set-key (kbd "s-A")  (lambda () (interactive) (exwm-workspace-move-window "0")))

(defun kill-buffer-and-window ()
  "Run `some-command' and `some-other-command' in sequence."
  (interactive)
  (kill-current-buffer)
  (delete-window))




(defun helm-find-files-history ()
  "Run `some-command' and `some-other-command' in sequence."
  (interactive)
  (let ((current-prefix-arg 4)) ;; emulate C-u
    (call-interactively 'helm-find-files)))


(defun reset-bindings ()
  "Reset Keyboard bindings."
  (interactive)
  (shell-command "sh ~/nextcloud/dev/scripts/resetbindings.sh"))



(defun mirror-displays ()
  "Mirror laptop display and HDMI external display."
  (interactive)
  (shell-command "sh ~/.screenlayout/mirror.sh"))

;; C-c v displays .tex associated pdf file.
              ; (global-set-key (kbd "C-c k") 'helm-find-files-history)

               (global-set-key "\C-c#" 'reset-bindings)

            ;; ivy find file
            (global-set-key (kbd "C-x C-f") 'counsel-find-file)
            ;https://github.com/syl20bnr/spacemacs/issues/7516
            ;(define-key ivy-minibuffer-map (kbd "TAB") 'ivy-alt-done)

            (global-set-key "\C-s" 'swiper)




      ; For when I'm using i3-wm (and not EXWM):
      (global-set-key (kbd "s-*") 'mpv-play)
      (global-set-key (kbd "s-g") 'mpv-pause)
      (global-set-key (kbd "s-c") 'mpv-seek-backward)
      (global-set-key (kbd "s-r") 'mpv-seek-forward)
      (global-set-key (kbd "M-f") 'forward-word)
      (global-set-key (kbd "M-b") 'backward-word)
      (global-set-key (kbd "M-w") 'kill-ring-save) 
      (global-set-key (kbd "C-d") 'delete-char) 
      (global-set-key (kbd "M-:") 'eval-expression) 

; screenshot
      (global-set-key (kbd "s-w") 'scrot-screenshot-rectangle-clipboard)




            ; multiple-cursors
            (global-set-key (kbd "C-c m c") 'mc/edit-lines)

               (global-set-key (kbd "C-c e") 'org-babel-execute-src-block)
               ;(global-set-key (kbd "C-h") 'backward-char)
               ;(global-set-key (kbd "C-s") 'forward-char)
               ;(global-set-key (kbd "C-t") 'previous-line)
               ;(global-set-key (kbd "C-n") 'next-line)
               (global-set-key (kbd "C-x p") 'org-pomodoro)

               (global-set-key (kbd "C-x 2") 'split-window-vertically)
               (global-set-key (kbd "C-x 3") 'split-window-horizontally)

               (global-set-key (kbd "M-W") 'ox-clip-image-to-clipboard)


               (global-set-key (kbd "C-x g") 'magit-global)
               (global-set-key (kbd "C-x M-g") 'magit-dispatch)
               (global-set-key (kbd "C-c g") 'org-latex-export-to-pdf)
               (global-set-key "\C-cc" 'cfw:open-org-calendar)
              ; (global-set-key "\C-cm" 'mu4e)
               (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
               (global-set-key "\C-ca" 'org-agenda)
               ;; quickly open some files
               (global-set-key (kbd "C-c o") (lambda () (interactive) (find-file "~/documents/zen/schedule.org")));
               ;; quickly open some files
               (global-set-key (kbd "C-c u") (lambda () (interactive) (find-file "~/documents/zen/selfdoc.org")));
               ;; quickly open some files
               (global-set-key (kbd "C-c i") (lambda () (interactive) (find-file "~/documents/zen/otherdoc.org")));
               (global-set-key (kbd "C-c j") (lambda () (interactive) (find-file "~/documents/zen/journal.org")));

               (global-set-key (kbd "C-r") 'yas-insert-snippet)

              (eval-after-load 'latex
                '(define-key LaTeX-mode-map (kbd "C-.") 'latex-compile))

                ;; add keybinding for screenshot in org-mode
                (define-key org-mode-map (kbd "C-.") 'org-download-screenshot)


                ;(global-set-key (kbd "s-g") 'mpv-seek-backward)



             ;; (setq exwm-input-global-keys
             ;;       `(
             ;;         ;; Bind "s-r" to exit char-mode and fullscreen mode.
             ;;          ([?\s-/] . exwm-reset)

             ;;          ([?\s-b] . decrease-volume)
             ;;         ([?\s-m] . increase-volume)
             ;;         ([?\s--] . suspend-computer)
             ;;         ([?\s-d] . counsel-linux-app)
             ;;         ;; Move focus to different buffers
             ;;         ([?\s-h] . windmove-left)
             ;;         ([?\s-n] . windmove-down)
             ;;         ([?\s-t] . windmove-up)
             ;;         ([?\s-s] . windmove-right)
             ;;         ;; Move buffers around
             ;;         ([?\s-H] . buf-move-left)
             ;;         ([?\s-N] . buf-move-down)
             ;;         ([?\s-T] . buf-move-up)
             ;;         ([?\s-S] . buf-move-right)

             ;;         ([?\s-#] . decrease-brightness)
             ;;         ([?\s-\\] . increase-brightness)
             ;;         ([?\s-`] . mirror-displays)

             ;;         ([?\s-*] . mpv-play)
             ;;         ([?\s-f] . mpv-pause)
             ;;         ([?\s-g] . mpv-seek-backward)
             ;;         ([?\s-c] . mpv-seek-forward)
             ;;         ;([?\s-g] . (lambda () (interactive) (mpv-seek-backward (2))))
             ;;         ([?\s-g] . (lambda () (interactive) (mpv-seek-backward 2)))
             ;;         ;(lambda () (mpv-seek-backward 2))
             ;;         ([?\s-c] . (lambda () (interactive) (mpv-seek-forward 2)))

             ;; ;(global-set-key (kbd "s-*") 'mpv-play)
             ;; ;(global-set-key (kbd "s-f") 'mpv-pause)
             ;; ;(global-set-key (kbd "s-g") 'mpv-seek-backward)
             ;; ;(global-set-key (kbd "s-c") 'mpv-seek-forward)


             ;;         ([?\s-'] . kill-this-buffer)
             ;;         ([?\s-Q] . kill-buffer-and-window)
             ;;         ([?\s-J] . take-screenshot)
             ;;         ([?\M-x] . counsel-M-x)
             ;;         ([?\s-w] . kill-ring-save)
             ;;         ;;  ([?\s-l] . helm-exwm)
             ;;         ([?\s-l] . (lambda () (interactive) (exwm-workspace-switch-to-buffer (helm-exwm))))

             ;;         ([?\s-r] . ivy-switch-buffer)


             ;;         ;;([?\s-z] . emms-player-mpd-pause)
             ;;         ([?\s-z] . emms-pause)
             ;;         ([?\s-@] . emms-seek-forward)
             ;;         ([?\s-/] . emms-seek-backward)


             ;;         ([?\s-&] . (lambda (command)
             ;;                      (interactive (list (read-shell-command "$ ")))
             ;;                      (start-process-shell-command command nil command)))
             ;;         ;; Bind "s-<f2>" to "slock", a simple X display locker.
             ;;         ;([s-f2] . (lambda ()
             ;;         ;            (interactive)
             ;;         ;            (start-process "" nil "/usr/bin/slock")))
             ;;         ([?\s-a] . (lambda () (interactive) (exwm-workspace-switch-create 0)))
             ;;         ([?\s-o] . (lambda () (interactive) (exwm-workspace-switch-create 1)))
             ;;         ([?\s-e] . (lambda () (interactive) (exwm-workspace-switch-create 2)))
             ;;         ([?\s-u] . (lambda () (interactive) (exwm-workspace-switch-create 3)))
             ;;         ([?\s-i] . (lambda () (interactive) (exwm-workspace-switch-create 4)))
             ;;         ;; unbound parenthesis error
             ;;         ([?\s-;
             ;;           ] . (lambda () (interactive) (exwm-workspace-switch-create 5)))
             ;;         ([?\s-,] . (lambda () (interactive) (exwm-workspace-switch-create 6)))
             ;;         ([?\s-.] . (lambda () (interactive) (exwm-workspace-switch-create 7)))
             ;;         ([?\s-p] . (lambda () (interactive) (exwm-workspace-switch-create 8)))
             ;;         ([?\s-y] . (lambda () (interactive) (exwm-workspace-switch-create 9)))
             ;;         ([?\s-A] . (lambda () (interactive) (exwm-workspace-move-window 0)))
             ;;         ([?\s-O] . (lambda () (interactive) (exwm-workspace-move-window 1)))
             ;;         ([?\s-E] . (lambda () (interactive) (exwm-workspace-move-window 2)))
             ;;         ([?\s-U] . (lambda () (interactive) (exwm-workspace-move-window 3)))
             ;;         ([?\s-I] . (lambda () (interactive) (exwm-workspace-move-window 4)))
             ;;         ([?\s-:] . (lambda () (interactive) (exwm-workspace-move-window 5)))
             ;;         ([?\s-<] . (lambda () (interactive) (exwm-workspace-move-window 6)))
             ;;         ([?\s->] . (lambda () (interactive) (exwm-workspace-move-window 7)))
             ;;         ([?\s-P] . (lambda () (interactive) (exwm-workspace-move-window 8)))
             ;;         ([?\s-Y] . (lambda () (interactive) (exwm-workspace-move-window 9)))))

             ;; ;; To add a key binding only available in line-mode, simply define it in
             ;; ;; `exwm-mode-map'.  The following example shortens 'C-c q' to 'C-q'.
             ;; (define-key exwm-mode-map [?\C-q] #'exwm-input-send-next-key)



             ;; ;; The following example demonstrates how to use simulation keys to mimic
             ;; ;; the behavior of Emacs.  The value of `exwm-input-simulation-keys` is a
             ;; ;; list of cons cells (SRC . DEST), where SRC is the key sequence you press
             ;; ;; ;; and DEST is what EXWM actually sends to application.  Note that both SRC
             ;; ;; ;; and DEST should be key sequences (vector or string).
             ;;    (setq exwm-input-simulation-keys
             ;;        '(
             ;;          ;; movement 
             ;;          ([?\C-b] . [left])
             ;;          ([?\M-b] . [C-left])
             ;;          ([?\C-f] . [right])
             ;;          ([?\M-f] . [C-right])
             ;;         ;; ([?\C-p] . [up])
             ;;          ([?\C-n] . [down])
             ;;         ;; ([?\C-a] . [home])
             ;;          ([?\C-e] . [end])
             ;;          ([?\M-v] . [prior])
             ;;          ([?\C-v] . [next])
             ;;          ([?\C-d] . [delete])
             ;;          ([?\C-k] . [S-end delete])
             ;;          ;; cut/paste.

             ;;          ;Don't use this, interferes with firefox
             ;;          ;;([?\C-w] . [?\C-x])

             ;;          ;;My Change from M-w to s-W because my mapping
             ;;          ([?\s-w] . [?\C-c])
             ;;          ([?\C-y] . [?\C-v])
             ;;          ;; search
;;          ([?\C-s] . [?\C-f])))

;; (require 'exwm-randr)
;; (setq exwm-randr-workspace-monitor-plist '(0 "HDMI_1"))
;; (add-hook 'exwm-randr-screen-change-hook
;;           (lambda ()
;;             (start-process-shell-command
;;              "xrandr" nil "xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --mode 3840x2160 --pos 0x0 --rotate normal --output HDMI-1 --off --output HDMI-2 --off")))
;;              ;"xrandr" nil "xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output HDMI-2 --mode 1920x1080 --pos 0x0 --rotate normal")))
;;             ;; "xrandr" nil "xrandr --output HDMI-2 --right-of HDMI-1 --auto")))
;;             ;; "xrandr" nil "xrandr --output eDP1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output DP1 --off --output HDMI1 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output VIRTUAL1 --off")))
;;        ;;      "xrandr" nil "xrandr --output eDP1 --primary --mode 1920x1080 --pos 1080x0 --rotate normal --output DP1 --off --output HDMI1 --mode 1920x1080 --pos 0x0 --rotate left --output HDMI2 --mode 1920x1080 --pos 1080x0 --rotate normal --output VIRTUAL1 --off")))
;; (exwm-randr-enable)

;; ;; You can hide the minibuffer and echo area when they're not used, by
;; ;; uncommenting the following line.
;;                                         ;(setq exwm-workspace-minibuffer-position 'bottom)

;; ;; Do not forget to enable EXWM. It will start by itself when things are
;; ;; ready.  You can put it _anywhere_ in your configuration.

;; (exwm-input-set-key (kbd "C-x C-/") #'ibuffer)

;; ;(exwm-enable)

;; Resize treemacs text:
     ;;(add-hook 'treemacs-mode-hook (lambda () (text-scale-decrease 1.5)))
     ;;(add-hook 'treemacs-mode-hook (lambda () (text-scale-decrease 1.3)))
     (use-package treemacs
       :ensure t
       :straight t
       :defer t ;;required
       ;;:demand t
       ;;:init
       ;;(add-hook 'after-init-hook 'treemacs))
       ;; https://old.reddit.com/r/emacs/comments/gu4q2m/how_do_you_get_treemacs_to_start_when_you_start/
       :hook (after-init . treemacs)
       ;; (with-eval-after-load 'winum
       ;;(define-key winum-keymap (kbd "M-0") #'treemacs-select-window)
       ;;(define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)))
       :config
       (define-key treemacs-mode-map [mouse-1] #'treemacs-single-click-expand-action)
       ;;(add-hook 'after-init-hook 'treemacs))
         )
;;(add-hook 'emacs-startup-hook 'treemacs)
;;:config
       ;;(progn
       ;;    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
       ;;          treemacs-deferred-git-apply-delay      0.5
       ;;          treemacs-directory-name-transformer    #'identity
       ;;          treemacs-display-in-side-window        t
       ;;          treemacs-eldoc-display                 t
       ;;          treemacs-file-event-delay              5000
       ;;          treemacs-file-extension-regex          treemacs-last-period-regex-value
       ;;         treemacs-file-follow-delay             0.2
       ;;         treemacs-file-name-transformer         #'identity
       ;;         treemacs-follow-after-init             t
       ;;        treemacs-git-command-pipe              ""
       ;;       treemacs-goto-tag-strategy             'refetch-index
       ;;     treemacs-indentation                   2
       ;;    treemacs-indentation-string            " "
       ;;   treemacs-is-never-other-window         nil
       ;;  treemacs-max-git-entries               5000
       ;; treemacs-missing-project-action        'ask
       ;;treemacs-no-png-images                 nil
       ;;treemacs-no-delete-other-windows       t
;;treemacs-project-follow-cleanup        nil
       ;;treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
       ;; treemacs-position                      'left
       ;;treemacs-recenter-distance             0.1
       ;;treemacs-recenter-after-file-follow    nil
       ;; treemacs-recenter-after-tag-follow     nil
       ;; treemacs-recenter-after-project-jump   'always
       ;; treemacs-recenter-after-project-expand 'on-distance
       ;; treemacs-show-cursor                   nil
       ;; treemacs-show-hidden-files             t
       ;; treemacs-silent-filewatch              nil
       ;; treemacs-silent-refresh                nil
       ;; treemacs-sorting                       'alphabetic-asc
       ;; treemacs-space-between-root-nodes      t
       ;; treemacs-tag-follow-cleanup            t
       ;; treemacs-tag-follow-delay              1.5
       ;; treemacs-width                         22)

       ;; The default width and height of the icons is 22 pixels. If you are
       ;; using a Hi-DPI display, uncomment this to double the icon size.
       ;;(treemacs-resize-icons 14)

       ;;(treemacs-follow-mode t)
       ;;(treemacs-filewatch-mode t)
       ;; (treemacs-fringe-indicator-mode t)
       ;; (pcase (cons (not (null (executable-find "git")))
       ;;              (not (null treemacs-python-executable)))
       ;;   (`(t . t)
       ;;    (treemacs-git-mode 'deferred))
       ;;   (`(t . _)
       ;;    (treemacs-git-mode 'simple))))
       ;; :bind
       ;; (:map global-map
       ;;       ("M-0"       . treemacs-select-window)
       ;;       ("C-x t 1"   . treemacs-delete-other-windows)
       ;;       ("C-x t t"   . treemacs)
       ;;      ("C-x t B"   . treemacs-bookmark)
       ;;      ("C-x t C-t" . treemacs-find-file)
       ;;      ("C-x t M-t" . treemacs-find-tag)))
       ;; ))

       ;;(use-package treemacs-evil
       ;; :after treemacs evil
       ;; :ensure t)

       ;;(use-package treemacs-projectile
       ;;  :after treemacs projectile
       ;;  :ensure t)

       ;;(use-package treemacs-icons-dired
       ;;  :after treemacs dired
       ;;  :ensure t
       ;;  :config (treemacs-icons-dired-mode))

       ;;(use-package treemacs-magit
       ;;  :after treemacs magit
       ;;  :ensure t)

       ;;(use-package treemacs-persp
       ;;  :after treemacs persp-mode
       ;;  :ensure t
       ;;  :config (treemacs-set-scope-type 'Perspectives))

       ;; (use-package treemacs-perspective ;;treemacs-perspective if you use perspective.el vs. persp-mode
       ;;   :after (treemacs perspective) ;;or perspective vs. persp-mode
       ;;   :straight t
       ;;   :ensure t
       ;;   :config (treemacs-set-scope-type 'Perspectives))

(custom-set-faces
       ;; custom-set-faces was added by Custom.
       ;; If you edit it by hand, you could mess it up, so be careful.
       ;; Your init file should contain only one such instance.
       ;; If there is more than one, they won't work right.

      ;; I believe an ERROR occures here when trying to make the default font "slate gray"
       ;;'(default ((t (:inherit nil :stipple nil :background "#1e1e27" :foreground "gray" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 83 :width normal :foundry "CYEL" :family "Iosevka"))))
       ;;'(default ((t (:inherit nil :stipple nil :background "#1e1e27" :foreground "snow4" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 83 :width normal :foundry "CYEL" :family "Iosevka"))))
       '(default ((t (:inherit nil :stipple nil :background "#1e1e27" :foreground "gray65" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 83 :width normal :foundry "CYEL" :family "Iosevka"))))
;;;;

       '(bold ((t (:foreground "medium orchid" :weight bold))))

       '(font-lock-comment-delimiter-face ((t (:foreground "maroon3"))))
      ;; '(font-lock-comment-face ((t (:foreground "maroon3"))))
       ;;'(font-lock-comment-face ((t (:foreground "snow4"))))
       '(font-lock-comment-face ((t (:foreground "gray50"))))
       ;;'(font-lock-string-face ((t (:background "#404040" :foreground "LightPink3"))))
       ;;'(font-lock-string-face ((t (:background "#404040" :foreground "#4f5d2f"))))
       '(font-lock-string-face ((t (:background "#404040" :foreground "#8f755b"))))
       '(italic ((t (:foreground "cadet blue" :slant italic))))
       '(mouse ((t (:background "plum2"))))
       '(org-verbatim
         ((t (:background "#404040" :foreground "pale violet red"))))
       '(org-code
         ((t (:background "#404040" :foreground "pale violet red"))))
       ;;'(org-code
       ;;  ((t (:background "#404040" :foreground "pale green"))))
       ;;'(org-code
       ;;  ((t (:background "gray20" :foreground "pale green"))))
       ;;'(org-block-begin-line
       ;;  ((t (:underline "#A7A6AA"  :background "#161650"))))
       '(org-block-begin-line
         ((t (:underline "#A7A6AA"  :foreground "#CCFF00"  :background "#374845"))))
       ;;'(org-block
       ;;  ((t (:background "#550444"))))
       '(org-block
         ((t (:background "#2A3C35"))))
       '(org-block-end-line
         ((t (:overline "#A7A6AA"  :foreground "#CCFF00"  :background "#374845"))))
       '(org-level-1 ((t (:foreground "#8b8bcd" :weight bold :height 1.5))))
       '(org-level-2 ((t (:foreground "violet" :weight bold :height 1.3))))
       '(org-level-3 ((t (:foreground "#add551" :weight bold :height 1.1))))
        '(tab-bar ((t (:background "dark slate gray"))))
        '(tab-bar-tab ((t (:background "brown" :foreground "black"))))
        ; '(underline ((t (:foreground "RosyBrown2" :underline t))))
        '(underline ((t (:foreground "light steel blue" :underline t))))


        '(tab-bar-tab-inactive ((t (:inherit tab-bar-tab :background "dim gray" :foreground "black")))))


      ;; https://old.reddit.com/r/emacs/comments/4lfyjp/how_can_i_make_emacs_transparent_but_not_the_text/
      (set-frame-parameter (selected-frame) 'alpha '(85 85))
      (add-to-list 'default-frame-alist '(alpha 85 85))



      (defun org-export-as-pdf-and-open ()
        (interactive)
        (save-buffer)
        (org-open-file (org-latex-export-to-pdf)))


      (add-to-list 'org-latex-classes
                   '("greg"
                     "\\documentclass{article}
           \\usepackage[utf8]{inputenc}
           \\usepackage[T1]{fontenc}
           \\usepackage{graphicx}
           \\usepackage{longtable}
           \\usepackage{hyperref}
           \\usepackage{natbib}
           \\usepackage{amssymb}
           \\usepackage{amsmath}
           \\setlength{\\parskip}{0pt}
           \\usepackage{geometry}
           \\geometry{ a4paper,left=0.5in,right=0.5in,top=0.3in,bottom=0.3in, footskip=.25in }"
                     ))   


                     (setq org-image-actual-width nil)
                   ;(setq org-image-actual-width 50)


      ;;(load "i3.el")
      ;;(load "i3-integration.el")
      ;;(require 'i3)
      ;;(i3-one-window-per-frame-mode-on)

                                              ; (add-hook 'emacs-lisp-mode-hook
                                              ;  (function (lambda ()
                                              ;   (add-hook 'local-write-file-hooks 
                                              ;   'check-parens))))  


                                        ;(set-frame-font "Hack-12" nil t)

                        ;(set-frame-font "Iosevka-12" nil t)
                        (set-frame-font "Scientifica-14" nil t)

;https://tecosaur.github.io/emacs-config/config.html#pretty-code-blocks
(setq org-latex-listings 'engraved) ; NOTE non-standard value
(straight-use-package 'csharp-mode) ; for csharp syntax highlighting

(use-package envrc
            :straight t
            :config (envrc-global-mode))


          ;;
          ;; https://www.gonsie.com/blorg/org-highlight.html
          ;; add highlighting ability to org-mode (using semicolon : ), and export highlight to pdf/html export

          (defun org-add-my-extra-markup ()
            "Add highlight emphasis."
            (add-to-list 'org-font-lock-extra-keywords
                         '("[^\\w]\\(@\\[^\n\r\t]+@\\)[^\\w]"
                           (1 '(face highlight invisible nil)))))

    ;(add-to-list 'org-emphasis-alist
    ;             '("*" (:foreground "red")
    ;               ))


          (add-hook 'org-font-lock-set-keywords-hook #'org-add-my-extra-markup)


        (defun my-html-mark-tag (text backend info)
          "Transcode :blah: into <mark>blah</mark> in body text."
          (when (org-export-derived-backend-p backend 'html)
            (let ((text (replace-regexp-in-string "[^\\w]\\(@\\)[^\n\t\r]+\\(@\\)[^\\w]" "<mark>"  text nil nil 1 nil)))
              (replace-regexp-in-string "[^\\w]\\(<mark>\\)[^\n\t\r]+\\(@\\)[^\\w]" "</mark>" text nil nil 2 nil))))

      ;(add-to-list 'org-export-filter-plain-text-fucntions 'my-html-mark-tag)

    (font-lock-add-keywords
     'org-mode
    '(("\\(@[^@\n]+@\\)" (0 '(:foreground "#2B2200" :background "#FFDDDD" :weight bold) t))))

(defun my-latex-highlight (text backend info)
  "replace @@ with \hl{}"
  (when (org-export-derived-backend-p backend 'latex)
      (replace-regexp-in-string "@\\([^@]+\\)@" "\\\\hl{\\1}" text)))

;(add-to-list 'org-export-filter-plain-text-functions 'my-latex-highlight)

  ; don't ask for confirmation to execute code blocks (don't keep asking yes or no)
  ; https://emacs.stackexchange.com/questions/23946/how-can-i-stop-the-confirmation-to-evaluate-source-code-when-exporting-to-html
  (setq org-confirm-babel-evaluate nil)

; make #+ faces smaller, so they are less distracting
; https://emacs.stackexchange.com/questions/27467/way-to-hide-src-block-delimiters
(set-face-attribute 'org-meta-line nil :height 0.8 :slant 'normal)
(set-face-attribute 'org-block-begin-line nil :height 0.8 :slant 'normal)
(set-face-attribute 'org-block-end-line nil :height 0.8 :slant 'normal)

;(load "pdf-avy-highlight")
