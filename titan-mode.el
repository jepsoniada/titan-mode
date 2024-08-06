(defvar titan-mode--real-input-decode-map nil)

(defconst titan-mode--modifiers '((meta meta 27 "M-")
				  (control control 26 "C-")
				  (shift shift 25 "S-")
				  (hyper hyper 24 "H-")
				  (super super 23 "s-")
				  (alt alt 22 "A-")))

(defun titan-mode-event-apply-modifier (event modifier)
  (apply #'event-apply-modifier event (alist-get modifier titan-mode--modifiers)))

(defcustom titan-mode-translation-function (lambda (event)
					     (let ((res (vector (titan-mode-event-apply-modifier event 'control))))
					       (message (prin1-to-string res))
					       res))
  "function that transforms event to another event e.g. 'x' to 'C-x'")

(define-minor-mode titan-mode
  "lesser version of `god-mode'"
  :init-value nil
  :global t
  (if titan-mode
      (progn
	(setf titan-mode--real-input-decode-map input-decode-map
	      input-decode-map `(keymap (t . ,(lambda (&rest _)
						(funcall titan-mode-translation-function
							 (elt (this-single-command-keys)
							      (- (length (this-single-command-keys)) 1))))))))
    (progn
      (setf input-decode-map titan-mode--real-input-decode-map))))

(provide 'titan-mode)
