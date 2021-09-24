;--------------------------------
;  1. (flat-devs coup-z) (flat_devs coup-z) 
;  2. (environment->name&zhang envs)
;  3. (int-coup&zhang this coups)      
;  4. (ext-inp-coup&zhang this coups)  
;  5. (out-ext-coup&zhang this coups)           
;  6. (common-coup&zhang this coups fun1 fun2)
;  7. (IN_LST? name lst)      
;  8. (NOT_IN_LST? name lst)                          
;  9. (this->coor->sons coor-name out-ext fint-coup)  
; 10. (sons->coor->this coor-name fint-coup ext-inp)    
; 11. (sons->father coor-name fname out-ext fout-ext)  
; 12. (father->sons coor-name fname ext-inp fext-inp)
; 13. (flat-devs&zhang coup-z)                    
; 14. (new-inf-dig&zhang nchild-lst nint-coup)          
; 15. (connect-it&zhang child int-coup father)           
; 16. (connect-out-ext&zhang child father out-ext-coup)  
; 17. (connect-ext-inp&zhang child father ext-inp-coup)
; 18. (flat-all coup-z) (flat_all coup-z)
;--------------------------------
;   flattening all structure in to one level
;
; EXAMPLE : (flat-all dc-ef)
;
;---------11/23/87---Guoqing Zhang----------------------
(define (flat-all coup-z) (flat_all coup-z))
(define (flat_all coup-z)(flat_all&zhang coup-z 0))
(define (flat_all&zhang coup-z depth)
 (let  ((class-name (class-of-object coup-z)) (chi '()))
    (IF (equal? 'root-co-ordinators class-name)
        (flat_all&zhang (send (send coup-z get-child) 
                              get-devs-component) depth) 
 ;-- ELSE 
        (IF (EQUAL? '() (member 'children 
                  (eval `(instvars ,class-name) user-initial-environment)))
            '()
    ;--- ELSE
           (BEGIN 
            (set! chi (send coup-z get-children))
            (FOR-EACH (lambda(mod)    
                (flat_all&zhang mod (+ 1 depth))
            )chi)
            (IF (> depth 0) (flat_devs coup-z))
           ) ;--- BEGIN
        ) ;----- IF
    ) ;--- IF
)) ;----- flat_all&zhang
;-------------------------------------------
;   flattening the DEVS structure
;
;EXAMPLE : (flat-devs dc-ef)
;
;-------11/7/87--Guoqing Zhang---
(define (flat-devs coup-z) (flat_devs coup-z))
(define (flat_devs coup-z)                                
 (let ((class-name (class-of-object coup-z)))
  (IF (equal? 'root-co-ordinators class-name)
      (display "ROOT-CO-ORDINATOR cannot be flattened !")
   (IF (equal? '() (member 'children 
                   (eval `(instvars ,class-name) user-initial-environment)))
       (DISPLAY "NOT a kind of COUPLED-MODELS !")
    (IF (number? (send coup-z get-parent))
        (DISPLAY "It is a root-model, please use FLAT-ALL, if you want.")
      (IF (equal? 'dum (send (send coup-z get-parent) get-name))
          (DISPLAY "It is a root-model, please use FLAT-ALL, if you want.")
          (flat-devs&zhang coup-z)
))))))

;--------------------------------
;   convert environments to NAMEs
;----------11/7/87--Guoqing Zhang
;--------------------------------
(define (environment->name&zhang envs)
  (let ((names '()))
       (for-each (lambda(env)
            (set! names (append names (list (send env get-name))))
       )envs)                                                     
   names
)) ;--- ENVIRONEMNT->NAME&ZHANG

;---------------------------------
;   Get INTERNAL couplings
;-------11/7/87--Guoqing Zhang ---
(define (int-coup&zhang this coups)
  (common-coup&zhang this coups NOT_IN_LST? car)
)
;--------------------------------
;  Get EXT-INP coupling
;-------11/7/87--Guoqing Zhang---
(define (ext-inp-coup&zhang this coups)
  (common-coup&zhang this coups equal? caar)
)                                          
;--------------------------------
;  Get OUT-EXT coupling
;-------11/7/87--Guoqing Zhang---
(define (out-ext-coup&zhang this coups)
  (common-coup&zhang this coups equal? cadar)
)
                                           
;---------------------------------------
;  common function for getting couplings
;-----------11/7/87-- Guoqing Zhang-----
(define (common-coup&zhang this coups fun1 fun2)
  (IF (equal? coups '())
      '()
      (IF (NOT (fun1 this (fun2 coups)))
          (common-coup&zhang this (cdr coups) fun1 fun2)
          (append (list (car coups)) 
                  (common-coup&zhang this (cdr coups) fun1 fun2)
          )
)))

;--------------------------------
;  check if name is in LST
;-----FROM LIB.S-of-CESS---------
(define (IN_LST? name lst)
  (NOT (EQUAL? #!FALSE (member name lst))) 
)

(define (NOT_IN_LST? name lst)
  (NOT (IN_LST? name lst)) 
)

(define (this->coor->sons coor-name out-ext fint-coup)
  (let ((result '()))
    (for-each (lambda(triple)
      (for-each (lambda(ftriple)
         (IF (AND (EQUAL? coor-name (car ftriple))
                  (EQUAL? (cdaddr triple) (caaddr ftriple)))
             (set! result (cons (list (car triple) (cadr ftriple)
                                 (cons (caaddr triple) (cdaddr ftriple)))
                                result))
         )
      )fint-coup)
    )out-ext)
  (remove-mult result)
)) ;--THIS->COOR->SONS

(define (sons->coor->this coor-name fint-coup ext-inp)
  (let ((result '()))
    (for-each (lambda(triple)
      (for-each (lambda(ftriple)
         (IF (AND (EQUAL? coor-name (cadr ftriple))
                  (EQUAL? (caaddr triple) (cdaddr ftriple)))
             (set! result (cons (list (car ftriple) (cadr triple)
                                 (cons (caaddr ftriple) (cdaddr triple)))
                                result))
         )
      )fint-coup)
    )ext-inp)
  (remove-mult result)    
))

(define  (sons->father coor-name fname out-ext fout-ext)
  (let ((result '()))
    (for-each (lambda(ftriple)
      (IF (NOT (EQUAL? coor-name (car ftriple)))
          (set! result (append result (list ftriple)))
          (for-each (lambda (triple)
             (IF (EQUAL? (caaddr ftriple) (cdaddr triple))
                 (set! result (cons (list (car triple) fname 
                       (cons (caaddr triple) (cdaddr ftriple))) result))
             )
          )out-ext)
      )
    )fout-ext)
    (remove-mult result)
))


;------continued on FLAT-DEVS----
;-------11/7/87--Guoqing Zhang---
;-------2/18/88--updated by B.P Zeigler & G. Zhang ----
(define (flat-devs&zhang coup-z)
  (let* ( (father     (send coup-z   get-parent))  
          (coor-name  (send coup-z   get-name))
          (child-lst  (send coup-z   get-children))
          (coups      (send coup-z   get-coupling))        
          (int-coup   (int-coup&zhang coor-name coups))
          (ext-inp    (ext-inp-coup&zhang coor-name coups))
          (out-ext    (out-ext-coup&zhang coor-name coups))
          
          (fchild-lst (send father get-children)) 
          (fname      (send father get-name))
          (fcoups     (send father get-coupling))
          (fint-coup  (int-coup&zhang fname fcoups))
          (fext-inp   (ext-inp-coup&zhang fname fcoups))
          (fout-ext   (out-ext-coup&zhang fname fcoups))

          (nchild-lst (append child-lst (remove coup-z fchild-lst)))
          (nint-coup  '())
          (next-inp-coup '())
          (nout-ext-coup '())
          (ninf-dig      '())
        ) ;-------------------LET
   ;----------set up new internal coupling to NINT-COUP---
    (set! nint-coup (clean (map (lambda(triple)
                           (IF (OR (EQUAL? (car triple) coor-name)
                                   (EQUAL? (cadr triple) coor-name))
                               '()
                               triple
                           )
                    ) fint-coup))
    )
          ;-- the old internal couplings go to new int-couplings
          ;-- if COUP-z is not involved
    (set! nint-coup (append nint-coup int-coup)) 
          ;-- all int-couplings in COUP-z go to NINT-COUP
    (set! nint-coup (append nint-coup 
                     (this->coor->sons coor-name out-ext fint-coup)
                     (sons->coor->this coor-name fint-coup ext-inp)))
          ;-- all indirect connections through COUP-z are collected
   ;----------set up new influence digraph list ----------
    (set! ninf-dig (new-inf-dig&zhang nchild-lst nint-coup))
   ;----------set up new internal --> outside ------------       
    (set! nout-ext-coup (sons->father coor-name fname 
                                      out-ext fout-ext))    
   ;----------set up new outside ---> internal -----------
    (set! next-inp-coup (father->sons coor-name fname 
                                      ext-inp fext-inp))  
   ;----------rebuild FATHER (removing COUP-z) -------------
    (send father set-composition-tree (bi-tree))
    (send father set-children '())
    (send father set-influence-digraph (digraph))

    (send father build-composition-tree father nchild-lst)
    (send father set-inf-dig  ninf-dig)
    (send father set-priority 
            (ask-prio-list&zhang father 
                (flat-list&zhang (eval `(replace ,coup-z 
                (send ,coup-z get-priority-list)
                (send ,father get-priority-list))user-initial-environment))))
    (for-each (lambda(child)
      (IF (> (LENGTH child) 1) ;--- have coupling to specify
          (connect-it&zhang child nint-coup father)
      )
    )ninf-dig)            
    (for-each (lambda(child)
          (connect-out-ext&zhang child father nout-ext-coup)
    )nchild-lst)       
    (for-each (lambda(child)
          (connect-ext-inp&zhang child father next-inp-coup)
    )nchild-lst)
   ;----------Miscellaneous adjustment -------------------
))

;;----------------------------------------------------
;; replace A with B in the list LST
;;---------Feb. 18, 1988  B.P Zeigler ----------------
;;----------------------------------------------------
(define (replace a b lst)
(let loop (
         (fnt '())
         (rem lst)
         )   
(cond
  ((null? rem) fnt)
  ((equal? (car rem) a) (loop (append fnt (list b)) (cdr rem)))
  (else (loop (append fnt (list (car rem))) (cdr rem)))
)))


(define (father->sons coor-name fname ext-inp fext-inp)
  (let ((result '()))
    (for-each (lambda(ftriple)
      (IF (NOT (EQUAL? coor-name (cadr ftriple)))
          (set! result (append result (list ftriple)))
          (for-each (lambda (triple)
             (IF (EQUAL? (cdaddr ftriple) (caaddr triple))
                 (set! result (cons (list fname (cadr triple)
                       (cons (caaddr ftriple) (cdaddr triple))) result))
             )
          )ext-inp)
      )
    )fext-inp)
    (remove-mult result)
))

(define (new-inf-dig&zhang nchild-lst nint-coup)
  (let* ((result '())  (single '()) (influencer '-) (influencee '-))
    (for-each (lambda(child)
        (set! single (list child))
        (set! influencer (send child get-name))
        (for-each (lambda(pair)               
           (when (EQUAL? influencer (car pair))
               (set! influencee (cadr pair))
               (set! influencee (eval `(eval ,influencee) 
                                       user-initial-environment))
               (set! single (append single (list influencee)))
           )
        )nint-coup)                                           
        (set! result (cons (remove-mult single) result))
    )nchild-lst)                          
    (remove-mult result)
))

(define (connect-it&zhang child int-coup father)
   (let* ((head (car child))
          (rest (cdr child))
          (head-name (send head get-name))
          (tail-name '-)                        
          (result '())
         ) 
         (for-each (lambda(tail) 
            (set! tail-name (send tail get-name))
            (for-each (lambda (triple)
                 (IF (AND (EQUAL? tail-name (cadr triple))
                          (EQUAL? head-name (car  triple)))
                     (set! result (cons (caddr triple) result))
                 )
            )int-coup)
         (IF (NOT (NULL? result))
             (send father set-int-coup head tail (remove-mult result)))
         (set! result '())   
         )rest)
))

(define (connect-out-ext&zhang child father out-ext-coup)
  (let* ((name (send child get-name))
         (result '())
        )
    (for-each (lambda(triple)
       (IF (EQUAL? name (car triple))
           (set! result (cons (caddr triple) result)))
    )out-ext-coup)                                     
    (IF (NOT (NULL? result))
      (send father set-ext-out-coup child result))
))

(define (connect-ext-inp&zhang child father ext-inp-coup)
  (let* ((name (send child get-name))
         (result '())
        )
    (for-each (lambda(triple)
       (IF (EQUAL? name (cadr triple))
           (set! result (cons (caddr triple) result)))
    )ext-inp-coup)                                     
    (IF (NOT (NULL? result))
      (send father set-ext-inp-coup child result))
))
 
;----------------------------------
;  remove nested  lists into a single list
;    Guoqing Zhang -- 2/18/1988
;
; EXAMPLE  : (flat-list&zhang '((a b)  (c (d)) e ))
;     results in : (a b c d e)
;-----------------------------------------
(define (flat-list&zhang lst)             
  (COND ((NOT (pair? lst)) (list lst))
        ((NULL? lst) lst)
        (else (clean (append (flat-list&zhang (car lst)) 
                             (flat-list&zhang (cdr lst)))))
))

