;;;;;;;;;;;;;;;;;;;;;;;;;;;;;kernel.s;;;;;;;;;;;;;;;;;;;;;

(define-class kernel-models
   (classvars)
   (instvars
       init-cell ; new models created will copy state of init-cell
       class
       (out-in-coup (table))  ;the out-in coupling common to all
   )
    (mixins coupled-models)
(options
  gettable-variables
  settable-variables
  inittable-variables)
 )

(compile-class kernel-models)

