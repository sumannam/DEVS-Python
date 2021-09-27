;-----------------------------------------------------------;
;     Program for DEVS-SCHEME -- JAN 5th, 1987              ;
;             Author:  Guoqing ZHANG                        ;
;             ECE Dept/Univ. of Arizona                     ;
;             Tucson, AZ 85721                              ;
;-----------------------------------------------------------;
;     Program Name :   ANALYZE.S/ANALYZE.F                  ;
;     Purpose      :   To analyze the simulation results    ;
;                  :    and get the optimal processor       ;
;                  :    structure in the case of the com-   ;
;                  :    bination of both sequential  and    ;
;                  :    parallel execution of the given     ;
;                  :    abstract simulator structures.      ;
;-----------------------------------------------------------;
;     Definition for NODE representation                    ;
;    ID -- the identifier of the node                       ;
;    ST -- sequential time required for a processor to do   ;
;    CT -- time for coordination and table look up          ;
;  SONS -- the sons                                         ;
;-----------------------------------------------------------;
;     A global variable : RO-NAME is reserved for this      ;
;     program.   The node name is created by adding  a      ;
;     prefix 'NODE-' to the name of the component given     ;
;     in abstract simulator structure.                      ;
;-----------------------------------------------------------;
;           The following functions are useful              ;
;           ----------------------------------              ;
;   1. (analyze  sim-root)                                  ;
;   2. (retrial )                                           ;
;   3. (reconstruct-son name)                               ;
;   4. (reconstruct-all-sons son)                           ;
;   5. (calculate-cts name)                                 ;
;   6. (sum-over son)                                       ;
;   7. (adjust-sons name)                                   ;
;   8. (adjust-all-sons son)                                ;
;   9. (init-node model mark)                               ;
;  10. (recover n)                                          ;
;  11. (recover-sons son)                                   ;
;  12. (sim com)                                            ;
;  13. (report n wind)                                      ;
;  14. (report-son son wind)                                ;
;  15. (display-son n wind)                                 ;
;  16. (out-sons son)                                       ;
;  17. (display-all-sons son wind)                          ;
;  18. (output-string sym)  OR in fact it is (o-s sym)      ;
;  19. (enclose  nod val)                                   ;
;  20. (maximum-time son val com)                           ;
;  21. (close-it nod val)                                   ;
;  22. (greatest str)                                       ;
;  23. (sort str)                                           ;
;  24. (change-order n)                                     ;
;  25. (order n)                                            ;
;  26. (order-son n)                                        ;
;                                                           ;
;-----------------------------------------------------------;
(define-structure node id st ct sons yt)



