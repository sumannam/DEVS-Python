;;enti-me.s

(define (make-entity class id)
     (let* (
               (initial (send (%sc-class-env class) get-initialized))
                (newent 0)
           )
           (set! newent (make-instance class  'name id) )
           (case initial
              (#!true (send (%sc-class-env class) set-lst
                              (cons newent (send (%sc-class-env class)
                                                           get-lst)))
              )
              (#!false  (send (%sc-class-env class) set-lst (list newent))
                        (send (%sc-class-env class) set-initialized #!true)
              )
              (else (display "enter error"))
           )
           newent
    )
)




(macro mk-ent (lambda(e)
     (let (
          (class (cadr e))
          (name (caddr e))
          )
`(begin
(define ,name (make-entity ,class ',name))
(newline)
(display "entity of type ")
(display ',class)
(display " with name ")
(display ',name)
(display " made.")
 ))))



(define (show-class class)
  (map (lambda (entity)(send entity get-name))
                  (send (%sc-class-env class) get-lst)
  )
)

(define (name->entity name lst)
(let (
      (out '())
      )
 (let  find (
           (lst lst)
           (flist '())
           )
  (cond
    ( (null? lst)  (set! out flist) )
    ( (equal?  (send (car lst) get-name) name)
                     (find (cdr lst) (cons (car lst) flist) ))
;                             (display (cons (car lst) flist))
    ( else  (find (cdr lst) flist) )
  )
 )
 (case (length out)
   ( 0 (writeln "there are no entities with this name") '())
   ( 1  (writeln "there is one entity with this name ") (car out))
   ( else (writeln "there are more than one entities with this name ") out)
 )
))



(define-method (entities destroy)()
(let (
     (el (name->entity name lst))
     )
(cond
  ( (pair? el) (writeln "destroy all? (y/n)")
               (if (equal? (read) 'y)
                 (begin (writeln "all destroyed")
                 (for-each (lambda(e)
                              (set! lst (remove e lst))) el))
                 (begin
                 (writeln "destroy the first one? (y/n)")
                 (if (equal? (read) 'y)
                      (begin (writeln "first destroyed")
                      (set! lst (remove (car el) lst)))))))
 ( (null? el) '()) 
 (else (writeln "entity " (send el get-name) " was destroyed")
       (set! lst (remove el lst)))
)) )




(define root-entity
  (make-entity entities 'root-entity)
)

(define (specialized-class obj classname)
   (let rep
      (
      (gen-classname (class-of-object obj))
      (classname classname)
      )
   (cond
     ( (equal? gen-classname classname) #!true)
     ( (null? (mixnames gen-classname))  #!false)
     ( else (rep (car (mixnames gen-classname)) classname))
   )
 )
)

(define (mixnames classname)
   (mixins (name->class classname))
 )


(macro def-class (lambda (e)
 (let (
     (class (cadr e))
     (varlist (caddr e))
      )
`(begin
   (define-class ,class
      (classvars)
      (instvars  ,@(map (lambda(v)`(,v 'u)) varlist))
      (options
       gettable-variables
       settable-variables
       inittable-variables)
    (mixins entities)
  )
(eval '(compile-class ,class))
 )
)))

