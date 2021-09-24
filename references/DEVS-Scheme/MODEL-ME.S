;;model-me.s


(define-method (models spec-class-of-object)()
(cond
  ((specialized-class (eval name) 'atomic-models) 'atomic-models)
  ((specialized-class (eval name) 'digraph-models) 'digraph-models)
  (else (let loop(
            (model (eval name))
            (lst (delete! 'kernel-models (sub-classes 'kernel-models)
                     ))
            )
  (cond
   ( (null? lst) (error "model is not in class of DEVS-SCHEME " name))
   ( (specialized-class model (car lst)) (car lst))
   ( else (loop model (cdr lst)))
)))))


;;;;;;; the following was replaced by the above -- not good form

;(define-method (models spec-class-of-object)()
;   (let (
;          (model (eval (get-name)))
;        )
;      (cond
;         ((specialized-class model 'atomic-models) 'atomic-models)
;         ((specialized-class model 'digraph-models) 'digraph-models)
;         ((specialized-class model 'broadcast-models) 'broadcast-models)
;         ((specialized-class model 'hypercube-models) 'hypercube-models)
;         ((specialized-class model 'cellular-models) 'cellular-models)
;         ((specialized-class model 'controlled-models) 'controlled-models) 
;         ((specialized-class model 'tree-models) 'tree-models) 
;         (else (error "model is not in class of DEVS-SCHEME " models)) 
;      )
;   )
;)

(define-method (models trav-models)(model)              
   (let* (                             
           (m model)
           (children (if (null? (send-if-handles m get-children)) 
                         ()
                         (if (null? (send-if-handles m get-init-cell))
                             (send m get-children)
                             (list (send m get-init-cell)))))
         )
      (cons m
           (union (map (lambda(ch) (send ch trav-models ch)) children))
      )
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;

(build-module pseudo-class
       (
       (pseudo-class-nm '())
       (parent-class-nm '())
       (originator '())
       (lst '())
       )
       (
(get-pseudo-class-nm ()(lambda()pseudo-class-nm))
(set-pseudo-class-nm (pseudo)(lambda(pseudo)(set! pseudo-class-nm pseudo)))
(set-parent-class-nm (class-nm)(lambda(class-nm)
          (set! parent-class-nm class-nm)))
(get-parent-class-nm ()(lambda()parent-class-nm))
(set-originator (model)(lambda(model)(set! originator model)))
(get-originator ()(lambda()originator))
(add-instance (newent) (lambda(newent)(set! lst (append lst
                            (list newent)))))
(get-pseudo-class-lst ()(lambda()lst))
(set-pseudo-class-lst (new-lst)(lambda(new-lst)(set! lst new-lst)))
       )
)

(define (make-pseudo-entity pseudo-class id) ;;pseudo-class exists
     (let (
          (newent 0)
          )
          (set! newent
            (make-instance  (eval (get-parent-class-nm pseudo-class))
                        'name id) )
           (add-instance pseudo-class newent)
           newent
    )
)


(macro mk-pseudo-ent (lambda(e)
     (let (
          (pseudo-class (cadr e))
          (name (caddr e))
          )
`(begin
(define ,name (make-pseudo-entity ,pseudo-class ',name))
(display "entity of pseudo-class ")
(display ',pseudo-class)
(display " with name ")
(display ',name)
(display " made.")
 ))))



(define (show-pseudo-class pseudo-class)
  (map (lambda (entity)(send entity get-name))
                  (get-pseudo-class-lst pseudo-class))
)


(define-method (models make-class)(pseudo-class-name)
  (let (
     (psc (pseudo-class))
     )
(set-pseudo-class-nm psc pseudo-class-name)
(set-parent-class-nm psc (class-of-object (eval name)))
(set-originator psc (eval name))
   (eval `(define ,pseudo-class-name ,psc)
              user-initial-environment)
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-method (models delete-methods)()
   (delete-method (models spec-class-of-object)) 
   (delete-method (models trav-models))
   (delete-method (models delete-methods))
)

;;;6-18-89
(define-method (models resume-methods)()
 (reload "model-me.f")
)
