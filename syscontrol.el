;;; syscontrol.el --- Emacs system control interface -*- lexical-binding: t; byte-compile-dynamic: t -*-

;; Author: Will Dey
;; Maintainer: Will Dey
;; Version: 1.0.0
;; Package-Requires: ()
;; Homepage: https://github.com/wi11dey/syscontrol.el
;; Keywords: keywords

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;; Generate README:
;;; Commentary:

;; Emacs system control interface

;;; Code:

;; TODO Multi-platform support and auto-select

(defgroup syscontrol nil
  ""
  :group 'external)

(defcustom syscontrol-interactive-confirm t
  ""
  :type 'boolean)

(defcustom syscontrol-interactive-confirm-timeout 30
  ""
  :type 'integer)

(defmacro syscontrol--interactive-message (format-string &rest args)
  `(when (called-interactively-p 'interactive)
     (message ,format-string ,@args)))


;;; System state

;;;###autoload
(defun syscontrol-lock ()
  "Lock the current user session, and move to the user switcher if possible."
  (interactive)
  (message "Locking screen...")
  ;; TODO more generic
  (start-process-shell-command "lock" nil "xscreensaver-command -lock"))

;;;###autoload
(defun syscontrol-reboot (&optional confirm)
  "Reboot the system.

If CONFIRM is non-nil, ask for a yes-or-no confirmation before executing."
  (interactive (list syscontrol-interactive-confirm))
  (when (or (not confirm)
            (with-timeout (syscontrol-interactive-confirm-timeout t)
              (yes-or-no-p "Really reboot system? ")))
    (message "Rebooting system...")
    ;; TODO more generic, and without systemctl/systemd
    (start-process-shell-command "reboot" nil "systemctl reboot")))

;;;###autoload
(defun syscontrol-shutdown (&optional confirm)
  "Shut down the system.

If CONFIRM is non-nil, ask for a yes-or-no confirmation before executing."
  (interactive (list syscontrol-interactive-confirm))
  (when (or (not confirm)
            (with-timeout (syscontrol-interactive-confirm-timeout t)
              (yes-or-no-p "Really shut down system? ")))
    (message "Shutting down system...")
    ;; TODO more generic, and without systemctl/systemd
    (start-process-shell-command "shutdown" nil "systemctl poweroff")))

;;;###autoload
(defun syscontrol-suspend (&optional confirm)
  "Suspend the system.

If CONFIRM is non-nil, ask for a yes-or-no confirmation before executing."
  (interactive (list syscontrol-interactive-confirm))
  (when (or (not confirm)
            (with-timeout (syscontrol-interactive-confirm-timeout t)
              (yes-or-no-p "Really suspend system? ")))
    (message "Suspending system...")
    ;; TODO more generic, and without systemctl/systemd
    (start-process-shell-command "suspend" nil "systemctl suspend")))


;;; Volume

(defgroup syscontrol-volume nil
  ""
  :group 'syscontrol)

(defcustom syscontrol-volume-default-step 5
  ""
  :type 'number)

(defcustom syscontrol-volume-auto-unmute t
  ""
  :type 'boolean)

;;;###autoload
(defun syscontrol-volume-muted-p ()
  (interactive)
  (let ((muted nil))
    ;; TODO
    (syscontrol--interactive-message "Currently %s" (if muted "muted" "unmuted"))
    muted))

;;;###autoload
(defun syscontrol-volume-mute ()
  (interactive)
  (call-process "amixer" nil nil nil
		"set" "Master" "mute")
  (syscontrol--interactive-message "Muted"))

;;;###autoload
(defun syscontrol-volume-unmute ()
  (interactive)
  (call-process "amixer" nil nil nil
		"set" "Master" "unmute")
  (syscontrol--interactive-message "Unmuted"))

(defun syscontrol--volume-do-auto-unmute ()
  (when syscontrol-volume-auto-unmute
    (syscontrol-volume-unmute)))

;;;###autoload
(defun syscontrol-volume-get ()
  (interactive)
  (let ((volume 0))
    ;; TODO
    (syscontrol--interactive-message "Volume: %d" volume)
    volume))

;;;###autoload
(defun syscontrol-volume-set (level)
  (interactive "nNew volume level: ") ;; TODO add previous level in prompt
  (syscontrol--volume-do-auto-unmute)
  )

;;;###autoload
(defun syscontrol-volume-add (level-delta)
  (interactive "nChange volume by: ")
  (syscontrol--volume-do-auto-unmute)
  (call-process "amixer" nil nil nil
		"set" "Master" (format "%d%%%c"
				       (abs level-delta)
				       (if (< level-delta 0)
					   ?-
					 ?+))))

;;;###autoload
(defun syscontrol-volume-default-increment ()
  (interactive)
  (syscontrol--volume-do-auto-unmute)
  (syscontrol-volume-add syscontrol-volume-default-step)
  (syscontrol--interactive-message "Volume up"))

;;;###autoload
(defun syscontrol-volume-default-decrement ()
  (interactive)
  (syscontrol--volume-do-auto-unmute)
  (syscontrol-volume-add (- syscontrol-volume-default-step))
  (syscontrol--interactive-message "Volume down"))



(provide 'syscontrol)
