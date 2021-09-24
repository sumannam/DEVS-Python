;; simu-me.s

(define (add n1 n2)
  (if
     (or (equal? n1 'inf) (equal? n2 'inf))
       'inf
     (+ n1 n2)
  )
)

(define (sub n1 n2)
  (cond
    ( (equal? n2 'inf) (display "error:trying to subtract inf") n2)
    ( (equal? n1 'inf) 'inf)
    ( else (- n1 n2))
  )
)

(define (less-than n1 n2)
   (cond
      ( (and (not (equal? n1 'inf)) (equal? n2 'inf) ) #!true)
      ( (and (not (equal? n1 'inf)) (not (equal? n2 'inf))
                     (< n1 n2))  #!true)
      (else #!false)
   )
)

(define (less-than-or-equal n1 n2)
 (or (eqv? n1 n2) (less-than n1 n2))
)

(define-structure message
     source
     time
     content
)

(define-structure (*-message (include message)))
       ;  source
       ;  time
;)
(define-structure (ext-message (include message)))

(define-structure  (done-message (include message)))


;(define-structure content
 ;      port
  ;     value
;)


(define-method (simulators when-receive-*) (input-message)   
(set! mark-time (runtime))
(flash-message devs-component input-message)
     (begin
        (if  (equal? time-of-next-event (message-time input-message))
            (begin
				(let* 
					(
						(devs-output (send devs-component output?))
						(out-lst (if (not (pair? devs-output)) 
									(list devs-output)
									devs-output)
						)
						(mes-lst '())
					)
					(set! mes-lst 
							(map 
							  (lambda(cont)
								(set! outport (make-ext-message))
								(set! (message-time outport) (message-time input-message))
								(set! (message-source outport) devs-component)
								(set! (message-content outport) cont) 
								outport
							  )
							  out-lst
							)
					)                         
					(set! *-time (+ *-time (- (runtime) mark-time)))
					
					(for-each 
						(lambda(mes)
							(send
								(send parent get-processor) when-receive-y mes
							)
						) 
						mes-lst
					)
				)
				(set! mark-time (runtime))
				(send devs-component int-transition)
				(set! time-of-last-event (message-time input-message))
				(set! time-of-next-event
						(add time-of-last-event
							(send devs-component time-advance?)
						)
				)

				(set! outport (make-done-message))
				(set! (message-source outport) devs-component)
				(set! (message-time outport) time-of-next-event)
				(set! *-time (+ *-time (- (runtime) mark-time)))
				(send
					(send parent get-processor )
						  when-receive-done outport
				)
			)               
 
			(error "error: time of *-message not = to time of next-event" input-message)

		)
	)
)

(define-method (simulators when-receive-x) (input-message)
(set! mark-time (runtime))
(flash-message devs-component input-message)

(if 
	(and 
		(less-than-or-equal time-of-last-event (message-time input-message))
		(less-than-or-equal (message-time input-message) time-of-next-event)
	)
	(begin
		(send devs-component set-elapsed-time
			(sub (message-time input-message)
				 time-of-last-event)
		)
	   
		(send devs-component set-ext-event (message-content input-message))
		(send devs-component ext-transition)
		(set! time-of-last-event (message-time input-message))
		(set! time-of-next-event
				   (add time-of-last-event
					   (send devs-component                                
								   time-advance? )))
		(set! outport
					  (make-done-message))
		(set! (message-source outport) devs-component)
		(set! (message-time outport) time-of-next-event)
		(set! x-time (+ x-time (- (runtime) mark-time)))
		(send
			(send parent get-processor)
					  when-receive-done outport)
	)
	(error "error: time in ext-message not in proper bounds" input-message)
)
)

;(compile-class processors)


