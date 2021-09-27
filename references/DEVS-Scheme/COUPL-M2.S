;;coupl-me2.s

(define-method (coupled-models copy-state)(m)  ;;assumes children are in
(let loop (                                    ;;one-one correspondence
          (this-children (get-children))
          (m-children (send m get-children))
          )
(when (not (null? this-children))
      (send (car this-children) copy-state (car m-children))
      (loop (cdr this-children) (cdr m-children))
)))

(define-method (coupled-models get-all-leaf-models)()
   (let (
          (all-leaves '())
        )
       (let rep (
                  (m (get-this-model))
                )
          (if (null? (send-if-handles m get-children))
              (set! all-leaves (append all-leaves (list m)))
              (for-each (lambda(ch) (rep ch)) (send m get-children))
          )
       )
       all-leaves
   )
)


(define-method (coupled-models save-all-state)(to-file)
   (let* (
           (all-leaf-models (get-all-leaf-models))
           (s-pairs-lst '())
           (fnm (symbol->string to-file))
           (fo (open-output-file (string-append mo-base fnm)))
        )
      (for-each (lambda(e) (set! s-pairs-lst (append s-pairs-lst 
         (list (send e get-ind-vars-pairs))))) all-leaf-models)
      (write s-pairs-lst fo)
      (close-output-port fo)
   )
)    

(define-method (coupled-models restore-all-state)(from-file)
   (let* (
           (fnm (symbol->string from-file))
           (fi (open-input-file (string-append mo-base fnm)))
           (models (get-all-leaf-models))
           (state-pairs (read fi))
         )
      (if (> (length models) (length state-pairs))
          (writeln "num of models > num of saved models : cannot restore state")
          (associate-model-state models state-pairs)
      )
      (close-input-port fi)
   )
)


(define-method (coupled-models associate-model-state)(models state-pairs)
   (let rep (
               (models models)
               (state-pairs state-pairs)
            )
      (when (not (null? models))
         (send (car models) resume-state (car state-pairs))
         (rep (cdr models) (cdr state-pairs))
      )                                          
   )
)

(define-method (coupled-models get-corresp-tab) (m)
   (let* (
           (corresp-tab (table))
           (m1-lst (trav-models this-model))
           (m2-lst (send m trav-models m))
           (len1 (length m1-lst))
           (len2 (length m2-lst))
           (class1-lst (map (lambda(m) (send m spec-class-of-object)) m1-lst))
           (class2-lst (map (lambda(m) (send m spec-class-of-object)) m2-lst))
         )
      (cond
         ( (not (equal? len1 len2)) #!false)
         ( (not (equal? class1-lst class2-lst)) #!false)
         ( else (let rep (
                           (m1 m1-lst)
                           (m2 m2-lst)
                         )
                      (if (equal? m1 '())
                          corresp-tab
                          (begin
                             (table-insert-pair corresp-tab (car m1) (car m2))
                             (rep (cdr m1) (cdr m2))
                          )
                       )
                 )
         )
      )
   )
)

(define-method (coupled-models resume-methods)()
   (reload "coupl-me.f")
)

;;; working but very slow because of delete-methods-inherited ;;;
;(define-method (coupled-models delete-methods)()
;   (let (
;          (methods-deleted '(associate-model-state restore-all-state
;                             save-all-state get-all-leaf-models
;                             copy-state translate get-receivers
;                             get-influencees get-children
;                             get-corresp-tab))
;        )
;      (for-each (lambda(method)
;         (if (member method (methods coupled-models))
;             (eval `(delete-method (coupled-models ,method))))
;      ) methods-deleted)
;   )
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-method (coupled-models delete-methods)()
   (delete-method (coupled-models associate-model-state)) 
   (delete-method (coupled-models restore-all-state))
   (delete-method (coupled-models save-all-state)) 
   (delete-method (coupled-models get-all-leaf-models))
   (delete-method (coupled-models copy-state)) 
   (delete-method (coupled-models translate)) 
   (delete-method (coupled-models get-receivers))
   (delete-method (coupled-models get-influencees)) 
   (delete-method (coupled-models get-children))
   (delete-method (coupled-models get-corresp-tab))
   (delete-method (coupled-models show-children))
   (delete-method (coupled-medels inject))
   (delete-method (coupled-models delete-methods))
)

