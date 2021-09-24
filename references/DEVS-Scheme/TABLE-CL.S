
;;;;;;;;;;;;;;;;;table-cl.s ;;;;;;;;;;;;;;;;

(define-class table-models
(instvars
   (ind-vars table-models-inds)
   (int-transfn int-tab)
   (ext-transfn ext-tab)
   (outputfn out-tab)
)
(options settable-variables gettable-variables inittable-variables)
(mixins atomic-models)
)

(compile-class table-models)
