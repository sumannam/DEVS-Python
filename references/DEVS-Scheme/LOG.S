
 
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
 
 
(define-method (root-co-ordinators when-receive-done) (input-message)
(when terminate
    (set! terminate '())
    (bkpt "stopped in complete state at "
                   (add clock-base (message-time input-message)))
)
(flash-message devs-component input-message)
      (run-it timer)
             (set! %start-message
              (make-*-message
                             'source name
                             'time (message-time input-message)
              )
             )
           (let (
                 (wind (send devs-component get-wind))
                  )
           (window-clear wind)
           (window-set-cursor! wind 0 0)
           (display-window wind "clock time: "
                 (add clock-base (message-time input-message) ) #\newline
                   "relative to " #\newline "clock-base: "
                           (message-time input-message))
 
            )
            (set! log-file (open-extend-file log-file-name))
            (newline log-file)
            (display "clock time: " log-file)
            (display (add clock-base (message-time input-message)) log-file)
            (newline log-file)
            (close-output-port log-file)
 
)
 
 
 (define-method (atomic-models int-transition) ()
 
                       (set! log-file (open-extend-file log-file-name))
                       (newline log-file)
                       (window-set-cursor! wind  (car cp) (cdr cp))
                       (display "state s = " wind)
 
                       ($erase s wind)
                       (if (vector? s)(int-transfn s) ;for use w/structure
                                     (set! s (int-transfn s)))
                       (window-set-cursor! wind  (car cp) (cdr cp))
                       (display "state s = " wind)
                       (display-structure s state-vars ind-vars wind)
                       (display (get-name) log-file)
                       (display " " log-file)
                       (display "state s = " log-file)
                       (display&file-structure s state-vars ind-vars log-file)
                       (newline log-file)
                       (close-output-port log-file)
  )
 
 
  (define-method (atomic-models ext-transition) ()
 
                        (set! log-file (open-extend-file log-file-name))
                        (newline log-file)
                        (window-set-cursor! wind (car cp) (cdr cp))
                        (display "state s = " wind)
                        ($erase s wind)
                        (if (vector? s)
                           (begin
                             (close-output-port log-file) ;; for introspection
                             (ext-transfn s e x))
                                       (set! s (ext-transfn s e x)))
                        (set! log-file (open-extend-file log-file-name))
                        (window-set-cursor! wind (car cp) (cdr cp))
                        (display "state s = " wind)
                        (display-structure s state-vars ind-vars wind)
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
)
 
 
(define-method (atomic-models output?) ()
               (let* (                      
                     (out (outputfn s))
                     (out-lst (if (not (pair? out))
                                  (list out)
                                  out))
                    )                                              
                    (set! log-file (open-extend-file log-file-name))
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
                           (display " " wind)
                           (display (content-value y) wind)
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
                    out
))
 
(define (start-log . fn)
(load "/scheme/devs/log.f")
(set! log-file-name
(if (and fn (string? (car fn)))
    (car fn)
    "logf"))
)
 
(define (stop-log)
(load "/scheme/devs/atom-me.f")
(load "/scheme/devs/root-me.f")
)
 
 

