;; atom-me2.s

(define-method (atomic-models add-introspection)() 
(def-state '(name %temp-phase% %temp-sigma% %result%)) (set-sv 'name name) 
(let ( 
     (old-int int-transfn)
     (old-ext ext-transfn)
     (old-out outputfn)
     )
(set! int-transfn (lambda(s)
   (if (equal? (state-phase s) '%report%)
    (hold-in (state-%temp-phase% s) (state-%temp-sigma% s))
    (old-int s)
   )))
(set! ext-transfn (lambda (s e x)
   (case (content-port x)
      ('%interrogate% (interrogate s e x))
      ('%obey% (obey s e x))
      (else (old-ext s e x))
    )))
(set! outputfn (lambda(s)
(if (equal? (state-phase s) '%report%)
    (make-content 'port '%report% 'value (state-%result% s))
    (old-out s)
    )))
))


(define (interrogate s e x)
(let* (
     (request (content-value x))
     (model (eval (state-name s) user-initial-environment))
     (result (eval request model))
     )
(eval `(begin
      (set-sv '%result%  ',result)
      (set-sv '%temp-sigma%  (get-sv 'sigma))
      (set-sv '%temp-phase% (get-sv 'phase))
      (hold-in '%report% 0)
      ) model)
))



(define (obey s e x)
(let (
     (request (content-value x))
     (model (eval (state-name s) user-initial-environment))
     )
(eval request model)
(continue)
))



(define-method (atomic-models save-all-state)(to-file)
   (let* (
           (fnm (symbol->string to-file))
           (fo (open-output-file (string-append mo-base fnm)))
         )
      (write (get-ind-vars-pairs) fo)
      (close-output-port fo)
   )
)    

(define-method (atomic-models restore-all-state)(from-file)
   (let* (
           (fnm (symbol->string from-file))
           (fi (open-input-file (string-append mo-base fnm)))
         )
       (resume-state (read fi))
       (close-input-port fi)
   )
)

(define-method (atomic-models get-ind-vars-pairs)()
   (let rep (
              (fields ind-vars)
              (retlst '())
            )                  
      (if (null? fields)
          retlst
          (rep (cdr fields) 
               (append retlst (list (cons (car fields) 
                    ((eval (symbol-append 'state- (car fields))) s)))))
      )
   )
)

(define-method (atomic-models resume-state)(ind-vars-pairs)
   (let (
          (old-ind-vars (map (lambda(e) (car e)) ind-vars-pairs))
        )
      (def-state (difference old-ind-vars '(sigma phase)))             
      (let rep (                     
                 (lst-ind-vars  ind-vars-pairs)
                 (lst-state-vars state-vars)
                 (ref-s 1)
               )
         (if (not (null? lst-ind-vars))        
             (if (equal? (caar lst-ind-vars) (car lst-state-vars))
                 (begin
                    (vector-set! s ref-s (cdar lst-ind-vars))
                    (rep (cdr lst-ind-vars) (cdr lst-state-vars) (1+ ref-s)))
                 (rep lst-ind-vars (cdr lst-state-vars) (1+ ref-s))
             )            
         )
      )
      
   )
) 

(define-method (atomic-models isomorphic?) (m)
   (and
      (equal? ind-vars    (send m get-ind-vars))
      (equal? int-transfn (send m get-int-transfn))
      (equal? ext-transfn (send m get-ext-transfn))
      (equal? outputfn    (send m get-outputfn))
   )
)

(define-method (atomic-models delete-methods)()
   (delete-method (atomic-models make-copy))
   (delete-method (atomic-models resume-state))
   (delete-method (atomic-models get-ind-vars-pairs))
   (delete-method (atomic-models restore-all-state))
   (delete-method (atomic-models save-all-state initial-state))
   (delete-method (atomic-models initial-state))
   (delete-method (atomic-models copy-state))
   (delete-method (atomic-models time-advance?))
   (delete-method (atomic-models output?))
   (delete-method (atomic-models ext-transition))
   (delete-method (atomic-models int-transition))
   (delete-method (atomic-models set-elapsed-time))
   (delete-method (atomic-models set-ext-event))
   (delete-method (atomic-models make-new))
   (delete-method (atomic-models set-state))
   (delete-method (atomic-models def-time-advancefn))
   (delete-method (atomic-models def-state))
   (delete-method (atomic-models def-outputfn))
   (delete-method (atomic-models def-ext-transfn))
   (delete-method (atomic-models def-int-transfn))
   (delete-method (atomic-models get-sv)) 
   (delete-method (atomic-models set-sv))
   (delete-method (atomic-models set-pairs))
   (delete-method (atomic-models get-vals))
   (delete-method (atomic-models set-display))
   (delete-method (atomic-models add-introspection)) 
   (delete-method (atomic-models add-ext-event-observation))
   (delete-method (atomic-models add-int-event-observation))
   (delete-method (atomic-models make-true-class))
   (delete-method (atomic-models get-your-name))
   (delete-method (atomic-models inject))
   (delete-method (atomic-models state-var-display-request))
   (delete-method (atomic-models isomorphic?))
   (delete-method (atomic-models delete-methods))
)

(define-method (atomic-models resume-methods)()
   (reload "atom-me.f")
   (reload "atom-me2.f")
)


(define-method (atomic-models make-true-class)(class-name)
   (send-if-handles (make-instance models) delete-methods)
   (send-if-handles (make-instance atomic-models) delete-methods)
   (gc)
   (eval `(make-atomic-class ,class-name (eval ,name)) 
              user-initial-environment)   ;assumes (define ,name...)
   (send (make-instance models) resume-methods) 
   (send (make-instance atomic-models) resume-methods)
 )

(macro make-atomic-class (lambda(e)
  (let* (
       (class-name (cadr e))
       (m (caddr e))
       )
`(begin
    (define-class ,class-name
       (classvars)
       (instvars
         (ind-vars  (send ,m get-ind-vars))
         (int-transfn  (send ,m get-int-transfn))
         (ext-transfn  (send ,m get-ext-transfn))
         (outputfn  (send ,m get-outputfn))
       )
      (mixins atomic-models)
    )
(eval '(compile-class ,class-name)user-initial-environment)          ;note use of ' to make this work
  )
)))


(define-method (atomic-models add-int-event-observation)(exp)
(let (
     (old-out outputfn)
     (model (eval name user-initial-environment))
     )
(set! outputfn (lambda(s)
    (cond
     ( (> (state-sigma s) 0) ;; no observation in transient state
              ; (not (member (state-phase s) '(%ext-report% %report%)))
            (list
             (make-content 'port '%int-event% 'value (eval exp model))
             (old-out s)
            )
     )
     (else (old-out s))
    )
))))


(define-method (atomic-models add-ext-event-observation)(exp)
(def-state '(%ext-phase% %ext-sigma% %ext-result%))
(let (
     (old-int int-transfn)
     (old-ext ext-transfn)
     (old-out outputfn)                          
     (model (eval name user-initial-environment))
     )
(set! int-transfn (lambda(s)
   (if (equal? (state-phase s) '%ext-report%)
    (hold-in (state-%ext-phase% s) (state-%ext-sigma% s))
    (old-int s)
   )))
(set! ext-transfn (lambda (s e x)
   (let* (
         (result (eval exp model))
         )
   (old-ext s e x)
    (eval `(begin
      (set-sv '%ext-result%  ',result)
      (set-sv '%ext-sigma%  (get-sv 'sigma))
      (set-sv '%ext-phase% (get-sv 'phase))
      (hold-in '%ext-report% 0)
      ) model)
  )    
))
(set! outputfn (lambda(s)
(if (equal? (state-phase s) '%ext-report%)
    (make-content 'port '%ext-event% 'value (state-%ext-result% s))
    (old-out s)
    )))
))
 
 
