;;;;;;;;;;;;;;;;;;;;;;;;;;;;module.s;;;;;;;;;;;;;

(macro build-module (lambda(e)
(let
     (
     (name (cadr e))
     (vvs  (caddr e)) ;list of variable,value pairs
     (fn-defs  (cadddr e)) ;list of function-name,args, definition triples
     )
`(begin
 (define ,name
  (lambda()
     (letrec ,vvs
      (lambda (request)
       (case request
              ,@(map (lambda(tr)`(,(car tr) ,(caddr tr))) fn-defs)
         )
       )
     )
   )
)

,@(map (lambda(tr)
 `(define ,(car tr) (lambda (,name ,@(cadr tr))((,name ',(car tr)) ,@(cadr tr) )))

    ) fn-defs)
))))

;(build-module mod ((a 0)(b 0)) (
 ;                        (vala? () (lambda() a))
  ;                       (set1 () (lambda()(set! a 1)))
   ;                      (seta (n)(lambda(n)(set! a n)))
    ;                     (setb (n m)(lambda(n m)(set! b (+ n m))))
     ;                   ))

 ;-----module example------------------
 
;(define module
 ; (lambda()
  ;   (letrec (
   ;             (n 0)
    ;            (f 0)
     ;        )
    ;  (lambda (request)
     ;    (case request
      ;      (def         (lambda (fn)
       ;                     (set! f fn)))
        ;    (add         (lambda ()
         ;                  (set! n (f n))))
          ;  (sub         (lambda ()
           ;                (set! n (- n 1))))
       ;     (val?        (lambda ()
        ;                    (display n)))
         ;   (clear       (lambda ()
          ;                  (set! n 0)))
;)))))

;(define def (lambda (module f) ((module 'def) f)))
;(define add (lambda (module) ((module 'add))))
;(define sub (lambda (module) ((module 'sub))))
;(define val? (lambda (module) ( (module 'val?))))
;(define clear (lambda (module) ( (module 'clear))))

;(define block (module))
;(def block (lambda (n) (+ n 5)))
;(add block)



