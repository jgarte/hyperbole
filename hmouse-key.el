;;; hmouse-key.el --- Setup Smart Key mouse bindings
;;
;; Author:       Bob Weiner
;;
;; Orig-Date:    30-May-94 at 00:11:57
;;
;; Copyright (C) 1994-2016  Free Software Foundation, Inc.
;; See the "HY-COPY" file for license information.
;;
;; This file is part of GNU Hyperbole.
;;
;;; Commentary:
;;
;;   Supports Mac OS X, X, NEXTSTEP and MS Windows window systems.
;;
;;   `hmouse-install' globally binds the Action and Assist Mouse Keys
;;   to shifted mouse buttons and optionally binds the Action Mouse Key
;;   to the middle mouse button.
;;
;;   `hmouse-toggle-bindings' switches between the Hyperbole mouse
;;   bindings and previous mouse key bindings any time after
;;   `hmouse-install' has been called.

;;; Code:
;;; ************************************************************************
;;; Other required Elisp libraries
;;; ************************************************************************

(eval-and-compile (mapc #'require '(hsite hmouse-drv hmouse-sh)))

;;; ************************************************************************
;;; Public variables
;;; ************************************************************************

(unless (or hyperb:xemacs-p hyperb:emacs-p)
  ;; XEmacs and Emacs pre-load their mouse libraries, so
  ;; we shouldn't have to require them here.
  (eval (cdr (assoc (hyperb:window-system)
		    '(
		      ("xterm"   . (require 'x-mouse))	 ; X
		      ("next"    . (load "eterm-fns" t)) ; NeXTstep
		      )))))

;;; ************************************************************************
;;; Public functions
;;; ************************************************************************

(defun hmouse-set-bindings (key-binding-list)
  "Sets mouse keys used as Smart Keys to bindings in KEY-BINDING-LIST.
KEY-BINDING-LIST is the value of either `hmouse-previous-bindings'
\(mouse bindings prior to Smart Key setup) or `hmouse-bindings' (mouse
bindings after Smart Key setup."
  (cond
    ;; Do nothing when running in batch mode.
    (noninteractive)
    ;;
    ;; GNU Emacs, XEmacs or InfoDock
    ((or hyperb:xemacs-p hyperb:emacs-p)
     (mapcar
       (lambda (key-and-binding)
	 (global-set-key (car key-and-binding) (cdr key-and-binding)))
       key-binding-list))
    ;;
    ;; X
    ((equal (hyperb:window-system) "xterm")
     (mapcar
       (lambda (key-and-binding)
	 (define-key mouse-map (car key-and-binding) (cdr key-and-binding)))
       key-binding-list))
    ;;
    ;; NeXT
    ((equal (hyperb:window-system) "next")
     (mapcar
       (lambda (key-and-binding)
	 (global-set-mouse (car key-and-binding) (cdr key-and-binding)))
       key-binding-list))))

(defun hmouse-install (&optional arg)
  "Binds the two rightmost shifted mouse keys to the Action and Assist Keys, initializing Hyperbole mouse buttons.
With optional prefix ARG or under InfoDock, also binds the unshifted middle mouse key to the Action Key.

The standard Hyperbole configuration is Action Key = shift-middle mouse key;
Assist Key = shift-right mouse key."
  (interactive "P")
  (unless hmouse-middle-flag
    (setq hmouse-middle-flag (or arg (and (boundp 'infodock-version)
					  infodock-version))))
  ;; Replace any original mouse bindings before installing Hyperbole bindings and
  ;; then force reinitialization of hmouse-previous-bindings.
  (if (and hmouse-bindings-flag hmouse-previous-bindings)
      (hmouse-set-bindings hmouse-previous-bindings))
  (setq hmouse-bindings-flag nil
	hmouse-previous-bindings nil)
  ;; This function does the actual binding of the Hyperbole mouse keys.
  (hmouse-shifted-setup hmouse-middle-flag)
  (if (called-interactively-p 'interactive)
      ;; Assume emacs has support for 3 mouse keys.
      (message "%s the Action Mouse Key; {Shift-Mouse-3} invokes the Assist Mouse Key."
	       (if hmouse-middle-flag "{Mouse-2} and {Shift Mouse-2} invoke"
		 "{Shift-Mouse-2} invokes"))))

(defun hmouse-toggle-bindings ()
  "Toggles between Smart Mouse Key settings and their prior bindings.
Under InfoDock, the first invocation of this command will make the middle
mouse key the Paste Key instead of the Action Key."
  (interactive)
  (let ((key-binding-list (if hmouse-bindings-flag
			      hmouse-previous-bindings
			    hmouse-bindings))
	(other-bindings-var (if hmouse-bindings-flag
				'hmouse-bindings
			      'hmouse-previous-bindings)))
    (if key-binding-list
	(progn
	  (set other-bindings-var (hmouse-get-bindings nil))
	  (hmouse-set-bindings key-binding-list)
	  (setq hmouse-bindings-flag (not hmouse-bindings-flag))
	  (if (called-interactively-p 'interactive)
	      (message "%s mouse bindings are now in use."
		       (if hmouse-bindings-flag "Hyperbole" "Non-Hyperbole"))))
      (error "(hmouse-toggle-bindings): `%s' is empty."
	     (if hmouse-bindings-flag 'hmouse-previous-bindings 'hmouse-bindings)))))

;;; ************************************************************************
;;; Private variables
;;; ************************************************************************

(defvar hmouse-bindings nil
  "List of (key . binding) pairs for Hyperbole mouse keys.")

(defvar hmouse-bindings-flag nil
  "True if Hyperbole mouse bindings are in use, else nil.")

(defvar hmouse-previous-bindings nil
  "List of prior (key . binding) pairs for mouse keys rebound by Hyperbole.")

(provide 'hmouse-key)

;;; hmouse-key.el ends here
