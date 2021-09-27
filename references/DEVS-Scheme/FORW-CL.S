
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;forw-cl.s;;;;;;;;;;;;;;;;;;;;

(define-class forward-models
             (classvars)
             (instvars
              (ind-vars '(sigma phase interpreter-phase
                          before-output-buffer after-output-buffer
                          action-buffer ext-activities int-activities))
              (int-transfn int-for)
              (ext-transfn  ext-for)
              (outputfn out-for)
             )
   (mixins models)
   (options
     gettable-variables
     settable-variables
     inittable-variables)
(mixins atomic-models)
)


(compile-class forward-models)


