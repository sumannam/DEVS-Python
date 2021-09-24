;;;;;;;;;;;Table-fn.s;;;;;;;;;;;;;;;;;;;;

(mk-st 'table-models '(stab gtab window))

(macro hold-in (lambda(e)
   (let (
        (phase (cadr e))
        (min-t (caddr e))
        (twind  (cadddr e))
        )
`(begin
   (set! (state-phase s) ,phase)
   (set! (state-sigma s) ,min-t)
   (when ,twind (set! (state-window s) ,twind))
))))


(define (int-tab s)
(let* (
     (stab  (eval (state-stab s)))
     (tuple (car (*get-related stab  (list (list 'state (state-phase s))
                                (list 'input '())))))
     (next-phase (project-on-attr  stab tuple 'next-state))
     (next-ta  (project-on-attr stab  tuple 'next-ta))
     (next-wind  (when (not (equal? next-ta 'inf))
                    (project-on-attr stab  tuple 'next-wind)))
     )
(when tuple (if next-wind
            (hold-in next-phase next-ta next-wind)
            (passivate-in next-phase))
)
))

(define (out-tab s)
(let* (
     (stab  (eval (state-stab s)))
     (tuple (car (*get-related stab  (list (list 'state (state-phase s))
                                (list 'input '())))))
     (out (project-on-attr stab  tuple 'out))
     )
(make-content 'port out)
))

(define (ext-tab s e x)
(let* (
     (stab  (eval (state-stab s)))
     (tuple (car (*get-related stab  (list (list 'state (state-phase s))
                                (list 'input (content-port x))))))
     (next-phase (project-on-attr stab  tuple 'next-state))
    (next-ta  (project-on-attr stab  tuple 'next-ta))
     (next-wind  (when (not (equal? next-ta 'inf))
                    (project-on-attr stab  tuple 'next-wind)))
     )
(if tuple (if next-wind
            (hold-in next-phase next-ta next-wind)
            (passivate-in next-phase))
          (continue)
)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (make-plan stab gtab  initials goal) ;does not back-up from initials
                                             ;so stops backing up all the way
                                             ;if initials form a cut-set
(define (back-tab stab gtab state goal)
(let* (
     (state-tuple (car (*get-related gtab (list (list 'state state)
                            (list 'goal goal)))))
     (tot (project-on-attr gtab state-tuple 'total))
     (total (if tot tot 0))
     (tuples (*get-related stab (list (list 'next-state state))))
     (new-states '())
     )
(for-each (lambda(tuple)(let* (
                            (pred (project-on-attr stab tuple 'state))
                            (pred-tuple (car
                             (*get-related gtab (list (list 'state pred)
                                       (list 'goal goal) ))))
                            (inp  (project-on-attr stab tuple 'input))
                            (ta  (if inp 0 (project-on-attr stab tuple 'ta)))
                               ;;assumes external transition takes 0 time
                            (pred-total (+ ta total))
                            (prev-total (project-on-attr gtab pred-tuple 'total))
                            )
                       (cond
                       ((null? pred-tuple)
                          (assert-rel gtab (list goal pred inp pred-total))
                          (set! new-states (union2 new-states (list pred))))
                       ((< pred-total prev-total)
                            (retract gtab pred-tuple)
                            (assert-rel gtab (list goal pred inp pred-total))
                            (revise-tab stab gtab goal pred)
                        )
                        )
                        )) tuples)
new-states
))

(let loop (
          (queue (back-tab stab gtab goal goal))
          )
(cond
  ( (null? queue))
  ( (member (car queue) initials)
            (loop  (cdr queue)))
  (else (loop
           (append (cdr queue) (back-tab stab gtab (car queue) goal))))
)))


(define (revise-tab stab gtab goal state)

(define (back-gtab stab gtab goal state)
(let* (
     (tuples (*get-related stab (list (list 'next-state state))))
     (new-states '())
     )
(for-each (lambda(tuple)(let* (
                            (s-tuple (car
                               (*get-related gtab (list (list 'state state)
                                       (list 'goal goal) ))))
                            (total (project-on-attr gtab s-tuple 'total))
                            (pred (project-on-attr stab tuple 'state))
                            (inp  (project-on-attr stab tuple 'input))
                            (ta  (if inp 0 (project-on-attr stab tuple 'ta)))
                            (g-tuple (car
                               (*get-related gtab (list (list 'state pred)
                                       (list 'goal goal) ))))
                            (g-inp  (project-on-attr gtab g-tuple 'input))
                            (g-total (project-on-attr gtab g-tuple 'total))
                            )
                       (when
                          (and g-tuple ;g-tuple is in gtab
                               (< (+ total ta) g-total))
                            (retract gtab g-tuple)
                            (assert-rel gtab (list goal pred inp (+ total ta)))
                            (set! new-states (union2 new-states (list pred)))
                         );when
                        )) tuples)
new-states
))


(let loop (
          (queue (back-gtab stab gtab goal state))
          )
(cond
  ( (null? queue))
  (else (loop
           (append (cdr queue) (back-gtab stab gtab goal (car queue) ))))
)))

(define (make-gtab)
(let (
     (gtab (relation))
     )
(set-attributes gtab '(goal state input total))
gtab
))

(define (make-stab)
(let (
     (stab (relation))
     )
(set-attributes stab '(state input next-state out ta next-ta next-wind))
stab
))
                     

