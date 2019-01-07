;;; system.el --- Control -*- lexical-binding: t; byte-compile-dynamic: t; -*-

;;; Commentary:

;; TODO support other OS's, etc.

(defgroup system.el nil
  ""
  :group 'external)

(defcustom system-no-confirm-interactive nil
  ""
  :tag "Disable Interactive Confirmation Prompt"
  :type 'boolean
  :group 'system.el)

(defcustom system-interactive-confirm-timeout 30
  ""
  :type 'integer
  :group 'system.el)

;;;###autoload
(defun system-lock ()
  "Lock the current user session, and move to the user switcher if possible."
  (interactive)
  (message "Locking screen...")
  ;; TODO more generic
  (start-process-shell-command "lock" nil "xscreensaver-command -lock"))

;;;###autoload
(defun system-reboot (&optional confirm)
  "Reboot the system.

If CONFIRM is non-nil, ask for a yes-or-no confirmation before executing."
  (interactive (not system-no-confirm-interactive))
  (when (or (not confirm)
            (with-timeout (system-interactive-confirm-timeout t)
              (yes-or-no-p "Really reboot system? ")))
    ;; TODO more generic, and without systemctl/systemd
    (start-process-shell-command "reboot" nil "systemctl reboot")))

;;;###autoload
(defun system-shutdown (&optional confirm)
  "Shut down the system.

If CONFIRM is non-nil, ask for a yes-or-no confirmation before executing."
  (interactive (not system-no-confirm-interactive))
  (when (or (not confirm)
            (with-timeout (system-interactive-confirm-timeout t)
              (yes-or-no-p "Really shut down system? ")))
    ;; TODO more generic, and without systemctl/systemd
    (start-process-shell-command "shutdown" nil "systemctl poweroff")))

;;;###autoload
(defun system-suspend (&optional confirm)
  "Suspend the system.

If CONFIRM is non-nil, ask for a yes-or-no confirmation before executing."
  (interactive (not system-no-confirm-interactive))
  (when (or (not confirm)
            (with-timeout (system-interactive-confirm-timeout t)
              (yes-or-no-p "Really suspend system? ")))
    ;; TODO more generic, and without systemctl/systemd
    (start-process-shell-command "suspend" nil "systemctl suspend")))
