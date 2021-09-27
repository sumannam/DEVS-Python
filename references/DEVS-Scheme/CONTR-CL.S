;;;;;;;;;;;;;;;;;;;controlled-models.s;;;;;;;;;;;;;;;;;;;;;

(define-class controlled-models
   (classvars)
   (instvars 
      controller
   )
   (mixins kernel-models)
(options
  gettable-variables
  settable-variables
  inittable-variables)
 )

(compile-class controlled-models)
