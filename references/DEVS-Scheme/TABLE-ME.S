
;;;;;;;;;;;;;table-me.s

(define-method (table-models assert)(tuple)
(let (
     (stab (eval `(state-stab s)))
     )
(assert-rel stab tuple)
))

(define-method (table-models plan)(initials goal)
(let (
     (stab (eval `(state-stab s)))
     (gtab (eval `(state-gtab s)))
     )
(make-plan stab gtab initials goal)
))


(define-method (table-models input?)(goal)
(let* (
     (gtab  (eval `(state-gtab s)))
     (tuple (car (*get-related gtab (list (list 'goal goal)
                                     (list 'state (state-phase s))))))
     (input (project-on-attr gtab tuple 'input))
     )
(inject input '() 0)
input
))


(define-method (table-models show-tuples)()
(let* (
     (gtab (state-gtab s))
     (stab (state-stab s))
     (g-tuples  (get-related gtab ()))
     (s-tuples (get-related stab ()))
     )
(writeln "the goal table is: ")(newline)
(for-each (lambda(tup)(writeln tup)(newline)) g-tuples)
(bkpt () "press <cntrl g> to continue")
(writeln "the state table is: ")(newline)
(for-each (lambda(tup)(writeln tup)(newline)) s-tuples)
))



