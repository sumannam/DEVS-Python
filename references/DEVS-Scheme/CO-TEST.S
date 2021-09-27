;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;co-test.s;;;;;;;;;;;;;

(define-structure message source time content)
(define-structure content port value)
(define #!t #!TRUE)
(define #!F #!FALSE)
(alias #nl #\newline)
(alias pl place-leaf)
(alias pa place-atomic)
(alias cs clear-screen)
(alias wcs window-clear-stack)


(define (attach processor model)  
     (send processor set-devs-component model)
     (send model set-processor processor)
     (send processor set-parent (send model get-parent))
)

(define (initial-tN processor) 
  (define (prepare-window model)
  (when pause (wpd (send model get-wind)))
  )
  (let (
         (model (send processor get-devs-component))

         (tN-list '())

        )

   (if (equal? (class-of-object processor) 'simulators)
    (begin
    (prepare-window model)
    (send processor set-time-of-next-event (send model time-advance?))
    )
   (begin
   (set! tN-list (map (lambda (chd) (cons chd
                            (initial-tN (send chd get-processor))))
                               (send model get-children)))
   (send processor set-tN-children tN-list)
   (send processor set-IMMINENT (compute-imminent tN-list))
   (send processor set-*-child                                  ;;initial tie-breaking
         (eval ( (send model get-selectfn)
                             (car (send processor get-IMMINENT))
               )
         )
             
   )              

   (send processor set-time-of-next-event (cdr (send processor get-IMMINENT)))
   )
  )
(send processor get-time-of-next-event)
 )
)


(define (initial-tL processor)
  (let (
         (model (send processor get-devs-component))

         (tL-list '())
        )

   (if (equal? (class-of-object processor) 'simulators)

    (send processor set-time-of-last-event (sub 0 (send model get-e)))

   (begin
   (set! tL-list (map (lambda (chd)(initial-tL (send chd get-processor)))
                                ;(send processor get-children)))
                                (send model get-children)))
   (send processor set-time-of-last-event (maximum tL-list))
   )
  )
(send processor get-time-of-last-event)
 )
)

(define (maximum tL-list)
   (let rep (
            (tlist tL-list)
            (tL 0)
            )

    (if (null? tlist) tL
        (begin
          (if (less-than tL (car tlist))
              (rep (cdr tlist) (car tlist))
              (rep (cdr tlist) tL)
          )
        )
    )
   )
)

(define pause nil)



(define  (make-pair class name)
   (let* (
        (model (make-entity class name))
        (type (if (specialized-class model 'atomic-models)
                   "S" "C"))
        (model-type (if (equal? type "S") "atomic-models" "coupled-models"))
        (proc-type (if (equal? type "S") "simulators" "co-ordinators"))
        (proc-name (string->symbol (string-append type ":"
                       (symbol->string name))))
        (proc-class (if (equal? type "S") simulators co-ordinators))
        (proc (make-entity proc-class proc-name))
        )
  (send model set-wind (make-window (symbol->string name) #!true))
  (eval `(define ,name ,model))
  (newline)
  (if (eq? (current-output-port) 'console)
      (display-window 'console "Model of type " model-type 
                           " with name " name " made."))
  (eval `(define ,proc-name ,proc))
  (newline)
  (if (eq? (current-output-port) 'console)
      (display-window 'console "Processor of type " proc-type 
                           " with name " proc-name " made."))
  (newline)
  (attach proc model)
))



(define (initialize root-co-ordinator processor)
(if (and (specialized-class root-co-ordinator 'root-co-ordinators)
         (specialized-class processor 'processors))
    (let (
           (dum (send root-co-ordinator get-devs-component))
           (model (send processor get-devs-component))
         )
         (send root-co-ordinator set-clock-base 0)
         (attach root-co-ordinator dum)
         (send model set-parent dum)
         (send root-co-ordinator set-child processor)
         (send processor set-parent (send model get-parent))
         (initial-structure model)
         (clear-screen)
         (window-clear-stack)
         (print-root root-co-ordinator)
         (place-root root-co-ordinator)
;         (eval `(define just-initialized 0) root-co-ordinator)
         (send root-co-ordinator set-just-initialized #t)
   )
   (display "check that arguments are root-co-ordinator, processor")
)
)




;;;; this restart extends the original one. It enables batch loading
;;;; of files (e.g. initialization) with optional interactivity as well.
;;;; If lst is given and any element in it is not an existing file
;;;; then the run will be interactive and
;;;; (in any event) the existing files will be loaded
;;;; otherwise (if all files exist) the run is not interactive
;;;; an exception: if lst has one element, not a file, the run is
;;;; not interactive
;;;; examples:
;;;; (res r) is interactive as before
;;;; (res r 0) is not interactive -- use it to avoid having to initialize
;;;;;      manually (run from the last state)
;;;; (res r "f.ini" "g.ini") is not interactive if these are both files
;;;;;    --use this to run in batch mode
;;;; (res r "f.ini" "g.ini" 0) is the same but interactive
;;;;;    --use this to initialize by both loading files and manual setting


(define (restart root-co-ordinator . lst)
      (let* (
           (child  (send root-co-ordinator get-child))
           (clock-base (send root-co-ordinator get-clock-base))
           (dum (send root-co-ordinator get-devs-component))
           (model (send child get-devs-component))
           (start-mes (make-done-message))
           (files (clean (map (lambda(fl)(when (file-exists? fl) fl)) lst)))
           (interact (or (null? lst)
                         (and (not (= (length lst) 1))
                              (not (equal? (length lst)(length files))))))
         )

      (cond
         ((send root-co-ordinator get-just-initialized)
             (send root-co-ordinator set-just-initialized #f)
         )
         ( (not (equal? (send child get-time-of-last-event) '#!unassigned))
                (send root-co-ordinator set-clock-base
                 (add clock-base (send child get-time-of-last-event)))
         )
      )    ;;;update the clock base: all timing is relative to zero
           ;;;and translated to current time by adding clock-base
      (for-each (lambda(fl)(load fl)) files)
      (set! pause interact)
      (window-clear-stack)
      (clear-screen)
      (send model set-parent dum)
      (send child set-parent (send model get-parent))
      (initial-structure model)

      (writeln "Initializing windows ...")

      (when (not (send root-co-ordinator get-nw-initialized))
        (if (atomic-eq? model)
            (atomic-wind model)
            (res-wind model) ;; set windows for restart
        )
        (send root-co-ordinator set-nw-initialized #t)
      )

      (display "<CTRL>Switch-mode <CTRL>Place-leaf ")(newline) ;;;;
      (display "<CTRL>Terminate   <CTRL>Help/?")     (newline)
      (if interact
       (begin
        (flush-input 'console)
        (writeln "type any key to continue")
        (key-menu&zhang   model)
        (send model ninitial-state)
        ) ;;;else
        (when display-message-window (initial-window model))             ;;;;
      )

      (clear-screen)

      (initial-tL child)
      (initial-tN child)

      ;(window-delete initialize-window)
      (when display-message-window (initial-window model))

      (set! (message-time start-mes) (send child  get-time-of-next-event));;
      (set! %start-message start-mes)
      (display "<CTRL>Switch-mode <CTRL>Place-leaf ")(newline)
      (display "<CTRL>Terminate   <CTRL>Help/?")     (newline)
      (repeat-cycle root-co-ordinator)
   )
)





;;;;;;; print-timing & print-time ;;;;;;

(define (print-timing model space wind)
(let (
     (proc (send model get-processor))
     )
     (newline wind)
     (display-window wind space (send proc get-name)
     " (*,t)= " (send proc get-*-time) 
     " (y,t)= " (send proc get-y-time)
     " (x,t)= " (send proc get-x-time) 
     )
(send proc set-x-time 0)
(send proc set-y-time 0)          
(send proc set-*-time 0)
    (if (specialized-class model 'coupled-models)
        (for-each (lambda (chd)
                      (print-timing chd (string-append "-" space) wind)
                  )      (send model get-children) )
   )
)
)

(define (print-time  root-co-ord)
(let* (
     (root-model (send (send root-co-ord get-child) get-devs-component))
     (height (+ 7 (grand-children root-model)))
     (width  (+ 60 (depth root-model)))
     (wind (make-window "EXECUTION TIMING" #!true))
     )
(wsp wind 1 1)
(wss wind height width)
(wc wind)
(newline wind)
(display-window wind "=============")
(newline wind)
(display-window wind "root-co-ordinator: " (send root-co-ord get-name))
(print-timing root-model "-" wind)
(newline wind)
(display-window wind "=============" )
))

;-----------------------------------------------------
;    Check Keys for controling DEVS simulation
;   --------------------------------------------------
;    <CTRL>S ---  SWITCHING MODE (INTERACTIVE VS. NON)
;    <CTRL>P ---  PLACE LEAF WINDOWS
;    <CTRL>T ---  TERMINATE THE SIMULATION
;    <CTRL>H ---  GET THIS EXPLANATION LIST
;          ? ---  THE SAME AS <CTRL>H
;----------------11/6/87-----Guoqing Zhang------------


(define (key-menu&zhang . root-model)
 (define (prompt_user question)
 ;-- Prompt user for answers to the given QUESTION
 ;----------------------------------------------------
   (display question 'console)
   (display " ===>" 'console)
   (read)
 ) ;--- PROMPT_USER

 (define (an_environment? name)
  (eval `(IF (UNBOUND? ,name)  #!false
      (ENVIRONMENT? ,name)) user-initial-environment)
 )

     (let* ((past-pause Pause)
            (key-pressed
               (IF Pause (read-char 'console)
                   (IF (CHAR-READY? 'console)
                       (read-char 'console) (integer->char 60)
               )))
            (model-name '-)
            (window-pos '-)
           )
           (set! key-pressed (char->integer key-pressed))
           (case key-pressed
             (8  ;------- <CTRL>H
                 (Display "<CTRL>Switch_Mode <CTRL>Place leaf " 'console)
                 (newline)
                 (display "<CTRL>Terminate <CTRL>Help/? " 'console)
                 (newline)
             )
             (16 ;------- <CTRL>P
                 ;;(cs-low)
                 (set! past-pause Pause)
                 (set! Pause #!f)
                 (set! model-name (prompt_user "Enter Name "))
                 (IF (AN_ENVIRONMENT? model-name)
                     (begin
                        (set! model-name (eval `(eval ,model-name)))
                        (set! window-pos (window-get-position
                                (send model-name get-wind)))
                        (place-atomic model-name (car window-pos)
                                (cdr window-pos))
                        (flush-input 'console)
                 )) ;-- if
                 (set! pause past-pause)
             )
             (19 ;------- <CTRL>S
                 (IF pause (begin (set! pause #!f)
                                  ;;(cs-low)
                                  (when display-message-window
                                    (initial-window (car root-model))
                                  )
                           )
                           (begin
                             (set! pause #!t)
                           )
                 )
             )
             (20 ;------- <CTRL>T
                 (if pause
                 (BKPT "STOPPED in partial state!" " ")
                 (let (
                      (r (send (send (car root-model) get-parent)get-processor) )
                      )
                 (send r set-terminate #t)
                 )
                 )
             )
             (63 ;------- ?
                 (Display "<CTRL>Switch_Mode <CTRL>Place leaf " 'console)
                 (newline)
                 (display "<CTRL>Terminate <CTRL>Help/? " 'console)
                 (newline)
             )
             (else ()
             )
           )
))


;;;;;;;;;;;;;;;;;;;;;;;necessary to avoid infinite stacking ;;;;;;
;;;;note: %start-message is changed by method when-receive-done of
;;;;;root-co-ordinator before recycling

(define %start-message '())

(define (repeat-cycle root-co-ordinator)
   (send root-co-ordinator when-receive-done %start-message)
   (let rep (
             (child (send root-co-ordinator get-child))
            )
      (when (less-than (message-time %start-message) 'inf)
      (send child when-receive-* %start-message)
      (rep child)
      )
   )
)


