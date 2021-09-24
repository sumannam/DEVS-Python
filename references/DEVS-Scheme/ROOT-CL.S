;;;;;;;;;;;;;;;;;;;;;;;;;;;;root-co-ordinator;;;;;;;;;;;;;;;

(define-class root-co-ordinators
    (classvars)
    (instvars
        child       ;processor
        (clock-base 0)
        (devs-component (make-entity atomic-models 'dum))
        (timer (time-gen))
        just-initialized
        (terminate '())
    )



    (mixins processors)
   (options
         gettable-variables
         settable-variables
         inittable-variables)
)

(compile-class root-co-ordinators)


