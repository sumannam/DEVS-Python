;;;;;;;;;;;;;;;;;;;;;;;;;;;;;tree.s;;;;;;;;;;;;;;;;;;;;;

(define-class tree-models
   (classvars)
   (instvars    
       (children-tree (bi-tree)) ; tree of children
       root-child                ; root of children-tree
       leftmost-child-lst        ; list of leftmost child from root
       rightmost-child-lst       ; list of rightmost child from root
       leaf-child-lst            ; list of leaves
       levels                    ; levels of tree
       branches                  ; branches of tree (uniform, balanced)
       ext-inp-coup              ; ext input coupling 
       ext-out-coup              ; ext output coupling
    )                            ; both ext couplings can be one of
   (mixins kernel-models)        ;  {root-only, all-leftmost, 
                                 ;    all-rightmost, all-leaves}
(options
  gettable-variables
  settable-variables
  inittable-variables)
 )

(compile-class tree-models)



