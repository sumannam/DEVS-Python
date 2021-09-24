;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;spec-model.s;;;;;;;;;;;;;;;;;;;;


(define-class spec-models
             (classvars)
             (instvars    
              (x (make-content 'port 'in 'value (gensym)))
              (s (gensym))                                
              (y (make-content 'port 'in 'value (gensym)))
              (e 0)
              (ta 1)
              (int-transfn int)
              (ext-transfn  ext)
              (outputfn out)
              (time-advancefn tad)

             )
   (mixins atomic-models)
   (options
     gettable-variables
     settable-variables
     inittable-variables)
)

(compile-class spec-models)

(define (int s) (gensym))
(define (ext s e x) (content-value x))
(define (out s) (make-content 'port 'out 'value s))
(define (tad s ) 1)

;---------general functions------

(define (identity x) x)

(macro constant (lambda(e)
 (let (
      (val (cadr e))
      )
 `(lambda(s),val)
)))








