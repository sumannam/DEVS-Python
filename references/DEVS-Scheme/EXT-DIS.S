;;---------------------------------------------------------------
;;  ext-dis.s : extended display file
;;
;; This file contains functions  and global variables
;; that are related to new-window display.
;;
;; Also contains procedures related to start-log
;;---------------------------------------------------------------


(define log-file-flag #f)  ;; #t when start-log is in operational

(define display-message-window #t)
(define display-model-window #t)




;;--------------------------------------------------------------
;; (change-display {option})
;;
;; {option}  a - all window display
;;           n - no display
;;           u - upper (message) window display
;;           l - lower (model) window display
;;           default - all window display
;;----------------------------------------------------------------


(macro change-display (lambda (e)
(let
  (
    (option (if (cadr e) (cadr e) '()))
    (co-ordinator  (if (caddr e) (caddr e) '()))
  )
  `(begin
      (case ',option
        ('a
           (set! display-message-window #t)
           (set! display-model-window #t)
        )
        ('n
           (set! display-message-window #f)
           (set! display-model-window #f)
        )
        ('u
           (set! display-message-window #t)
           (set! display-model-window #f)
        )
        ('l
           (set! display-message-window #f)
           (set! display-model-window #t)
        )
        (else
           (set! display-message-window #t)
           (set! display-model-window #t)
        )
      ) ;; case

   ) ;; begin
)));; let







;;--------  related functions of coupled-models new window -----
;;
;;     res-wind : (send model initial-wind)
;;     flesh-message : (cs-low) ...
;;
;;--------------------------------------------------------------



;;--------------------------------------------------------------
;; new-wind.s
;;
;; Functions related to displaying new windows are in this file.
;;
;; The I/O ports of atomic-models within coupling table of coupled-models
;; are initialized when restart is called (initialized by res-wind).
;; The I/O ports not in the coupling table are made at the ext or out funciton
;; the atomic-models.
;;---------------------------------------------------------------


(define temp-wind (make-window))

;; new-window display area

(define (cs-low)
(wsp temp-wind 16 0)
(wss temp-wind 10 80)
(wc temp-wind)
)



(define initialize-window (make-window "INITIALIZATION" #!true))
(wss initialize-window 5 40)
(wsp initialize-window 2 1)





;;--------------------------------------------------------------
;; make-winds :
;;
;; Makes a window for atomic-models.
;; The windows created for atomic-models are windows for I/O ports,
;; state variables.
;;---------------------------------------------------------------

;;--------------------------------------------------------------
;; (car position) - top of the model window position
;; (cadr position) - offset from left most window, 1 currently
;; (car size) - veritcal width of model window
;; (cadr size) - string length of model name (for hor. width)
;;--------------------------------------------------------------



(define (make-winds type position size inports)
(let (
       (h-start left-most-of-model-wind)
                                   ;; also left most wind position of vars
       (h-threshold 70)
       (sv-wind-with 10) ;; window with of state variable
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
                   (banner (symbol->string (car rem-ports)))
                   (w (make-window banner #!true))
                   (v-offset (case type
                              ('in  1)  ;;  (+ 1 (* num 1))
                              ('out  1) ;;  (+ 1 (* num 1))
                                        ;; ports always same position

                              ('state (+ (- (car size) 1) v-num))
                           ))
                   (h-offset (case type
                              ('in  1)
                              ('out (+ 1 (cadr size) h-start))
                              ('state (+ h-start
                                         (* num
                                            (+ sv-wind-with 1)
                                         )
                                       )
                               )
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
;               (window-set-attribute! w 'border-attributes 11) ;; blue & red
               (window-set-attribute! w 'window-flags 2)        ;; truncate
               (window-set-position! w (+ (car position) v-offset)
                                       (+ (cadr position) h-offset)
               )
               (if (or (equal? type 'in) (equal? type 'out))
                   (window-set-size! w  1 (- left-most-of-model-wind 2))
                   (window-set-size! w  1 sv-wind-with)
                )
             ;;  (window-clear w)   hide while initializing
               (list (car rem-ports) w)
               ) assoc-lst))
               (loop (cdr rem-ports) assoc-lst (1+ num) v-num)
      )
))))







(define (remove-pair lst)
(cond
  ((null? lst) '())
  ((pair? (car lst)) (remove-pair (cdr lst))
  )
  (t (append (list (car lst)) (remove-pair (cdr lst))))
))



;;-------------------------------------------------------------------
;;  (res-wind model):
;;
;;  Make windows for state-vars and ports for all atomic-eq models
;;  & determines window display positions.
;;  Make windows for coupled-models body.
;;  Also sets nw.display flag to default value (atomic-eq #t others #f)
;;
;;  (res-wind model) has to be performed for (ndisplay-structure...)
;;  (nget-structure) & (atomic-models method (set-state))
;;  Called only for coupled-models -- children of coupled models are
;;                                    initialized
;;
;;-------------------------------------------------------------------

(define (res-wind model)
(let (
        (coupling (send model get-coupling))
        (v-start 17)    ;; left-upper conner of window position (line #)
        (v-gap 5)       ;; distance between top of model and that of vars
     )

     (send model initial-wind) ;; initialize windows for coupled-models

  (for-each (lambda (chd)
                   (cond
                     ((atomic-eq? chd)

                      (send chd set-nw 'display #t)
                                 ;; make atomic-eq models displayed
                                 ;; as a default

                      (send chd set-ind-vars-wind
                            (send chd get-ind-vars)
                      )
                         ;; use ind-vars-wind only for new-window display
                      (let ( (lst (send chd get-ind-vars-wind)) )
                         (set! lst
                              (map (lambda (var)
                                      (if (pair? var)
                                           var
                                           (if (or (equal? var 'sigma)
                                                   (equal? var 'phase)
                                               )
                                               var
                                               (list var)
                                           )
                                      )
                                    )
                               lst)
                         )
                         (send chd set-ind-vars-wind lst)
                           ;; hide all vars as defaut display
                       )


                      (send chd initial-wind
                                 (list v-start 1)
                                  ;;  1 is off-set from left-most-model-wind

                                 (list v-gap
                                    (let
                                     ((hor-length
                                       (string-length
                                         (symbol->string (send chd get-name))
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
                                 (get-ports coupling chd 'in)
                                 (get-ports coupling chd 'out)
                      )
                     )
                     (t (res-wind chd))
                   )


            ) (send model get-children)
  )
))


;;---------------------------------------------------------------
;;  Same as res-wind, but for the atomic-models
;;---------------------------------------------------------------



(define (atomic-wind model)
(let (
        (v-start 17)    ;; left-upper conner of window position (line #)
        (v-gap 5)       ;; distance between top of model and that of vars
     )



                      (send model set-nw 'display #t)
                                 ;; make atomic-eq models displayed
                                 ;; as a default

                      (send model set-ind-vars-wind
                            (send model get-ind-vars)
                      )
                         ;; use ind-vars-wind only for new-window display
                      (let ( (lst (send model get-ind-vars-wind)) )
                         (set! lst
                              (map (lambda (var)
                                      (if (pair? var)
                                           var
                                           (if (or (equal? var 'sigma)
                                                   (equal? var 'phase)
                                               )
                                               var
                                               (list var)
                                           )
                                      )
                                    )
                               lst)
                         )
                         (send model set-ind-vars-wind lst)
                           ;; hide all vars as defaut display
                       )


                      (send model initial-wind
                                 (list v-start 1)
                                  ;;  1 is off-set from left-most-model-wind

                                 (list v-gap
                                    (let
                                     ((hor-length
                                       (string-length
                                         (symbol->string (send model get-name))
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
                                 '() ;; input port
                                 '() ;; output port
                      )

))





;;---------------------------------------------------------------
;;  get-ports:
;;
;;  Get the ports in coupling table for initializing
;;  port windows.
;;
;;  coupling for (send digraph-model get-coupling)
;;  e.g. (get-ports coupling ef 'out)
;;---------------------------------------------------------------


(define (get-ports coupling model type)
(let
  (
    (m-name (send model get-name))
    (len (case type ('in 2) ('out 3)))
  )
  (let loop (
              (port-lst '())
              (c-lst coupling)
            )
            (if (null? c-lst)
                (clean port-lst)
                (begin
                  (when
                    (= (length (member m-name (car c-lst))) len)
                    (set! port-lst
                          (append port-lst
                                  (list
                                    (let
                                     ((port
                                       (if
                                         (equal? type 'in)
                                         (cdaddr (car c-lst))
                                         (caaddr (car c-lst))
                                       )
                                     ))
                                     (if (member port port-lst)
                                         '()
                                         port
                                     )
                                    ) ;end of let
                                  )
                          )
                    )
                  )
                  (loop port-lst (cdr c-lst))
                )
            )
  )
))





(define (atomic-eq? model)
  (let ((class (class-of-object model)))
       (or (equal? class 'atomic-models)
           (equal? class 'forward-models)
           (equal? class 'table-models)
       )
  )
)


(define (hide-nw-parent model)
  (let ((p (send model get-parent)))
    (cond
      ((environment? p)
       (send p set-nw 'display #f)
       (hide-nw-parent p)
      )
   )
 )
)



;;;;;;; manywin.s (from display.s) ;;;;;;;;;

;;;;;;;  MANYWIN.S  ;;;;
; modify place-model and print-root of DISPLAY.S
; for a model which has too many components.
;
(define (place-model model line col)
(let (
        (v-threshold 9)
     )
   (let* (
           (banner (symbol->string (send model get-name)))
           (wind (send model set-wind (make-window banner #!true)))
         )
      (wss wind 5 25)
      (wsp wind line col)
      (let* (
              (wind (send model get-wind))
              (pair (cons model wind))
            )
         (window-reduce-stack pair)
         (when (equal? (top? wst) pair) (window-pop))
         (window-push pair)
         (display-window wind " ")
      )
      (when (specialized-class model 'coupled-models)
         (let (
                (l line)
                (co (+ col 10))
              )
            (for-each
               (lambda(chd)
                 (begin
                   (place-model chd l co)
                   (set! l
                     (if (> l v-threshold)
                         line
                         (+ l 1)  ;;; set! l (+ l 3) in display.s
                     )
                   )
                 )
               )
               (send model get-children)
             )
         )
      )
   )
))


(define (print-root root-co-ord)
   (let* (
           (root-model
              (send (send root-co-ord get-child) get-devs-component))
           (height (+ 7 (grand-children root-model)))
           (width  (+ 60 (depth root-model)))
           (wind (make-window "COMPOSITION TREE" #!true))
         )
       (wsp wind 1 1)
       (wss wind (if (<= height 21) height 21) width)
       (wc wind)
       (newline wind)
       (display-window wind "=============")
       (newline wind)
       (display-window wind "root-co-ordinator: " (send root-co-ord get-name))
       (print-structure root-model "-" wind)
       (newline wind)
       (display-window wind "=============" )
   )
)










;(define-method (atomic-models inject) (port value . elapsed-time)
;(set-ext-event (make-content 'port port 'value value))
;(when elapsed-time (set-e (car elapsed-time)))
;(ext-transition)
;)








;;----------------------------------------------------------
;;              Fuctions related to start-log only
;;----------------------------------------------------------



;;---------------------------------------------------------------
;; start-log, stop-log:
;; Use for creating logf files
;;
;; Usage - (start-log) or (start-log "file-name"), (stop-log)
;;---------------------------------------------------------------


(define (start-log . fn)
(if (not log-file-flag)
(begin
  (set! log-file-flag #t)
  (set! log-file-name
  (if (and fn (string? (car fn)))
      (car fn)
      "logf"))
) ;; begin
(display "Already in Start-log mode.")
) ;; if
)


(define (stop-log)
(if log-file-flag
(set! log-file-flag #f)
(display "Not in Start-log mode.")
);; if
)




;; To keep atomic-models' inputs, states and outputs in a file
;; example of use:
;; (start-log arg)
;; If arg is a string "..." will (set! log-file-name "...")
;; otherwise (or if arg is omitted) will (set! log-file-name "logf")

;; atomic model state variables specified through the display method
;; appear in "..." or "logf" file
;; always appends new data at end of given file
;; to start from empty file you can delete [(dos-delete "...") in Scheme]
;; or rename current file

;; log-file will be closed if atomic-model's transfn or outputfn is finished
;; or use (close-output-port log-file) to close it at any time

;; to remove logging capability and restore DEVS-Scheme to original display
;; mode, use
;; (stop-log)

(define log-file)
(define log-file-name)


(define (display&file-structure s state-vars ind-vars log-file)

(define (mark val)
(if (null? val) '- ($clip val 1))
)

(define (comp-lst v state-vars ind-vars)
(map (lambda(state-var)
      (begin0
         (cond;

                     ( (equal? state-var (car ind-vars))
                              (begin0 (mark (car v));

                                      (set! ind-vars (cdr ind-vars))
                               )
                      )
                      ((and (pair? (car ind-vars))
                                   (equal? state-var (caar ind-vars)));

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
         (display (clean lst) log-file)
    )
    (display s log-file)
)
)

