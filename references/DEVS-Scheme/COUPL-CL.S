;;;;;;;;;;;;;;;;;;;;;;;;;;;;;coupled-model.s;;;;;;;;;;;;;;;

(define-class coupled-models
   (classvars)
   (instvars
              this-model                     ;actual object this instance is
              (selectfn (lambda (l) (car l)))
    )
    (mixins models)
(options
  gettable-variables
  settable-variables
  inittable-variables)
)

;(compile-class coupled-models)







