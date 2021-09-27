;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;di-model.s;;;;;;;;;;;;;;;

(define-class digraph-models   ;digraph coupled models
   (classvars)
   (instvars
              this-model                     ;actual object this instance is
              (composition-tree (bi-tree))  ;special
              (children '())
              (influence-digraph (digraph))       ;special
              (selectfn (lambda (l) (car l)))
              (priority-list '())

    )
    (mixins coupled-models)
(options
  gettable-variables
  settable-variables
  inittable-variables)
)

(compile-class digraph-models)

(define-method (digraph-models set-priority)(plist)
(set! priority-list plist)
(set! selectfn (eval `(make-priority-order ,plist)))
)

(define (priority-order prior-lst lst)
 (define (priority prior-lst lst)
 (let loop (
          (rlist prior-lst)
          )
 (cond                
  ((null? rlist) '())      
  ((and (not (pair? (car rlist))) (member (car rlist) lst)) (car rlist))
  ((and (pair? (car rlist)) (priority (car rlist) lst))
          (priority (car rlist) lst))  
  (else (loop (cdr rlist)))
 )))
(let (
     (result (priority prior-lst lst))
     )
 (if result result (car lst))
))  

(macro make-priority-order (lambda(e)
(eval `(lambda(lst)(priority-order ',(cadr e) lst)))
))
