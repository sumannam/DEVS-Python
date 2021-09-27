;;;;;;;;;;;;;;;;;;;;;;;;;;;;;display.s;;;;;;;;;;;;;;;

(define (dc)(dos-call "" ""))
(alias init initialize)             ;(initialize root-co proc)   
(define (mk-cop m1 m2)
        (send m1 make-copy m2))    ;(mk-cop atom-mod/di-mod 'atom-mod/di-mod)
(alias mk-e mk-ent)                 ;(mk-ent class name)
(alias mk-br make-broadcast)        ;(make-broadcast model-class)
(alias mk-pr make-pair)             ;(make-pair model-class 'name)
(define (pg m)(send m print-graph)) ;(pg coup-mod)
(alias pr print-root)               ;(print-root root-co)
(alias plr place-root)              ;(place-root root-co)
(alias pm place-model)              ;(place-model mod)
(alias pll place-leaf)              ;(place-leaf root-co)
(alias pa place-atomic)             ;(place-atomic coup-mod line col)
(alias res restart)                 ;(restart root-co)


(define (hide-window model line col) 
(let* (
     ( wind (send model get-wind)) 
     (hidden (< 22 (car (window-get-position wind))))
     )
     (wpd wind)
     (when hidden 
        (wss wind 5 30)     
        (wsp wind 10 10)    
        (wss wind 5 30)     
     )
                            ;;;order counts
     (window-popup wind)        
     (flash-message model "")
     (flush-input wind)
     (display-window wind "Hide this window? (y/n)")
     (list hidden
     (cond
       ( (equal? (read wind) 'y)
         (wpd wind)
        (wsp wind 24 79)
         (wss wind 1 1)      

        wind
       )
       (else (wpd wind)
             (wss wind 5 30)
             (wsp wind 10 10)
             '()
       )
     )           
    )
))                                                 




(define (place-atomic model line col) 
(define (ok val low high)
(let (
     (mod-val val)
     )
(set! mod-val (if (< mod-val low) low mod-val))
(set! mod-val (if (> mod-val high) high mod-val))
mod-val
))

(cond
 ( (specialized-class model 'atomic-models)
      (let* (
           (return (hide-window model line col))
           (unhidden (car return) )
           (hide-now (cadr return) )
           )
       (if hide-now   (wpd (send model get-wind))
        (begin 
          (when unhidden 
           (set! line 10)
           (set! col 10)
          )

          (let loop (
             (wind (send model get-wind))
              (line  (ok line 0 23))
              (col (ok col 0 70))
                    )
           (wpd wind)
;           (wss wind wwh wwl)
           (wsp wind line col)
           
           (window-popup wind)       
           (flash-message model "")
             (let (
                 (pair (get-line-column wind line col))
                 )
              (when (not (null? pair))
               (set! line (car pair))
               (set! col (cadr pair))            
               (window-popup-delete wind)
               (loop wind  (ok line 0 23) (ok col 0 70))
             );;when
            ) ;;let
          );;let
          (let loop (
               (wind (send model get-wind))
                    )
             (flash-message model "")
             (let (
                  (pair (get-height-width wind))
                  )
              (when (not (null? pair))
               (wpd wind)
               (wss wind  (ok (car pair) 0 23)(ok (cadr pair) 0 80))
               (wp wind)            
               (wc wind)                                               
               (loop wind)
              ) ;;when
             ) ;;let 
            (wc wind)
        );;let
   );;begin
  ) ;;if   
  ) ;;;let*
 ) ;;;(spec
 ( else   (let (
                 (li line)
                 (co col)
                 )
            (for-each (lambda(chd)
                  (place-atomic chd li co)
                  (set! li (ok (+ li 7) 0 23))
                      )
             (send model get-children))
         )
)) )    


(define (place-root root-co-ord)
(let* (
     (root-model (send (send root-co-ord get-child) get-devs-component))
     (dum (send root-co-ord get-devs-component))
     (wind (make-window (symbol->string (send root-co-ord get-name)) #!true))
     )
(set! pause #!true)
(send dum set-wind wind)
(wss wind 6 20)
(wsp wind 2 2)
(let* (
     (wind (send dum get-wind))
     (pair (cons dum wind))
     )
(window-reduce-stack pair)
(when (eq? (top? wst) pair) (window-pop))
(window-push pair)
(display-window wind " ")
)
(place-model root-model 4 11)
))

(define (print-structure model space wind)
     (newline wind)
     (display-window wind space "model: " (send model get-name) "--->"
      " processor: " (send (send model get-processor) get-name))
    (if (specialized-class model 'coupled-models)
        (for-each (lambda (chd)
                      (print-structure chd (string-append "-" space) wind)
                  )      (send model get-children) )
   )
)



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



;;----------------------------------------------------------
;;  flash-message:
;;
;;   The statements related to the coupled model new window
;;   display call is in this function.
;;
;;----------------------------------------------------------



(define (flash-message model mes)
 (define (root-of-model model)
 (if (equal? 'dum (send model get-name))
     (send (send (send model get-processor) get-child) get-devs-component)
 (root-of-model (send model get-parent))
 ))
(let* (
     (wind (send model get-wind))
     (pair (cons model wind))
     )


        ;---------------------------------------------------
          ;; coupled-models new window display call

      (when (content? (message-content mes))
        (when display-model-window
          (when (and (not (atomic-eq? model))
                     (not (null? (content-port (message-content mes))))
                     ;; need for forward-models dummy port and value

                     (send model get-nw 'display)
                       ;; check new window display flag
                 )

                 (if (member (message-source mes)
                             (send model get-children)
                     )
                    (when  (send model external-message? (message-source mes)
                                        (content-port (message-content mes))
                           ) ;; display only out going message
                           (cs-low)
                           (send model display-nw (message-content mes)
                                           (message-source mes)
                           )
                    ) ;; when
                    (begin (cs-low)
                           (send model display-nw (message-content mes)
                                           (message-source mes)
                           )
                    ) ;; begin
                 ) ;; if
          )  ;; when
        ) ;; when  display-model-window
        ;----------------------------------------------------
      ) ;; when content


   ;; display following message only when pause model
(IF (and pause display-message-window)
  (begin
   (window-reduce-stack pair)
   (when (eq? (top? wst) pair) (window-pop))
   (window-push pair)
   (if (not (message? mes) )
       (display-window wind mes)
     (begin
      (display-window wind
         (cond
         ( (ext-message? mes) "Ext-message ")
         ( (*-message? mes) "*-message ")
         ( (done-message? mes) "Done-message ")) #nl
          "received from: " (if
                             (environment? (message-source mes))
                                (send (message-source mes) get-name)
                             (message-source mes)) #nl
          "with time: " (message-time mes) #nl) ;-- display-window
      (when (content? (message-content mes))


                 ;; do not place any fuction below this
                 ;; other return value causes error


        (display-window wind
          "with port: " (content-port (message-content mes)) #nl
          "saying: "   (content-value (message-content mes) ) )


      ) ;; when

   ));---- IF

   (flush-input 'console)
   (writeln "type any key to continue")
   (key-menu&zhang  (root-of-model model))
;  (when (equal? (read-char) " ")(bkpt "STOPPED" ""))

   ) ;-- BEGIN

   (cond
     ( (not pause)
       (key-menu&zhang (root-of-model model))
     )
     ( (and (not display-message-window)
            (not display-model-window)
       )
       (writeln "type any key to continue")
       (key-menu&zhang (root-of-model model))
     )
     ( (and pause (not display-message-window))
       (if (and (send model get-nw 'display)
                (not (atomic-eq? model))
                (when (content? (message-content mes))
                      (content-port (message-content mes))
                )
           )
           (if  (or (send model external-message? (message-source mes)
                       (content-port (message-content mes))
                    ) ;; checking for outgoing message.
                    (not (member (message-source mes)
                                 (send model get-children)
                          )
                    )  ;; external input
                 ) ;; or, only when exeternal input and output
                 (key-menu&zhang (root-of-model model))
                                          ;; after model window display
           ) ;; if
       ) ;; if
     )
   ) ;; cond

) ;----- IF  pause and display-message-window
))


(define (place-leaf root-co-ord)               
(set-stack wst nil)
(let* (                                                                         
                                               
     (root-model (send (send root-co-ord get-child) get-devs-component))
     )
(set! pause nil)
(clear-screen)
(place-atomic root-model 1 11)
(let loop (
          (model root-model)
          )
    (cond 
      ((specialized-class model 'atomic-models)
             (window-popup-delete (send model get-wind)))
      (else (for-each (lambda(ch)(loop ch)) (send model get-children)))
    )
)                                                                      

    (clear-screen)
    (window-clear-stack)
))

(define (clear-screen)
(wsp 'console 0 0)
(wss 'console 24 80)
(wc 'console)
(wsp 'console 0 40)
(wss 'console 4 40)
)
 

(define (window-clear-stack)
(for-each (lambda(w)(wpop)) (get-stack wst)
))

(define initialize-window (make-window "INITIALIZATION" #!true))
(wss initialize-window 5 40)
(wsp initialize-window 21 1)
         
(define (initial-window model)       
    (if (specialized-class model 'coupled-models)
        (for-each (lambda (chd)
                      (initial-window chd)
                  )      (send model get-children) ) ;;else
   (window-clear (send model get-wind))       
   )                                                
)

(define (bel$hu no)   ;;;from menu.s
  (cond ((equal? no 0))
        (else (write (ascii->symbol 7))
              (bel$hu (- no 1))
        )))

 





;;;;;;;  MANYWIN.S  ;;;;
; modify place-model and print-root of DISPLAY.S
; for a model which has too many components.

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



(define (get-line-column wind line col)
(flush-input wind)    
(display-window wind "Touch arrow keys to POSITION window"
     #\newline "hit <end> to stop" #\newline)
(let (                             
     (l-sensitivity 2)
     (c-sensitivity 10)
     (dir (read-key))
     )
(cond
( (equal?  dir @end ) '())                                      
( (equal? dir @up_arrow) (list (- line l-sensitivity) col))

( (equal? dir @down_arrow) (list (+ l-sensitivity line) col))

( (equal? dir @right_arrow) (list line (+ c-sensitivity col)))

( (equal? dir @left_arrow) (list line (- col c-sensitivity)))

(else (bel$hu 2)(get-line-column wind line col))
)
))



(define (get-height-width wind)
(flush-input wind)
(display-window wind "Touch arrow keys to SIZE window"
     #\newline "hit <end> to stop" #\newline)
(let* (                        
     (pair (window-get-size wind))
     (height (car pair))
     (width (cdr pair))     
     (l-sensitivity 2)
     (c-sensitivity 10)
     (dir (read-key))
     )
(cond
( (equal? dir @end) '())                                      
( (equal? dir @up_arrow) (list (- height l-sensitivity) width))

( (equal? dir @down_arrow) (list (+ l-sensitivity height) width))

( (equal? dir @right_arrow) (list height (+ c-sensitivity width)))

( (equal? dir @left_arrow) (list height (- width c-sensitivity)))

(else (bel$hu 2)(get-height-width wind))
)
))


;; overwirtes initialize-window in runprun. s file


(define initialize-window (make-window "INITIALIZATION" #!true))
(wss initialize-window 5 40)
(wsp initialize-window 2 1)
