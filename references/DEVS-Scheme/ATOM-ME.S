;; atom-me.s

(define (int-a s) (set! (state-phase s) 'active) s)
(define (ext-a s e x) (set! (state-phase s) (content-value x)) s)
(define (out-a s) (make-content 'port 'out 'value (state-phase s)))
(define (ta-a s)(state-sigma s))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define ($erase x wind)
  (display (make-string (print-length x) #\space) wind)
)

(define-method (atomic-models def-int-transfn) ()
                                   (window-clear 'console)
         (display "enter internal transition fn for model " 'console)
                                    (display name 'console)
                                    (set! int-transfn (eval (read)))

)
(define-method (atomic-models def-ext-transfn) ()
                                   (window-clear 'console)
          (display "enter external transition fn for model " 'console)
                                   (display name 'console)

                                   (set! ext-transfn (eval (read)))

)
(define-method (atomic-models def-outputfn) ()
                                   (window-clear 'console)
        (display "enter output  fn  for model " 'console)
                                   (display name 'console)
                                   (set! outputfn (eval (read)))

)
(define-method (atomic-models def-time-advancefn)  ()
                                   (window-clear 'console)
         (display "enter time advance  fn  for model " 'console)
                                   (display name 'console)
                                   (set! time-advancefn (eval (read)))

)

(define-method (atomic-models set-state)()
   (cs-low)
   (window-clear (get-nw 'cp))
   (ndisplay-structure s state-vars ind-vars-wind (get-nw 'wind))
   (window-popup initialize-window)
      (if (equal? 'init-cell (get-cell-position))
          (display-window initialize-window
             "Wish to set " name " : INIT-CELL of "
                      (send parent get-name))
          (display-window  initialize-window
             "Wish to change  (state /display) " name
         )
      )
      (display "? (y/n/d)" initialize-window)
      (newline initialize-window)
      (case (read initialize-window)
        ('y
          (set! s (nget-structure s state-vars ind-vars-wind
                    (get-nw 'wind)
                  )
          )

          (window-clear initialize-window)
          (display-window initialize-window "enter  elapsed time ")
          (newline initialize-window)
          (display-window initialize-window "elapsed time e = ")
          (set! e (read initialize-window))

          (set-state)
        )
        ('d (state-var-display-request))
        (else
            (window-popup-delete initialize-window)
        )
      )
      (cs-low)
)



(define-method (atomic-models set-ext-event) (ext-event)
                      (when display-message-window
                            (window-set-cursor! wind (+ (car cp) 2) (cdr cp))
                            (display "external event x = " wind)

                            ($erase (content-port x) wind)
                            (display " " wind)
                            ($erase (content-value x) wind)

                            (window-set-cursor! wind (+ (car cp) 2) (cdr cp))
                            (display "external event x = " wind)
                      ) ;; when

                            (set! x ext-event)

                      (when display-message-window
                            (display (content-port x) wind)
                            (display " " wind)
                            (display (content-value x) wind)
                      ) ;; when display-message-window

                            ;; need not check nw-flag since ext-ext-event
                            ;; does not overlap with start-log files

                           (when (and display-model-window (get-nw 'display))
                                ;; change and -> or for nw fast model display
                            (let (
                                  (w
                                   (cadr (assoc (content-port x) inport))
                                  )
                                 )
                            (cs-low)

                            (when (null? w)
                                 (set! w
                                     (cadar (make-winds
                                           'in
                                           (list 17 1)
                                           ;; (list v-start 1)

                                ;;--- 3rd argument of make-wind ----
                                 (list 5
                                    (let
                                     ((hor-length
                                       (string-length
                                         (symbol->string name)
                                       )
                                      )
                                     )
                                     (if (> hor-length 10)
                                          hor-length
                                          10
                                     ) ;; restrict minimum hor. model
                                        ;; with as 10
                                    ) ;; let
                                 )
                              ;; min. of (list v-gap 10 or model-name leng.)

                              ;;----- end of 3rd argument of make-wind ----

                                         (list
                                          (if (pair? (content-port x))
                                              (cadr (content-port x))
                                              (content-port x)
                                           )
                                         ) ;; need for level access case

                                        ) ;; make-wind
                                     ) ;; cadar
                                 )  ;; set!
                             ) ;; when (null? w)


                            (window-clear w)
                            (display (content-value x) w)
                            ) ;; let
                           ) ;; when display-model-window (get-nw 'display)

 )




(define-method (atomic-models external-message?) (source port)
(if (equal? source (eval name))
    #t
    #f
))



 (define-method (atomic-models set-elapsed-time) (elapsed-time)
                      (when display-message-window
                            (window-set-cursor! wind (+ (car cp) 1) (cdr cp))
                            (display "elapsed time e = " wind)
                            ($erase e wind)
                            (window-set-cursor! wind (+ (car cp) 1) (cdr cp))
                            (display "elapsed time e = " wind)
                      )

                            (set! e elapsed-time)

                      (when display-message-window
                            (display e wind)
                      )
 )




 (define-method (atomic-models int-transition) ()
                       (when display-message-window
                           (window-set-cursor! wind  (car cp) (cdr cp))
                           (display "state s = " wind)

                           ($erase s wind)
                       ) ;; when

                           (if (vector? s)(int-transfn s) ;for use w/structure
                                        (set! s (int-transfn s)))

                       (when display-message-window
                           (window-set-cursor! wind  (car cp) (cdr cp))
                           (display "state s = " wind)
                           (display-structure s state-vars ind-vars-wind wind)
                       ) ;; when

                           (when log-file-flag
                              (set! log-file (open-extend-file log-file-name))
                              (newline log-file)
                              (display (get-name) log-file)
                              (display " " log-file)
                              (display "state s = " log-file)
                              (display&file-structure s state-vars ind-vars log-file)
                              (newline log-file)
                              (close-output-port log-file)
                           ) ;; when log-file-flag
  )





  (define-method (atomic-models ext-transition) ()

                      (when display-message-window
                           (window-set-cursor! wind (car cp) (cdr cp))
                           (display "state s = " wind)
                           ($erase s wind)
                      ) ;; when

                           (if log-file-flag
                             (if (vector? s)
                                (begin
                                  (close-output-port log-file) ;; for introspection
                                  (ext-transfn s e x))
                                            (set! s (ext-transfn s e x)))
                             (if (vector? s)(ext-transfn s e x)
                                           (set! s (ext-transfn s e x)))
                           ) ;; if

                      (when display-message-window
                           (window-set-cursor! wind (car cp) (cdr cp))
                            (display "state s = " wind)
                            (display-structure s state-vars ind-vars-wind
                              wind)

                      ) ;; when display message-window


                           (when display-model-window
                             (when  (get-nw 'display)
                               (window-clear (get-nw 'cp))
                               (ndisplay-structure s state-vars ind-vars-wind
                                (get-nw 'wind)
                               )

                               (when pause
                                     (key-menu&zhang (eval name))
                               )

                             ) ;; when
                           ) ;; when  display-model-window

                           (when log-file-flag
                              (set! log-file (open-extend-file log-file-name))
                              (display (get-name) log-file)
                              (display " " log-file)
                              (display "input x = " log-file)
                              (display (content-port x) log-file)
                              (display " " log-file)
                              (display (content-value x)
                                log-file)
                              (newline log-file)
                              (display (get-name) log-file)
                              (display " " log-file)
                              (display "state s = " log-file)
                              (display&file-structure s state-vars ind-vars log-file)
                              (newline log-file)
                              (close-output-port log-file)
                           ) ;; log-file-flag


)





(define-method (atomic-models output?) ()
               (let* (
                     (out (outputfn s))
                     (out-lst (if (not (pair? out))
                                  (list out)
                                  out))
                    )

                    (for-each (lambda(cont)
                       (when display-message-window
                          (window-set-cursor! wind (+ (car cp) 3) (cdr cp))
                          (display "output y = " wind)
                          ($erase (content-port y) wind)
                          (display " " wind)
                          ($erase (content-value y) wind)
                       ) ;; when

                           (set! y cont)

                       (when display-message-window
                           (window-set-cursor! wind (+ (car cp) 3) (cdr cp))
                           (display "output y = " wind)
                           (display (content-port y) wind)
                           (display " " wind)
                           (display (content-value y) wind)
                       ) ;; when
                               ) out-lst)
                    out



                    (when display-model-window
                      (when (get-nw 'display)
                      (cs-low)
                      (window-clear (get-nw 'cp))
                      (ndisplay-structure s state-vars ind-vars-wind
                        (get-nw 'wind))
                      (for-each (lambda(cont)
                              (let (
                                   (w (cadr (assoc (content-port
                                               cont) outport)))
                                    )

                                    (when
                                        (and (null? w)
                                             (not (null? (content-port cont)))
                                        )  ;; (content-port cont) is
                                           ;; to prevent error when forward
                                           ;; models are producing dummy
                                           ;; outpus '(()())


                                        (set! w
                                            (cadar (make-winds
                                                  'out
                                                  (list 17 1)
                                                  ;; (list v-start 1)

                                  ;;--- 3rd argument of make-wind ----
                                   (list 5
                                      (let
                                       ((hor-length
                                         (string-length
                                           (symbol->string name)
                                         )
                                        )
                                       )
                                       (if (> hor-length 10)
                                            hor-length
                                            10
                                       ) ;; restrict minimum hor. model
                                          ;; with as 10
                                      ) ;; let
                                   )
                                ;; min. of (list v-gap 10 or model-name leng.)

                                ;;----- end of 3rd argument of make-wind ----

                                                (list
                                                 (if (pair? (content-port cont))
                                                     (cadr (content-port cont))
                                                     (content-port cont)
                                                  )
                                                ) ;; need for level access case

                                               ) ;; make-wind
                                            ) ;; cadar
                                        )  ;; set!
                                    ) ;; when

                                  (window-clear w)
                                  (display (content-value cont) w)

                              )
                                 ) out-lst)
                      (when (and pause (content-port y))
                            (key-menu&zhang (eval name))
                      )

                      );; when (get-nw 'display)
                    ) ;; when display-model-window

                    (when log-file-flag
                      (set! log-file (open-extend-file log-file-name))
                      (for-each (lambda(cont)
                           (newline log-file)
                           (display (get-name) log-file)
                           (display " " log-file)
                           (display "output y = " log-file)
                           (display (content-port y) log-file)
                           (display " " log-file)
                           (display (content-value y)
                             log-file)

                               ) out-lst)
                      (newline log-file)
                      (close-output-port log-file)
                    ) ;; when log-file-flag

                    out

))




(define-method (atomic-models time-advance?) ()
                         (when display-message-window
                           (window-set-cursor! wind (+ (car cp) 4) (cdr cp))
                           (display "time-advance ta = " wind)
                           ($erase ($clip ta 2) wind)
                         ) ;; when

                           (set! ta (time-advancefn s))

                         (when display-message-window
                           (window-set-cursor! wind (+ (car cp) 4) (cdr cp))
                           (display "time-advance ta = " wind)
                           (display ($clip ta 2) wind)
                         ) ;; when

                           ta
)


;;;;;;;;;;;;;;;;;;;;;;;;;;


(define (add-state-vars new-vars)
     (let (
          (vars (union2 state-vars new-vars))
                        ; (getcv atomic-models state-vars) new-vars))
          )
(set! state-vars vars)
;(setcv  atomic-models state-vars vars)
(eval `(define-structure state ,@ vars) user-initial-environment)
))


;;;;;;variables not displayed are made into pairs, eg (v) means don't
;;;;;;display v; then state-var cannot equal? ind-var



(define-method (atomic-models state-var-display-request)()
(let (
      (marked-ind-vars-wind (map (lambda(ind)
                             (display-window initialize-window
                                "Display this variable? "
                                 (if (pair? ind) (car ind) ind)
                                " (y/n)"
                             )
                       (if (equal? (read initialize-window) 'n)
                           (if (pair? ind) ind (list ind))
                           (if (pair? ind) (car ind) ind)
                       )
                            ) ind-vars-wind)
     )
    )
(set! ind-vars-wind marked-ind-vars-wind)
(set-nw 'wind (make-winds 'state '(17 1) '(5 12) (remove-pair ind-vars-wind)))
(set-state)
))
            ;; reinitialize windows so that only desired windows
            ;; can be displayed (by make-winds)




(define (get-structure s state-vars ind-vars wind)
(if (vector? s)
    (begin
    (window-clear initialize-window)
    (display "enter the variable values in order:" initialize-window)
    (newline initialize-window)
    (let (
         (vals '())
         (lst '())
         (old-s (cdr (vector->list s)))
         (display-vars (clean (map (lambda(ind)(when (symbol? ind)ind))
                          ind-vars)))
         )
      (print display-vars initialize-window)
      (let loop (
                )
       (set! vals (read wind))
       (when (not (= (length vals)(length display-vars)))
             (display "NUMBER OF ENTRIES NOT CORRECT!!!!")
             (loop)
       )
       )
       (set! lst (map (lambda(state-var)
                         (cond
                             ((equal? state-var (car ind-vars))
                                    (begin0 (car vals)
                                           (set! old-s (cdr old-s))
                                           (set! vals (cdr vals))
                                           (set! ind-vars (cdr ind-vars))
                                    )
                              )
                              ( (and (pair? (car ind-vars))
                                   (equal? state-var (caar ind-vars)))
                                    (begin0 (car old-s)
                                            (set! old-s (cdr old-s))
                                            (set! ind-vars (cdr ind-vars))
                                    )
                               )
                               (else (set! old-s (cdr old-s))
                                     '()
                                )
                           )
                                    ) state-vars))

         (list->vector (cons (vector-ref s 0) lst))
    ))
(read wind)
))


(define (display-structure s state-vars ind-vars wind)
(define (mark val)
(if (null? val) '- ($clip val 1))
)

(define (comp-lst v state-vars ind-vars)
(map (lambda(state-var)
      (begin0
         (cond

                     ( (equal? state-var (car ind-vars))
                              (begin0 (mark (car v))

                                      (set! ind-vars (cdr ind-vars))
                               )
                      )
                      ((and (pair? (car ind-vars))
                                   (equal? state-var (caar ind-vars)))

                                     (set! ind-vars (cdr ind-vars))
                                     '()
                      )
         )
         (set! v (cdr v))
     );begin0
                         ) state-vars)
)
(if (vector? s)
    (let* (
         (v (cdr (vector->list s)))
         (lst (comp-lst v state-vars ind-vars))
         )
         (display (clean lst) wind)
    )
    (display s wind)
))


(define-method (atomic-models get-sv)(var)
(let (
     (nm (symbol-append 'state- var))
     )
 (eval `(,nm s))
 ))

(define-method (atomic-models set-sv)(var val)
(let (
     (nm (symbol-append 'state- var))
     )
(eval `(set! (,nm s) ',val))
 ))

(define-method (atomic-models set-pairs)(pairs)
(for-each (lambda(pair)(set-sv (car pair)(cadr pair))) pairs)
)

(define-method (atomic-models get-vals)(list)
(map get-sv list)
)


(define-method (atomic-models def-state)(vars)
(set! ind-vars (map (lambda(ind)(if (pair? ind)(car ind)ind))ind-vars))
(add-state-vars  vars)
(set! ind-vars (align  state-vars
        (append '(sigma phase) (union2 ind-vars vars))))       ;changed from union2
(let loop (
      (sl (vector->list s))
      )
(if (= (length sl)(1+ (length state-vars))) (set! s (list->vector sl))
(loop (append sl (list '())))
)
))


(define-method (atomic-models set-display)(state-var)
(set! ind-vars-wind (map (lambda(in)
    (if (or (equal? in 'sigma) (equal? in '(sigma))
            (equal? in 'phase) (equal? in '(phase))
           (equal? in state-var) (equal? in (list state-var))
        )
        (if (pair? in) (car in) in)
        (if (pair? in) in (list in))
    )) ind-vars-wind)
 )
)



(define-method (atomic-models ninitial-state)()
  (display-window initialize-window "Initialize or Display "
                   (get-name) " ? (i/d/n)" #\newline)
  (case (read initialize-window)
    ( (d D)  ;; display and set-state
      (set-nw 'display #t)
      (hide-nw-parent (eval name))
      (ninitial-state)
    )
    ( (i I)  ;; no display but set-state
      (set-state)
    )
  ) ;; case
)


(define-method (atomic-models initial-state)() (set-state))

(define-method (atomic-models copy-state)(m)  ;send m copy-state m1 (no ')
   (let* (
           (sm  (send m get-s))
           (lm (if (vector? sm) (vector->list sm) sm))
         )
       (set! s (if (vector? sm) (list->vector lm) sm))                          
       (set! e (send m get-e))
;       (if (eq? (current-output-port) 'console)(window-clear wind))
   )
)

(define-method (atomic-models make-copy) (m)    ;m is new model
(make-new m)
)

                                                                  
(define-method (atomic-models make-new)(m-nm)
(let* (
     (class (eval (class-of-object (eval name)))) ;assumes (define name ...)
     (m (make-entity class m-nm) )
     (sim-nm  (string->symbol(string-append "S:"(symbol->string m-nm))))
     (sim (make-entity simulators sim-nm))
    )
(attach sim m)
(eval `(begin
(send ,m set-ind-vars ',ind-vars)
(send ,m set-int-transfn ,int-transfn)
(send ,m set-ext-transfn ,ext-transfn)
(send ,m set-outputfn ,outputfn)
(send ,m copy-state ,name)
))
(eval `(define ,sim-nm ,sim) user-initial-environment)                                        
(eval `(define ,m-nm ,m) user-initial-environment)
(writeln "atomic model and simulator made: " m-nm " " sim-nm)
m
))


;;;;;;;;for testing 

(define-method (atomic-models inject)(port  value . elapsed-time)
(set-x (make-content 'port port 'value value))
(when elapsed-time (set-e (car elapsed-time)))
(ext-transition)
)

;;;;;;;when have name as state var can use:

(define-method (atomic-models get-your-name)()
 (when (or (member 'name ind-vars)(member '(name) ind-vars))
     (eval `(set! (state-name ,s) ',name))
))

(macro myself (lambda (ex)
   '(eval (state-name s) user-initial-environment)
))

(macro my-eval (lambda(ex)
  (let (
       (exp (cadr ex))
       )
  `(eval ,exp  (myself))
  )
))

;;Suppose you have just corrected a file "mod.m"
;;(send mod modify) will update all the models which
;;have mod as their base name
;;eg mod0, mod1, etc. in a kernel-model

(define-method (atomic-models modify)()
(load (string-append model-base_directory
          (symbol->string name) ".m"))
(for-each (lambda(m)
   (when (base-name (send m get-name))
     (send m set-ext-transfn
         (send (eval name)  get-ext-transfn))
     (send m set-int-transfn
         (send (eval name)  get-int-transfn))
     (send m set-outputfn
         (send (eval name)  get-outputfn))
   ))(getcv atomic-models lst))
)


;;; display-structure for new-wind

(define (ndisplay-structure s state-vars ind-vars-wind wind-lst)
(define (mark val)
(if (null? val) '- ($clip val 1))
)

(define (comp-lst v state-vars ind-vars-wind)
(map (lambda(state-var)
      (begin0
         (cond

                     ( (equal? state-var (car ind-vars-wind))
                              (begin0 (list
                                        (car ind-vars-wind)
                                        (mark (car v))
                                        )
                                      (set! ind-vars-wind (cdr ind-vars-wind))
                               )
                      )
                      ((and (pair? (car ind-vars-wind))
                                   (equal? state-var (caar ind-vars-wind)))

                                     (set! ind-vars-wind (cdr ind-vars-wind))
                                     '()
                      )
         )
         (set! v (cdr v))
     );begin0
                         ) state-vars)
)
(if (vector? s)
    (let* (
         (v (cdr (vector->list s)))
         (lst (comp-lst v state-vars ind-vars-wind))
         )
         (display-each (clean lst) wind-lst)
    )
    (display s wind-lst)
))




;;;;;;variables not displayed are made into pairs, eg (v) means don't
;;;;;;display v; then state-var cannot equal? ind-var





(define (nget-structure s state-vars ind-vars-wind wind-lst)
(if (vector? s)
    (begin
    (window-clear initialize-window)
    (display "enter the variable values in order:" initialize-window)
    (newline initialize-window)
    (let (
         (vals '())
         (lst '())
         (old-s (cdr (vector->list s)))
         (display-vars (clean (map (lambda(ind)(when (symbol? ind)ind))
                          ind-vars-wind)))
         )
      (print display-vars initialize-window)
      (let loop (
                )
       (set! vals (get-each display-vars wind-lst))
       (when (not (= (length vals)(length display-vars)))
             (display "NUMBER OF ENTRIES NOT CORRECT!!!!")
             (loop)
       )
       )
       (set! lst (map (lambda(state-var)
                         (cond
                             ((equal? state-var (car ind-vars-wind))
                                    (begin0 (car vals)
                                           (set! old-s (cdr old-s))
                                           (set! vals (cdr vals))
                                           (set! ind-vars-wind
                                                 (cdr ind-vars-wind))
                                    )
                              )
                              ( (and (pair? (car ind-vars-wind))
                                   (equal? state-var (caar ind-vars-wind)))
                                    (begin0 (car old-s)
                                            (set! old-s (cdr old-s))
                                            (set! ind-vars-wind
                                                  (cdr ind-vars-wind))
                                    )
                               )
                               (else (set! old-s (cdr old-s))
                                     '()
                                )
                           )
                                    ) state-vars))

         (list->vector (cons (vector-ref s 0) lst))
    ))
(read wind-lst)
))




(define (get-each lst wind-lst)
 (let loop (
           (rem-lst lst)
           (val-lst '())
           )
(cond
  ((null? rem-lst) val-lst)
  (else (let* (
               (w (cadr (assoc (car rem-lst) wind-lst)))
             ;;  (w-pos (window-get-position w))
               (val '())
             )
        ;; (window-set-cursor! w (1+ (car w-pos)) (1+ (cdr w-pos)))
         (window-clear w)
         (set! val (read w))
         (display val w)
         (loop (cdr rem-lst)(append val-lst (list val)))
       )
  )
)))


(define (wind-clear wind-lst)
(cond
  ( (atom? wind-lst) (window-clear wind-lst))
  (t (for-each (lambda (w) (window-clear (cadr w))) wind-lst))
)
)



;;; displays windows for ports w/o contents

;(define-method  (atomic-models clear-ports) (port-lst)
;(for-each (lambda (w) (window-clear (cadr w))) port-lst)
;)


(define (display-each lst wind-lst)
 (let loop (
           (rem-lst lst)
           )
(cond
  ((null? rem-lst))
  (else (let* (
               (pair (car rem-lst))
               (var (car pair))
               (val (cadr pair))
               (w (cadr (assoc var wind-lst)))
              )
          (window-clear w)
          (display (if (atom? val) val (length val)) w)
        )
        (loop (cdr rem-lst))
  )
)))





;;each atomic model  must have its window specified as follows:

(define left-most-of-model-wind  20)

;;------------------------------------------------------------
;; initial-wind:
;;
;; Create a window for atomic-model body. Windows for ports and
;; state-variables are created at make-winds.
;;
;; (car position) - top of the model window position
;; (cadr position) - offset from left most model window, 1 currently
;; (car size) - veritcal width of model window
;; (cadr size) - string length of model name
;;------------------------------------------------------------

;; Inst var nw.cp - used for model body window
;;          nw.wind -  used for statw varibles

(define-method (atomic-models initial-wind)(position size inports outports)
   (let* (
           (banner (symbol->string name))
           (w (make-window banner #!true))
         )

;(window-set-attribute! w 'border-attributes 11) ;; green and blue
(window-set-position! w (car position)
                      (+ left-most-of-model-wind (cadr position)) );;fffffff
(window-set-size! w (- (car size) 2) (cadr size))
                            ;; (cadr size) returns model name length
(set-nw 'cp w)
;;(window-clear (get-nw 'cp))  ;;; hide while initializing
(set! inport (make-winds 'in position size inports))
(set! outport (make-winds 'out position size outports))
(set-nw 'wind (make-winds 'state position size (remove-pair ind-vars-wind)))
))




