;; coor-me.s

(define ($empty? input-message)
	(let* 
		(
			(cont (message-content input-message))
			(outport (content-port cont))
		)
		(null? outport)
	)
)

(define ($reconstruct input-message coupled-model destination)
	(let*
        (
			(cont (message-content input-message))
			(outport (content-port cont))
			(value   (content-value cont))
			(source (message-source input-message))
			(time   (message-time input-message))
			(inport (send-if-handles coupled-model translate source destination outport))
			(message (make-ext-message))
        ) 
        (set! cont (make-content 'port inport 'value value))
        (set! (message-content message) cont)
        (set! (message-source message) coupled-model)
        (set! (message-time message) time)
        message
    )
)

(define-method (co-ordinators when-receive-y) (input-message)
	(flash-message devs-component input-message)

	(set! outport
		  ($reconstruct input-message devs-component devs-component)
	)

	(if (not ($empty? outport))
		(send (send parent get-processor) when-receive-y outport)
	)
	(set! event-type 'y)
	(set! mark-time (runtime))

	(set! DESTINATIONS  (send devs-component get-influencees *-child))
	(display (map (lambda (e) (send e get-name)) DESTINATIONS)) 
	(newline)
	(display (map (lambda (e) (send e get-name)) wait-list)) 
	(newline)

	(for-each 
		(lambda (chd)
			(set! outport 
				  ($reconstruct input-message devs-component chd))      
			(if (not ($empty? outport))
				(set! wait-list (cons chd wait-list))
			)
		)
		DESTINATIONS
	)

	(for-each 
		(lambda(chd)
			(set! outport ($reconstruct input-message devs-component chd))
			(send (send chd get-processor) when-receive-x outport)
		)
		(remove *-child wait-list)
	)
)



(define-method (co-ordinators when-receive-x) (input-message)
(set! event-type 'x)
(set! mark-time (runtime))
(flash-message devs-component input-message)

(if (and (less-than-or-equal time-of-last-event
                             (message-time input-message))
         (less-than-or-equal (message-time input-message)
                             time-of-next-event))
	(begin                                                       
		(set! time-of-last-event (message-time input-message))
        (set! DESTINATIONS (send devs-component get-receivers))
        (set! (message-source input-message) devs-component)
        (for-each 
			(lambda (child)
				(set! outport
					  ($reconstruct input-message devs-component child)
				)
				(if (not ($empty? outport))
                    (set! wait-list (cons child wait-list))
                )
            )
			DESTINATIONS
		)
        
		(when (null? wait-list)
            (begin
				(set! outport 
					(make-done-message 'source 
										devs-component
                                        'time time-of-next-event
					)
				)
                (send (send parent get-processor) 
					  when-receive-done outport
				)
            )
        )

        (for-each 
			(lambda(child)
				(set! outport
                      ($reconstruct input-message devs-component child))
				(send (send child get-processor)
                      when-receive-x outport)
            ) 
			wait-list
		)
    )
	(error "error: time in ext-message not in proper bounds" input-message)
) ;; if
) ;; begin

(define-method (co-ordinators when-receive-*) (input-message)
(set! *-mark-time (runtime))
(flash-message devs-component input-message)

       (if  (equal? time-of-next-event (message-time input-message))
            (begin
             (set! time-of-last-event (message-time input-message))
             (set! outport
                     (make-*-message
                                 'source devs-component
                                 'time time-of-next-event
                      )
             )
             (set! wait-list (list *-child))
       (send
            (send *-child get-processor)
                 when-receive-* outport)

            )
        (display "error: time of *-message not = to time of next-event")

    )
)


(define ( compute-imminent tN-list)
(let rep (
        (temp tN-list)
        (ilist '())
        (tN  'inf)
        )
   (if (null? temp)
       (cons ilist tN)
       (cond
          ( (equal? (cdar temp) tN)
           (rep (cdr temp) (cons (caar temp) ilist) tN))
          (  ( less-than (cdar temp) tN)
           (rep (cdr temp) (list (caar temp)) (cdar temp)) )
          (else
             (rep (cdr temp) ilist tN) )
      )
   )
))


(define ( mark-done message wait-list)
(let rep(
      (front '())
      (wlist wait-list)
      (source  (message-source message))
     )
     (cond
      ( (null? wlist) (display "message source not on list") #!false)
      ((equal? (car wlist) source) (append front (cdr wlist)))
      ( else ( rep (cons (car wlist) front) (cdr wlist) source))
     )
))

(define (set-tN  message tN-list)
(let rep (
      (front '())
      (tlist tN-list)
      (source  (message-source message))
      (tN (message-time message))
         )
     (cond
     ( (null? tlist) (display "message source not in list") #!false)
     ( (equal? (caar tlist) source)
               (append front  (cons (set-cdr! (car tlist) tN)
                                          (cdr tlist)))   )
     ( else (rep (cons (car tlist) front) (cdr tlist) source tN))
    )
))

(define-method (co-ordinators when-receive-done) (input-message)
(flash-message devs-component input-message)
  (set! wait-list (mark-done input-message wait-list))
  (set! tN-children (set-tN  input-message tN-children))

  (if (AND (EQUAL? (LENGTH wait-list) 1) (EQUAL? event-type 'y))
    (set! y-time (+ y-time (- (runtime) mark-time)))
  )
  (if (null? wait-list)
    (begin      
      (set! IMMINENT (compute-imminent tN-children))
      (set! *-child
        (eval 
					( 
						(send devs-component get-selectfn)
            (car IMMINENT)
					)
				)
			)              
      (set! time-of-next-event (cdr IMMINENT))
      (set! outport
        (make-done-message
          'source devs-component
          'time time-of-next-event
				)
			)
      (case event-type
        ('x (set! x-time (+ x-time (- (runtime) mark-time))))
        ('y (set! *-time (+ *-time (- (runtime) *-mark-time))))
      )
      (send
        (send parent get-processor)
          when-receive-done outport)
        )
  )
)