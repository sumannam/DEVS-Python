

;;;;;;;;;;;;;;;;;;;;forward-models inference engine

;;if before-output is not null then it will be sent first 
;;;then transition will be carried out
;;;then if after-output is not null then it will be sent
;;;THis holds for both internal and external transitions
;;if no output then just carry out transition

(define-structure activity condition action before-output after-output)
;(define-structure state sigma phase interpreter-phase 
;                        before-output-buffer after-output-buffer
;                        action-buffer ext-activities int-activities saved-sigma name)

;(define state-vars '(sigma phase interpreter-phase 
;                     before-output-buffer after-output-buffer
;                     action-buffer ext-activities int-activities saved-sigma name))

(mk-st 'forward-models '(interpreter-phase before-output-buffer 
                         after-output-buffer action-buffer 
                         ext-activities int-activities saved-sigma name))

(define (first-satisfied lst env)
    (let loop (
	       (rem lst)
	      )
      (cond
	((null? rem) '())
	((eval (activity-condition (car rem)) env)
	 (car rem)
        )
	(else
	 (loop  (cdr rem)))
      )
    )
)


(define (ext-for s e x)
  (set! (state-saved-sigma s) (state-sigma s) )
  (case (state-interpreter-phase s)
    ((doing test-condition)    ;;;only phases for receiving input
     (let* (
	    (env (eval (state-name s) user-initial-environment))
	    (act*  (first-satisfied (state-ext-activities s) env))
	    (before-output (when act* (eval (activity-before-output act*) env)))
	    (after-output (when act* (activity-after-output act*)))
	    (action (when act* (activity-action act*)))
	   )


       (set! (state-after-output-buffer s) after-output)
       (cond
	 ((null? act*)
	  (set! (state-interpreter-phase s) 'passive)
	  (set! (state-sigma s) 'inf)
	 )
	 (before-output
	  (set! (state-before-output-buffer s) before-output)
	  (set! (state-action-buffer s)  action)
	  (set! (state-interpreter-phase s) 'before-sending)
          (set! (state-sigma s) 0)
	 )
	 (else
      (set! (state-sigma s) (state-saved-sigma s))  ;;expect action to set sigma
	  (eval action env)                             ;;if not, use saved-sigma
	  (set! (state-interpreter-phase s) 'doing)
	 )
       )
     )
    )
    (else (set! (state-sigma s) (state-saved-sigma s)) 
    ) 
  )
)




(define (int-for s)

  (case (state-interpreter-phase s)
     ('before-sending
        (let (
              (env (eval (state-name s) user-initial-environment))
	       )
          (set! (state-sigma s) (state-saved-sigma s))   ;;expect action to set sigma
          (eval (state-action-buffer s) env)             ;;if not, use saved-sigma
          (set! (state-interpreter-phase s) 'doing)
	)
     )
     ('doing
              (set! (state-interpreter-phase s) 'test-condition)
              (set! (state-sigma s) 0)
     )
     ('test-condition
        (let* (
               (env (eval (state-name s) user-initial-environment))
               (act*  (first-satisfied (state-int-activities s) env))
               (before-output (when act* (eval (activity-before-output act*) env)))
               (after-output (when act* (activity-after-output act*)))
               (action (when act* (activity-action act*)))
              )

           (set! (state-after-output-buffer s) after-output)
           (cond
            ( (null? act*)
	      (set! (state-interpreter-phase s) 'passive)
              (set! (state-sigma s) 'inf)
            )
            ( before-output
              (set! (state-before-output-buffer s) before-output)
              (set! (state-action-buffer s) action)
              (set! (state-interpreter-phase s) 'before-sending)
              (set! (state-sigma s) 0)
            )
            ( else
              (set! (state-sigma s) (state-saved-sigma s))  ;;expect action to set sigma
	             (eval action env)                             ;;if not, use saved-sigma
              (set! (state-interpreter-phase s) 'doing)
            )
           )
        )
     )
     (else
       (set! (state-interpreter-phase s) 'passive)
       (set! (state-sigma s) 'inf)
     )
   )
)


(define (out-for s)
 (let (
      (env (eval (state-name s) user-initial-environment))
      )
   (case (state-interpreter-phase s)
     ('before-sending (state-before-output-buffer s))
     ('doing (cond ((eval (state-after-output-buffer s)env))
                       (else (make-content))))
     (else (make-content))
   )
))

