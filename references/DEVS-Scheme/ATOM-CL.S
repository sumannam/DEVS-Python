;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;atomic-model.s;;;;;;;;;;;;;;;;;;;;

(define-class atomic-models
             (classvars) ;(state-vars '(sigma phase)))
             (instvars
              (ind-vars '(sigma phase))
              (ind-vars-wind) ;; ind for new-window display
              (x (make-content 'port 'in 'value (gensym)))
              (s (make-state))
              (y (make-content 'port 'in 'value (gensym)))
              (e 0)
              (ta 0)
              (int-transfn int-a)
              (ext-transfn  ext-a)
              (outputfn out-a)
              (time-advancefn ta-a)

             )
   (mixins models)
   (options
     gettable-variables
     settable-variables
     inittable-variables)
)


(compile-class atomic-models)

;------------------------------------------------;
(define-structure state sigma phase)
(define-structure content port value)
(define state-vars '(sigma phase))
;------------------------------------------------;


(define (int-a s) (set! (state-phase s) 'active) s)
(define (ext-a s e x) (set! (state-phase s) (content-value x)) s)
(define (out-a s) (make-content 'port 'out 'value (state-phase s)))
(define (ta-a s)(state-sigma s))


;;erase these in atom-me.s and add to end of atom-cl.s

;---------scheduling primitives----


(define s)

(macro passivate-in (lambda (e)
   (let (
        (phase (cadr e))
        )
`(begin
 (set! (state-phase s) ,phase)
 (set! (state-sigma s) 'inf)
))))


(macro passivate (lambda(e)     
`(begin
(set! (state-phase s) 'passive)
(set! (state-sigma s) 'inf)
)))

(macro continue (lambda(e)
 `(if (not (equal? (state-sigma s) 'inf))
     (set! (state-sigma s) (- (state-sigma s) e))
  )
 ))

(macro in-phase? (lambda(e)
  (let (
       (phase (cadr e))
       )
 `(equal? (state-phase s) ,phase)
  )
))

(macro hold-in (lambda(e) 
   (let (
        (phase (cadr e))
        (min-t (caddr e))
        )
`(begin
   (set! (state-phase s) ,phase)
   (set! (state-sigma s) ,min-t)
))))



;---------general functions------

(define (identity x) x)

(macro constant (lambda(e)
 (let (
      (val (cadr e))
      )
 `(lambda(s),val)
)))

;;;;;;;;;;;;;;;;;;;;needed to add atomic-model subclass
;;add to end of atom-cl.s

;;;;;;;;;;;;(mk-st class-name inds)

;1. extends state-vars with  inds
;2. defines state structure with slots the new state-vars
;3. defines variable <class-name>-inds which contains the inds properly aligned
;   to be used in the following class definition
;4. place at front of any functions to be used in class definition                                                

;; example: (mk-st 'table-models '(stab gtab))
;; is placed in table-fn.s

(define (mk-st class-name inds)
(eval `(define state-vars (union2 ',state-vars ',inds))user-initial-environment)
(eval `(define-structure state ,@state-vars) user-initial-environment)
(let (
     (out '())
     (ind-name (symbol-append class-name '-inds))
     )
 (let loop (
          (vars (map (lambda(v)`(',v)) state-vars))
          (lst '())
          )
 (if  (null? vars) (set! out lst)
    (loop (cdr vars) (cons (caar vars) (cons '() lst))))
 )
 (eval `(make-state  ,@out) user-initial-environment)

(eval `(define ,ind-name (align state-vars
             (union2 '(sigma phase) ',inds))) user-initial-environment)
))




