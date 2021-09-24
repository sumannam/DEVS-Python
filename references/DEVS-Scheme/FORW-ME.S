
;;;;;;;;;;;;;;;;forw-me.s


(define-method (forward-models add-ext-activities)(lst)
(set! (state-ext-activities s)(append (state-ext-activities s) lst))
)

(define-method (forward-models set-ext-activities)(lst)
(set! (state-ext-activities s) lst)
)


(define-method (forward-models add-int-activities)(lst)
(set! (state-int-activities s)(append (state-int-activities s) lst))
)

(define-method (forward-models set-int-activities)(lst)
(set! (state-int-activities s) lst)
)


(define-method (forward-models set-display)()
(set! ind-vars (map (lambda(in)
    (if (or (equal? in 'sigma)    (equal? in '(sigma))
            (equal? in 'phase)    (equal? in '(phase))
            (equal? in 'interpreter-phase) (equal? in '(interpreter-phase))
        )
        (if (pair? in) (car in) in)
        (if (pair? in) in (list in))
    )) ind-vars)
 )
)

(define-method (forward-models copy-state)(m)
(let (
      (src (make-instance atomic-models))
      )
(send src copy-state m)
(set! s (send src get-s))
(set! e (send src get-e))
(set! ind-vars (send m get-ind-vars))
(message-mode-off)
(get-your-name)
(message-mode-on)
))

;;inherits not only state-variables and activities but also
;; values of new inherited variables
;; and values of phase, sigma, and interpreter phase
;; when these are () locally
 
(define-method (forward-models inherit-from)(m)
(let* (
     (my-vars (map (lambda(ind) (if (pair? ind) (car ind) ind))
             (get-ind-vars)))
     (ex-acts (state-ext-activities s))
     (in-acts (state-int-activities s))
     (parent-vars (map (lambda(ind) (if (pair? ind) (car ind) ind))
                      (send m get-ind-vars)))
     (new-vars (difference parent-vars my-vars))
     (new-vals (map (lambda(v)(send m get-sv v))
                                new-vars))
    (parent-phase-val (send m get-sv 'phase))
    (parent-sigma-val (send m get-sv 'sigma))
    (parent-inter-val (send m get-sv 'interpreter-phase))
 
    )
(def-state parent-vars)
(set! (state-ext-activities s)
  (append  ex-acts (state-ext-activities (send m get-s)))
)
(set! (state-int-activities s)
  (append in-acts (state-int-activities (send m get-s))))
(for-each (lambda(v)(set-sv v (car new-vals))
                    (set! new-vals (cdr new-vals)))
                         new-vars)
(when (not (get-sv 'phase))
    (set-sv 'phase parent-phase-val))
(when (not (get-sv 'sigma))
     (set-sv 'sigma parent-sigma-val))
(when (not (get-sv 'interpreter-phase))
     (set-sv 'interpreter-phase  parent-inter-val))
(set-sv 'name (get-name))
(set-display)
))

;;Suppose you have just corrected a file "mod.m"
;;(send mod modify) will update all the models which
;;have mod as their base name
;;eg mod0, mod1, etc. in a kernel-model
 
(define-method (forward-models modify)()
(load (string-append model-base_directory
          (symbol->string name) ".m"))
(for-each (lambda(m)
   (when (base-name (send m get-name))
     (send m set-ext-activities
         (send (eval name)  get-sv 'ext-activities))
     (send m set-int-activities
         (send (eval name)  get-sv 'int-activities))
   ))(getcv forward-models lst))
)
