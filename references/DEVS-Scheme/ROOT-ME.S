;; root-me.s

(define (timer n)
  (let
		(
			(tim0 (runtime))
		)
  (let rep 
		(
			(tim tim0)
    )
;     (flush-input 'console)
	(if (< tim (+ tim0 n)) 
		(rep (runtime))
	)

;     (if (char-ready?)
;           (bkpt "stopped before next transition" (read-char) ))

)))

(define pause #!true)

(define time-gen
  (lambda()
   (let ((n 0))
    (lambda (req)
       (case req
         (set-interval  (lambda(m)(set! n m)))
         (run-it        (lambda() (timer n)))
     )
    )
  )
))



(define set-interval 
	(lambda(time-gen m)
		((time-gen 'set-interval) m)
	)
)


(define run-it 
	(lambda(time-gen)
		((time-gen 'run-it))
	)
)



(define-method (root-co-ordinators when-receive-y)(input-message)
(flash-message devs-component input-message)
)


;; changed to accomodate start-log

(define-method (root-co-ordinators when-receive-done) (input-message)
	(when terminate
			(set! terminate '())
			(bkpt "stopped in complete state at "
										 (add clock-base (message-time input-message)))
	)

	(flash-message devs-component input-message)
	(run-it timer)
	(set! %start-message
				(make-*-message 'source name
												'time (message-time input-message)
				)
	)
	(let 
		(
			(wind (send devs-component get-wind))
		)
		(window-clear wind)
		(window-set-cursor! wind 0 0)
		(display-window wind 
			"clock time: " (add clock-base (message-time input-message) ) #\newline
			"relative to " #\newline "clock-base: " (message-time input-message)
		)

	)

	(when log-file-flag
		(set! log-file (open-extend-file log-file-name))
		(newline log-file)
		(display "clock time: " log-file)
		(display (add clock-base (message-time input-message)) log-file)
		(newline log-file)
		(close-output-port log-file)
	) ;; when log-file-flag
)