;;;;;;;;;;;;;;;;;;;;;;;;;model.s;;;;;;;;;;;;;;;;;;;;;;

(define-class models
             (classvars)
             (instvars
               cell-position
               (processor 0)
               (parent 0)
               (wind (make-window))
               (cp (cons 0 0))
               (nw (make-nwind))
               inport
               outport
             )
   (mixins entities)
   (options
     gettable-variables
     settable-variables
     inittable-variables)
)
;(compile-class models)


(define-structure nwind
  (wind (make-window))
  (cp (cons 0 0))
  (display #f)
)


(define-method (models get-nw)(var)
(let (
     (nm (symbol-append 'nwind- var))
     )
 (eval `(,nm nw))
 ))

(define-method (models set-nw)(var val)
(let (
     (nm (symbol-append 'nwind- var))
     )
(eval `(set! (,nm nw) ',val))
 ))










(define (grand-children model)
(if (specialized-class model 'atomic-models)
    1
    (let (
         (num 0)
         )
    (for-each (lambda(chd)(set! num (+ num (grand-children chd))))
                  (send model get-children))
    num
    )
))

(define (depth model)
(if (specialized-class model 'atomic-models)
     1
    (let (
         (num 0)
         )
    (for-each (lambda(chd)(set! num (max num (depth chd))))
                  (send model get-children))
    (1+ num)
    )
))











