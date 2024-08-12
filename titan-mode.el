(defvar titan-mode--real-input-decode-map nil)
(defvar titan-mode--current-modifiers nil
  "list of modifier symbols")

(defconst titan-mode--modifiers '((meta meta 27 "M-")
				  (control control 26 "C-")
				  (shift shift 25 "S-")
				  (hyper hyper 24 "H-")
				  (super super 23 "s-")
				  (alt alt 22 "A-")))

(defun titan-mode--toggle-modifier (modifier)
  (if (member modifier titan-mode--current-modifiers)
      (setf titan-mode--current-modifiers (remove modifier
						  titan-mode--current-modifiers))
    (add-to-list 'titan-mode--current-modifiers
		 modifier)))

(defun titan-mode-change-modifiers nil
  (interactive)
  (let ((input-loop t))
    (while input-loop
      (let ((key (read-event)))
	(cond ((eq (elt (kbd "<escape>") 0) key) (progn (setf input-loop nil)
							(keyboard-escape-quit)))
	      ((eq (elt (kbd "<return>") 0) key) (setf input-loop nil))
	      ((eq ?m key) (titan-mode--toggle-modifier 'meta))
	      ((eq ?c key) (titan-mode--toggle-modifier 'control))
	      ((eq ?s key) (titan-mode--toggle-modifier 'shift))
	      ((eq ?h key) (titan-mode--toggle-modifier 'hyper))
	      ((eq ?u key) (titan-mode--toggle-modifier 'super))
	      ((eq ?a key) (titan-mode--toggle-modifier 'alt))
	      (t `(message "humongus")))))))

(defun titan-mode-event-apply-modifier (event modifier)
  (apply #'event-apply-modifier event (alist-get modifier titan-mode--modifiers)))

(defcustom titan-mode-translation-function (lambda (event)
					     (vector (let ((res event))
						       (dolist (mod titan-mode--current-modifiers)
							 (setf res (titan-mode-event-apply-modifier res mod)))
						       res)))
  "function that transforms event to another event e.g. 'x' to 'C-x'")

(define-minor-mode titan-mode
  "lesser version of `god-mode'"
  :init-value nil
  :global t
  :keymap `((,(kbd "<escape>") . titan-mode-change-modifiers))
  (if titan-mode
      (progn
	(setf titan-mode--real-input-decode-map input-decode-map
	      input-decode-map `(keymap (escape . nil)
					(t . ,(lambda (&rest _)
						(funcall titan-mode-translation-function
							 (elt (this-single-command-keys)
							      (- (length (this-single-command-keys)) 1))))))))
    (progn
      (setf input-decode-map titan-mode--real-input-decode-map))))

(provide 'titan-mode)
