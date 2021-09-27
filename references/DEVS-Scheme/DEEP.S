;         Deepening DEVS structure
;         Guoqing Zhang / 11/10/1987
;    Command :  (DEEP-DEVS coupled_model list_of_models 
;                          new_model_name new-class)
;            OR (DEEP_DEVS ...)
;  EXAMPLE : (DEEP-DEVS DC-EF  '(p1 p2) 'new 'digraph-models)
;----------------------------------------
(define (deep-devs coup-z group new cls)(deep_devs coup-z group new cls))
(define (deep_devs COUP-z Gnames NEW CLS)     
 (let  ((class-name (class-of-object coup-z)))
   (IF (EQUAL? '() (member 'children 
            (eval `(instvars ,class-name) user-initial-environment)))

        (DISPLAY "only coupled model is acceptable !")
        (deep_DEVS&zhang coup-z Gnames NEW CLS)
)))
(define (deep_devs&zhang coup-z Gnames NEW CLS)
  (let* ( (couplings (send COUP-z get-coupling))
          (GROUP     (clean (map (lambda(e) (eval `(eval ,e))) Gnames)))
          (Oprio     '()) ; old priority list for COUP-Z
          (Nprio     '()) ; new priority list for NEW
          (Cname     (send COUP-z get-name))
          (Ncnt-in   1)
          (Ncnt-out  1)

          (int-coup  (int-coup&zhang Cname couplings))
          (ext-inp   (ext-inp-coup&zhang Cname couplings))
          (out-ext   (out-ext-coup&zhang Cname couplings))
          (child-lst (send COUP-z get-children))

          (Pint-coup '())
          (Pext-inp  '())
          (Pout-ext  '())
          (Pinf-dig  '())
          (Pchild-lst (clean (map (lambda(e) (IF (IN_LST? e group) '() e))
                                  child-lst)))

          (Nint-coup '())
          (Next-inp  '())
          (Nout-ext  '())
          (Ninf-dig  '())

          (port      '-)
          (out       '-)
          (in        '-)
        )
   ;----------------------------------------
   ;   Deal With INT-COUP
   ;----------------------------------------
   (FOR-EACH (lambda(e)
        (set! out (caaddr e))
        (set! in  (cdaddr e))                
        (IF (AND (IN_LST? (car e) Gnames) (NOT_IN_LST? (cadr e) Gnames))
            (BEGIN
                (set! port (port&zhang 'out Ncnt-out))
                (set! Ncnt-out (+ 1 Ncnt-out))
                (set! Nout-ext (cons (list (car e) NEW (cons out port))
                                     Nout-ext))
                (set! Pint-coup (cons (list NEW (cadr e) (cons port in))
                                     Pint-coup))
            ) ;---- BEGIN -- ELSE
        (IF (AND (NOT_IN_LST? (car e) Gnames) (IN_LST? (cadr e) Gnames))
            (BEGIN       
                (set! port (port&zhang 'in Ncnt-in))
                (set! Ncnt-in (+ 1 Ncnt-in))
                (set! Pint-coup (cons (list (car e) NEW (cons out port))
                                     Pint-coup))
                (set! Next-inp  (cons (list NEW (cadr e) (cons port in))
                                     Next-inp))
            );----- BEGIN-ELSE                 
        (IF (AND (IN_LST? (car e) Gnames) (IN_LST? (cadr e) Gnames))
            (set! Nint-coup (cons e Nint-coup))
            (set! Pint-coup (cons e Pint-coup))
        )))
   )int-coup)

   (FOR-EACH (lambda(e)
        (set! out (caaddr e))
        (set! in  (cdaddr e))
        
        (IF (NOT_IN_LST? (cadr e) Gnames)
            (set! Pext-inp (cons e Pext-inp))
            (BEGIN
                (set! port (port&zhang 'in Ncnt-in))
                (set! Ncnt-in (+ 1 Ncnt-in))
                (set! Pext-inp (cons (list (car e) NEW (cons out port))
                                     Pext-inp))
                (set! Next-inp (cons (list NEW (cadr e) (cons port in))
                                     Next-inp))
        ))
   )ext-inp)

   (FOR-EACH (lambda(e)
        (set! out (caaddr e))
        (set! in  (cdaddr e))
        
        (IF (NOT_IN_LST? (car e) Gnames)
            (set! Pout-ext (cons e Pout-ext))
            (BEGIN
                (set! port (port&zhang 'out Ncnt-out))
                (set! Ncnt-out (+ 1 Ncnt-out))
                (set! Pout-ext (cons (list NEW (cadr e) (cons port in))
                                     Pout-ext))
                (set! Nout-ext (cons (list (car e) NEW (cons out port))
                                     Nout-ext))
        ))
   )out-ext)                                   
                                    
   ;----------initialize components
    (send COUP-z set-composition-tree (bi-tree))
    (send COUP-z set-children '())
    (send COUP-z set-influence-digraph (digraph))           
    
    (set! NEW (ask-for-reuse CLS NEW))
    (send NEW set-composition-tree (bi-tree))
    (send NEW set-children '())
    (send NEW set-influence-digraph (digraph))

    (set! Pchild-lst (cons NEW Pchild-lst))                         
    (set! Pinf-dig (new-inf-dig&zhang Pchild-lst Pint-coup))

;;---------------- updating priority lists for COUP-Z & NEW ---;;
(set! Oprio (send coup-z get-priority-list))
(set! Nprio (clean (map (lambda(m) (if (member m Group) m '())) 
                             Oprio)))
(set! Oprio (clean (remove-mult (map (lambda(m) (if (member m Group) NEW m))
                             Oprio))))

;;================ For NEW Coupled Model ======================;;
    (send NEW set-priority (ask-prio-list&zhang NEW Nprio)) 
    (set! Ninf-dig (new-inf-dig&zhang GROUP Nint-coup)) 
    (send NEW build-composition-tree NEW GROUP)
    (send NEW set-inf-dig (remove-mult Ninf-dig))
    
    (for-each (lambda(child)
      (IF (> (LENGTH child) 1) ;--- have coupling to specify
          (connect-it&zhang (remove-mult child) Nint-coup NEW)
      )
    )Ninf-dig)            

    (for-each (lambda(child)
          (connect-out-ext&zhang child NEW Nout-ext)
    )GROUP)       

    (for-each (lambda(child)
          (connect-ext-inp&zhang child NEW Next-inp)
    )GROUP)                                
;;============== For OLD Coupled Model =====================;;
    (send COUP-z set-priority (ask-prio-list&zhang COUP-z Oprio))
    (send COUP-z build-composition-tree COUP-z Pchild-lst) 
    (send COUP-z set-inf-dig Pinf-dig)

   (for-each (lambda(child)
      (IF (> (LENGTH child) 1) ;--- have coupling to specify
          (connect-it&zhang (remove-mult child) Pint-coup COUP-z)
      )
   )Pinf-dig)            

    (for-each (lambda(child)
          (connect-out-ext&zhang child COUP-z Pout-ext)
    )Pchild-lst)                             

    (for-each (lambda(child)
          (connect-ext-inp&zhang child COUP-z Pext-inp)
    )Pchild-lst)
    
)) ;---DEEP_DEVS

(define (port&zhang port cnt)
   (symbol-append port (string->symbol (integer->string cnt 10)))
) ;--- port&zhang

;-------------------------------------------------------------;
;   ask user for priority list of the coupled model COUP-z    ;
;   IF user answers 'N' the default value PRIO is returned.   ;
;     Otherwise, user needs to enter in this form : (p1 p2 )  ;
;
; EXAMPLE : (ask-prio-list&zhang dc-ef (list p1 p2))
;           
;-------------------------------------------------------------;
;    Feb. 18, 1988  G.Zhang |
;----------------------------

(define (ask-prio-list&zhang COUP-z prio)                        
 (let ((answer '()))
  (newline)
  (display "The default priority list for ")
  (display (send coup-z get-name))
  (display " is --> ")
  (display (map (lambda(m) (send m get-name)) (clean prio)))(newline)
  (display "Enter 'N' to use the default, or give the list ==> ")
  (set! answer (read))
  (IF (pair? answer) 
      (map (lambda(m) (eval `(eval ,m user-initial-environment))) answer)
      prio)
))                                                                 

;------------------------------------------
; (ASK-FOR-REUSE class_name new_model_name)      
;   BY G.Zhang  Feb 20, 1988
;
; EXAMPLE : (ask-for-reuse 'digraph-models 'new)
;------------------------------------------------
(define (ask-for-reuse CLS NEW)
  (LET* ((clist (eval `(getcv ,cls lst) user-initial-environment))
        (Inlist (member NEW (map (lambda(m) (send m get-name)) clist)))
       )
       (IF Inlist (BEGIN  (newline)
                     (DISPLAY "The new coupled model : ")
                     (DISPLAY NEW) (DISPLAY " exists. ")
                     (DISPLAY "Do you want to reuse it (Y/N)? ==>")
                     (IF (NOT (EQUAL? 'Y (READ)))
            (eval `(make-pair ,cls ',NEW) user-initial-environment)
                   )) ;--- IF & BEGIN
            (eval `(make-pair ,cls ',NEW) user-initial-environment)
      ) ;---- IF
      (eval `(eval ,NEW ) user-initial-environment)
))


