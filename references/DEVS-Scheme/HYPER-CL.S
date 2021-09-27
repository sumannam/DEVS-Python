;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;hypercube-model.s;;;;;;;;;;;;;;;;;;;;


(define-class hypercube-models
    (classvars)
    (instvars    
       origin-cell  ; the cell with cell position (0,0,0.....,0)
       ext-coup  ; ext coupling scheme w/r {broadcast, origin-only}
       num-infl  ; numbers of influencees w/r {1,2, . . . ,dimension}
    )
   (mixins kernel-models)
   (options
     gettable-variables
     settable-variables
     inittable-variables)
)

(compile-class hypercube-models)


