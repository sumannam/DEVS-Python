(define (atomic-wind model)

  (set! pause t)

  (send model initial-wind '(17 1)
               (list 5
                     (string-length
                       (symbol->string (send model get-name))
                     )
               )
              '(dum) '(dum)
   )

  (define-method (atomic-models set-ext-event) (ext-event)
                            (window-set-cursor! wind (+ (car cp) 2) (cdr cp))
                            (display "external event x = " wind)

                            ($erase (content-port x) wind)
                            (display " " wind)
                            ($erase (content-value x) wind)

                            (window-set-cursor! wind (+ (car cp) 2) (cdr cp))
                            (display "external event x = " wind)
                            (set! x ext-event)
                            (display (content-port x) wind)
                            (display " " wind)
                            (display (content-value x) wind)

                            (when pause
                            (set! inport (make-winds 'in '(17 1) '(5 0)
                                            (list (content-port x))
                                         )
                            )
                            (let (
                                  (w
                                   (cadr (assoc (content-port x) inport))
                                  )
                                 )
                            (cs-low)
                            (window-clear w)
                            (display (content-value x) w)
                            )
                            )

  )





  (define-method (atomic-models ext-transition) ()
                           (window-set-cursor! wind (car cp) (cdr cp))
                           (display "state s = " wind)
                           ($erase s wind)
                           (if (vector? s)(ext-transfn s e x)
                                         (set! s (ext-transfn s e x)))
                           (window-set-cursor! wind (car cp) (cdr cp))
                            (display "state s = " wind)
                            (display-structure s state-vars ind-vars wind)


                            (when pause
                            (window-clear (get-nw 'cp))
                            (ndisplay-structure s state-vars ind-vars (get-nw 'wind))
                            )
)





  (define-method (atomic-models output?) ()
               (let* (
                     (out (outputfn s))
                     (out-lst (if (not (pair? out))
                                  (list out)
                                  out))
                    )
                    (for-each (lambda(cont)
                          (window-set-cursor! wind (+ (car cp) 3) (cdr cp))
                          (display "output y = " wind)
                          ($erase (content-port y) wind)
                          (display " " wind)
                          ($erase (content-value y) wind)
                           (set! y cont)
                           (window-set-cursor! wind (+ (car cp) 3) (cdr cp))
                           (display "output y = " wind)
                           (display (content-port y) wind)

                           (set! outport
                                 (make-winds 'out  '(17 1) '(5 0)
                                             (list (content-port y))
                                 )
                           )

                           (display " " wind)
                           (display (content-value y) wind)
                               ) out-lst)
                    out

                    (when pause
                    (cs-low)
                    (window-clear (get-nw 'cp))
                    (ndisplay-structure s state-vars ind-vars (get-nw 'wind))
                    (for-each (lambda(cont)
                            (let (
                                 (w (cadr (assoc (content-port
                                             cont) outport)))
                                  )
                                  (window-clear w)
                                  (display (content-value cont) w)

                              )
                                 ) out-lst)
                    );; when
                    out
  ))
  (clear-screen)
)





(define (make-winds type position size inports)
(let (
       (h-start 12)
       (h-threshold 70)
     )
(let  loop (
            (rem-ports inports)
            (assoc-lst '())
            (num 0)
            (v-num 0)    ;; v-num for displaying state-vars at new line
           )
(cond
 ((null? rem-ports) assoc-lst)
  (else (set! assoc-lst
           (cons (let* (
                   (banner
                             (if (null? (car rem-ports))
                                 ()
                                 (symbol->string (car rem-ports))
                             )
                   )
                   (w (make-window banner #!true))
                   (v-offset (case type
                              ('in  1)  ;;  (+ 1 (* num 1))
                              ('out  1) ;;  (+ 1 (* num 1))
                                        ;; ports always same position

                              ('state (+ (- (car size) 1) v-num))
                           ))
                   (h-offset (case type
                              ('in  1)
                              ('out 23) ;;; (+1 (cadr size)) ffffff
                              ('state (+ h-start (* num 11)))
                             )
                   )
                 )


               (if (> (+ h-start (* num 11))  h-threshold)
                    (begin
                       (set!  v-num 2)
                       (set! num 0)
                       (set! v-offset (+ v-offset 2))
                       (set! h-offset h-start)
                    )
               )

               (window-set-position! w (+ (car position) v-offset)
                                       (+ (cadr position) h-offset)
               )
               (window-set-size! w  1 10)
             ;;  (window-clear w)   hide while initializing
               (list (car rem-ports) w)
               ) assoc-lst))
               (loop (cdr rem-ports) assoc-lst (1+ num) v-num)
      )
))))



(define-method (atomic-models inject) (port value . elapsed-time)
(set-ext-event (make-content 'port port 'value value))
(when elapsed-time (set-e (car elapsed-time)))
(ext-transition)
)

