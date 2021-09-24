;;;;;;;;;;;;;;;;;;;;;cellular-model.s;;;;;;;;;;;;;;;;;;;;

(define-class cellular-models
   (classvars)
   (instvars    
      origin-cell     ; the cell with cell position (0,0,0.....,0)
      ext-coup        ; ext coupling scheme w/r {broadcast, origin-only}
      infl-origin     ; infl pattern of origin , list of lists (coor)
      structure       ; w/r {fixed, variable}
   )
   (mixins kernel-models)
   (options
      gettable-variables
      settable-variables
      inittable-variables)
)

(compile-class cellular-models)


