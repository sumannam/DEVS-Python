(fresh-line)
(newline) (newline)
(when (unbound? model-base_directory)
   (display "enter model-base directory in string form : ")
   (define model-base_directory (read))
)
(when (unbound? entstr-base_directory)
   (display "enter entstr-base directory in string form : ")
   (define entstr-base_directory (read))
)
(writeln "The current model-base directory is " 
         (if (string=? model-base_directory "")
             " current default directory"
             model-base_directory
         )
)
(writeln "The current entstr-base directory is " 
         (if (string=? entstr-base_directory "")
             " current default directory"
             entstr-base_directory
         )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define en-mgr (entstr-manager))
(init-enmgr en-mgr)
(define ent-nm-ctr (name-counter))
(define name-ctr (name-counter))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