;----------------------------------------------------------------;
;       Function for ANALYZE (sim-root )                         ;
;          sim-root is the root-coordinator of the abstract      ;
;          simulator structure                                   ;
;----------------------------------------------------------------;
(define (analyze  sim-root)
  (let* (
     (temp-name 'ro-name)
     (r-model (send (send sim-root get-child) get-devs-component))
     ( root-name  (ini-node r-model 'root))
                    ; create the item structure for use
        )
     (adjust-sons (eval root-name))

     (calculate-cts (eval root-name))

     (reconstruct-son (eval root-name))

     (order (eval root-name))

     (eval `(define ,temp-name) )
     (set! ro-name root-name)
     (back 'console)
     (retrial) 
))
;----------------------------------------------------------------;
;           Function for Retrial()                               ;
;----------------------------------------------------------------;
(define (retrial )
     (back 'console)
     (wp initialize-window)
     (display-window initialize-window "enter communication time :")
     (sim (read initialize-window))
     (wp initialize-window)
     (display-window initialize-window "another trial? (y/n) :")
     (when (equal? (read initialize-window) 'y)                 
       (retrial)
     )
)
  
;----------------------------------------------------------------;
;           Function for Reconstruct-son(name)                   ;
;        name -- NODE name                                       ;
;----------------------------------------------------------------;
(define (reconstruct-son name)
  (let* ( (son (node-sons name))
          (new-son (reconstruct-all-sons son)))
   (set! (node-sons name) new-son)
   (for-each (lambda (chd)
                (reconstruct-son (eval chd)))
             son)
   )
)

;----------------------------------------------------------------;
;           Function for Reconstruct-all-sons(son)               ;
;        son -- list of (ID ST)s                                 ;
;----------------------------------------------------------------;
(define (reconstruct-all-sons son)
 (case son
   ('() '())
   (else (let* (
                 (first (car son))
                 (rest  (cdr son))
                 (fir   (eval first))
                 (first-st (node-st fir))
                 (first (list first first-st))
                 (rest  (reconstruct-all-sons rest))
                 (resul (cons first rest))
                )
            resul))
))

;----------------------------------------------------------------;
;           Function for Calculate-cts (name)                    ;
;    name -- NODE name                                           ;
;----------------------------------------------------------------;
(define (calculate-cts name)
  (let* ( (son (node-sons name))
          (current-st (node-st name)))
  (set! (node-ct name) (+ (node-yt name) (- current-st (sum-over son))))
  (if (not (equal? '() son))
  (for-each (lambda (sub-com)
                (let ((sub-comp (eval sub-com)))
                     (calculate-cts sub-comp)))
            son)
  (set! (node-ct name) 0))
))

;----------------------------------------------------------------;
;           Function for Sum-over(son)                           ;
;    son -- list of (ID ST)s                                     ;
;----------------------------------------------------------------;
(define  (sum-over son)
   (case son
     ('() 0)
     (else (let* ((first (car son))
                  (rest  (cdr son))
                  (first (eval first))
                  (first-st (node-st first))
                  (rest-st  (sum-over rest)))
            (+ first-st rest-st)))
))

;----------------------------------------------------------------;
;           Function for Adjust-sons (name)                      ;
;   name --- NODE name                                           ;
;----------------------------------------------------------------;
(define (adjust-sons name)
    (let ( (son (node-sons name)))
    (case son
     ('() '())
     (else (set! (node-sons name)
                 (adjust-all-sons son))
           (for-each (lambda(chd)
                         (let* ((child (send chd get-name))
                                (child (symbol->string child))
                                (child (string-append "node-" child))
                                (child (string->symbol child))
                                (child (eval child)))
                         (adjust-sons child)))
                 son)
     ))
))

;----------------------------------------------------------------;
;          Function for Adjust-all-sons (son)                    ;
;     son -- list of (ID ST)s                                    ;
;----------------------------------------------------------------;
(define (adjust-all-sons son)
     (case son
       ('() '())
       (else (cons (string->symbol
                     (string-append "node-"
                       (symbol->string (send (car son) get-name))))
                   (adjust-all-sons (cdr son))
             )
       )
))
;----------------------------------------------------------------;
;           Function for INI-NODE(model mark)                    ;
;     model -- the actual component defined in abstract simuator ;
;                         structure                              ;
;     mark  -- ROOT means the first entry to this program        ;
;              INTERIOR means the second or later entry          ;
;----------------------------------------------------------------;
(define (ini-node model mark)

   (let* (
     (proc (send model get-processor))
     (st   (send proc  get-x-time   ))
     (st1  (send proc  get-y-time   ))
     (id   (string->symbol
              (string-append "node-"
              (symbol->string (send model get-name)))))
     (cont (make-node 'id id 'st st 'ct 0 'yt st1 'sons '()))
         )

   (if (equal? mark 'root)
       (begin (set! (node-st cont) st1)
              (set! (node-yt cont) 0)
   ))

   (if (specialized-class model 'coupled-models)
       (set! (node-sons cont) (send model get-children)))

   (eval `(define ,id ,cont))

   (if (specialized-class model 'coupled-models)
       (for-each (lambda (chd)
                    (ini-node chd 'interior)
                 )
                   (send model get-children))
   )
   id     ; return the name of the newly created item
))





;----------------------------------------------------------------;
;       Function for Recover(n)                                  ;
;    n      ---   NODE name, may be ()                           ;
;----------------------------------------------------------------;
(define (recover n)
   (case n
    ('() nil)
    (else (if (< (node-st n) 0)
              (set! (node-st n) (- (+ 1 (node-st n)))))
          (recover-sons (node-sons n)))
))

;----------------------------------------------------------------;
;       Function for Recover-Sons(son)                           ;
;  son --  list of (ID ST)s                                      ;
;----------------------------------------------------------------;
(define (recover-sons son)
    (case son
      ('() nil)
      (else (let* (
                   (first (eval (caar son)))
                   (rest  (cdr son)))
             (recover first)
             (recover-sons rest)))
))

;----------------------------------------------------------------;
;       Function for Sim(com)                                    ;
;   com -- communication time for the simulator structure        ;
;----------------------------------------------------------------;
(define (sim com)
   (let* ( (n (eval ro-name))
           (wind (make-window "ANALYZE" #!true))
           (height 18)
           (width  70) 
         )
   (wsp wind 1 1)
   (wss wind height width)
   (wc wind)         
   (newline wind)
   (display-window wind "====================")
   (newline wind)
   (display-window wind "the optimal amount of time is :  " 
                        (enclose n (* 2 com)))
   (newline wind)
   (report n wind)      
   (newline wind)
   (display-window wind "=====================")
   (newline wind)
   (recover n)
))
;----------------------------------------------------------------;
;     Function for Report(n wind)                                ;
;   wind -- window name                                          ;
;----------------------------------------------------------------;
(define (report n wind)
   (case (node-sons n)
    ('() (display-window wind  "enclose - atomic model :  ")
         (display-window wind (o-s (node-id n)))
         (newline wind))
    (else (if (>= (node-st n) 0)
            (display-window wind "assign a processor for CO-ORDINATOR : ")
            (display-window wind "enclose a CO-ORDINATOR :  "))

              (display-window wind (o-s (node-id n))) 
              (newline wind)

          (if (< (node-st n) 0)
              (display-window wind "the sub-components of "
                                   (o-s (node-id n)) " are : "))

          (if (>= (node-st n) 0)
              (report-son (node-sons n) wind)
               (if (not (null? (node-sons n)))
                   (display-son n wind))))
))

;----------------------------------------------------------------;
;      Function for report-son(son wind)                         ;
;   son -- list of (ID ST)s      wind -- window name             ;
;----------------------------------------------------------------;
(define (report-son son wind)
   (case son
     ('() nil)
     (else (report (eval (caar son)) wind) 
           (if (not (null? (cdr son)))
               (report-son (cdr son) wind)))
))

;----------------------------------------------------------------;
;   Function for Display-son(n wind )                            ;
;   n --  NODE name      wind -- window name                     ;
;----------------------------------------------------------------;
(define (display-son n wind)
   (display-window wind  (out-sons (node-sons n)))
   (newline wind)
   (display-all-sons (node-sons n) wind))

;----------------------------------------------------------------;
;       Function for Out-sons (son)                              ;
;    son  -- list of (ID ST)s                                    ;
; -------------------------------------------------------------  ;
(define (out-sons son)
  (case son
   ('() '())
   (else (let* (( first (caar son))
               (  rest  (cdr son))
               (  first (o-s first))
                 )
          (cons first (out-sons rest)))
)))

;----------------------------------------------------------------;
;       Function for Display-all-sons(son wind)                  ;
;    son -- list of (ID ST)s    wind -- window name              ;
;----------------------------------------------------------------;
(define (display-all-sons son wind)
    (case son
      ('() nil)
      (else (let* (
                 (firstson (eval (caar son)))
                 (rest-son (cdr son)))
            (if (not (null? (node-sons firstson)))  
                (IF (< (node-st firstson) 0)
                 (begin 
                  (display-window wind "the sub-components of "
                             (o-s (node-id firstson)) " are : ")
                  (display-son firstson wind))
                ;--- ELSE
                (for-each (lambda (model) 
                     (set! model (car model))
                     (set! model (eval `(eval ,model)))
                     (report model wind)
                )(node-sons firstson)))
            )
            (if (not (null? rest-son))
                (display-all-sons rest-son wind))
     ))  
))


;----------------------------------------------------------------;
;               Function for Output-string(sym)                  ;
;      sym  --  the symbol name                                  ;
;----------------------------------------------------------------;
(define (o-s sym)
   (let* ( (str (symbol->string sym))
           (len (string-length str))
           (sub (substring str 5 len))
           (sub (string->symbol sub))
         )
    sub
))

;----------------------------------------------------------------;
;       Function definition for Enclose(n com)                   ;
;    n -- NODE name      com -- communication time               ;
;----------------------------------------------------------------;
(define (enclose n com)
  (let* ( (XTIME (node-st n))
          (STIME (+ XTIME (node-yt n)))
        )
   (case (node-sons n)
     ('() (node-st n))   ;-- basic model is reached
     (else
       (let* ( (m 0)
               (R (maximum-time (node-sons n) (list 0 0) com))
                                 ; COM is the communication time
                                 ; for each son of node, N, search
                                 ; for the one with maximum time
                                 ; to simulate it.
                                 ; R will hold a list (MAX SUM)
               (m (min (+ (car R) (node-ct n)) 
                       (+ (node-ct n) (cadr R))))) 
                                 ; get the minimum between sequential case 
                                 ; and Optimal case among the sons
               (if (= m (+ (node-ct n) (cadr R)))
                 (close-it n m)
               )
               (floor (/ (* XTIME m) STIME))
)))))

;----------------------------------------------------------------;
;       Function definition for Maximum-time(son val com)        ;
;    SON - the current list of sons to be processe               ;
;    VAL - the current optimal value of processing time          ;
;    COM - the communication time                                ;
;----------------------------------------------------------------;
(define (maximum-time son val com)
   (case  son
     ('() val)
     (else (let* ( (first-son (caar  son))
                   (first-val (cadar son))
                   (rest--son (cdr   son))
                   (first-son (eval first-son))
                   (sons--val (+ (enclose first-son com) com))
                  )
            (set! val (list (MAX (car val) sons--val)
                            (+ (cadr val)  (- sons--val com))))
            (maximum-time rest--son val com))))
)


;----------------------------------------------------------------;
;       Function for Close-it(nod val)                           ;
;   nod  --  NODE name     val  -- current optimal time          ;
;----------------------------------------------------------------;
(define (close-it nod val)
        (set! (node-st nod) (- (- (node-st nod)) 1))
        val
)

;----------------------------------------------------------------;
;       Function definition for Greatest(str)                    ;
;     str  --  list of (ID ST)s                                  ;
;----------------------------------------------------------------;
(define (greatest str)
   (case (length str)
    (0  '())
    (1   str)
    (else
          (let ((temp (cons (car str) (greatest (cdr str))))
               )
          (if (>= (cadar temp) (cadadr temp))
              temp
              (cons (cadr temp) (cons (car temp) (cddr temp)))))
   ))
)

;----------------------------------------------------------------;
;       Function definition for Sort(str)                        ;
;    str -- list of (ID ST)s                                     ;
;----------------------------------------------------------------;
(define (sort str)
   (case (length str)



     (1 str)
     (else (set! str (greatest str))
           (cons (car str) (sort (cdr str))))
))

;----------------------------------------------------------------;
;        Function definition for Change-Order (n)                ;
;     n --- NODE name                                            ;
;----------------------------------------------------------------;
(define (change-order n)
   (case (node-sons n)
     ('()   n)    ;  n has no sons
     (else (set! (node-sons n) (sort (node-sons n))))
))

;----------------------------------------------------------------;
;       Function definition for Order(n)                         ;
;    n -NODE name                                                ;
;----------------------------------------------------------------;
(define (order n)
   (change-order n)
   (order-son (node-sons n))
)

;----------------------------------------------------------------;
;         Function definition for Ordre-Son(n)                   ;
;  n -list of (ID ST)s                                           ;
;----------------------------------------------------------------;
(define (order-son n)
   (case n
     ('() '())
     (else (order (eval (caar n)))
           (order-son (cdr n)))
))

;--------------------------------------------------------------;
;     Extra functions for use                                  ;
;--------------------------------------------------------------;
(define (bc) (back 'console))
(define (stry) (load "\\user\\zhang\\try.s"))
(define (ftry) (load "\\user\\zhang\\try.f"))
(define (ttry) (load "\\user\\zhang\\try.t"))

;--------------------------------------------------------------;
;     End of the program for simulation result analysis        ;
;--------------------------------------------------------------;






