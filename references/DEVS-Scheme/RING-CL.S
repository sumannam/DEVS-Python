;;; RING-MODELS CLASS

(define-class ring-models
   (classvars)
   (instvars
       top-child         ; top of circular ring
       ext-out-coup      ; {broadcast, top-child}
       loop              ; {single, dual}
       routing           ; {single, multi}
       backsteps         ; backword link steps in dual loops
       (influencees-table (table)) ; multi-routing
   )
   (mixins kernel-models)
   (options
       gettable-variables
       settable-variables
       inittable-variables)
)

(compile-class ring-models)

