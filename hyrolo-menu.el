;;; hyrolo-menu.el --- Pulldown and popup menus of HyRolo commands  -*- lexical-binding: t; -*-
;;
;; Author:       Bob Weiner
;;
;; Orig-Date:    28-Oct-94 at 10:59:44
;; Last-Mod:     18-Apr-22 at 00:29:31 by Mats Lidell
;;
;; Copyright (C) 1994-2022  Free Software Foundation, Inc.
;; See the "HY-COPY" file for license information.
;;
;; This file is part of GNU Hyperbole.

;;; Commentary:

;;; Code:
;;; ************************************************************************
;;; Other required Elisp libraries
;;; ************************************************************************

(require 'easymenu)
(require 'hyrolo)

;;; ************************************************************************
;;; Public variables
;;; ************************************************************************

(defconst infodock-hyrolo-menu
  '("Rolo"
    ["Manual"                  (id-info "(hyperbole)HyRolo")            t]
    "----"
     ;; Delete Rolo menu from all menubars.
    ["Remove-This-Menu"        (hui-menu-remove Rolo hyrolo-mode-map)   t]
    "----"
    ["Add-Entry"               (id-tool-invoke 'hyrolo-add)             t]
    ["Delete-Entry"            (id-tool-invoke 'hyrolo-kill)            t]
    ["Display-Prior-Matches"   (id-tool-invoke 'hyrolo-display-matches) t]
    ["Edit-Entry"              (id-tool-invoke 'hyrolo-edit)            t]
    ["Find-HyRolo-File"        (id-tool-invoke
				(lambda ()
				  (require 'hyrolo)
				  (hyrolo-find-file)))
     t]
    ["Insert-Entry-at-Point"   (id-tool-invoke 'hyrolo-yank)            t]
    ["Mail-to-Address"         (id-tool-invoke 'hyrolo-mail-to)         t]
    ["Search-for-Regexp"       (id-tool-invoke 'hyrolo-grep)            t]
    ["Search-for-String"       (id-tool-invoke 'hyrolo-fgrep)           t]
    ["Search-for-Word"         (id-tool-invoke 'hyrolo-word)            t]
    ["Sort-Entries"            (id-tool-invoke 'hyrolo-sort)            t]))

(defconst hyrolo-menu-common-body
  '(
    ("Move"
     ["Scroll-Backward"        scroll-down                              t]
     ["Scroll-Forward"         scroll-up                                t]
     ["To-Beginning"           beginning-of-buffer                      t]
     ["To-End"                 end-of-buffer                            t]
     "----"
     ["To-Next-Entry"          outline-next-visible-heading             t]
     ["To-Next-Same-Level"     outline-forward-same-level               t]
     ["To-Previous-Entry"      outline-previous-visible-heading         t]
     ["To-Previous-Same-Level" outline-backward-same-level              t]
     ["Up-a-Level"             outline-up-heading                       t])
    ("Outline"
     ["Hide (Collapse)"        outline-hide-subtree                     t]
     ["Show (Expand)"          outline-show-subtree                     t]
     ["Show-All"               outline-show-all                         t]
     ["Show-Only-First-Line"   outline-hide-body                        t]))
  "The middle menu entries common to all HyRolo menus.")

(defconst id-popup-hyrolo-menu
  (append
   '("Rolo"
     ["Help"                   describe-mode                            t]
     ["Manual"                 (id-info "(hyperbole)Rolo Keys")         t]
     "----"
     ["Edit-Entry-at-Point"    hyrolo-edit-entry                        t]
     "----"
     ["Locate-Entry-Isearch"   hyrolo-locate                            t]
     ["Next-Match"             hyrolo-next-match                        t]
     ["Previous-Match"         hyrolo-previous-match                    t]
     "----")
   `,@hyrolo-menu-common-body
   (list infodock-hyrolo-menu)
   '("----"
     ["Quit"                   (id-tool-quit '(hyrolo-quit))            t])))

;;; ************************************************************************
;;; Public functions
;;; ************************************************************************

(defun hyrolo-menubar-menu ()
  "Add a HyRolo menu to the rolo match buffer menubar."
  (define-key hyrolo-mode-map [C-down-mouse-3] 'hyrolo-popup-menu)
  (define-key hyrolo-mode-map [C-mouse-3] nil)
  (unless (global-key-binding [menu-bar Rolo])
    (easy-menu-define nil hyrolo-mode-map "Rolo Menubar Menu" id-popup-hyrolo-menu)
    ;; Force a menu-bar update.
    (force-mode-line-update)))

(defun hyrolo-popup-menu (event)
  "Popup the Hyperbole Rolo match buffer menu."
  (interactive "@e")
  (mouse-set-point event)
  (popup-menu id-popup-hyrolo-menu))

(add-hook 'hyrolo-mode-hook #'hyrolo-menubar-menu)

(provide 'hyrolo-menu)

;;; hyrolo-menu.el ends here
