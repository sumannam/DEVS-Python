;;;;;;;;;;;;;;;;;;;;;;;;;;;;;digraph.s;;;;;;;;;;;;;;;;;;

(define-structure link
      left
      right
      (port-pairs  '())     ;list of pairs (a.b) a,b are port-names
)

(define   (outgoing  edges cur)
                           (let scan (
                                 (elist edges)
                                 (olist '())
                                )
                            (if (null? elist)
                                olist

                              (if (equal? (link-left (car elist))  cur )
                                  (scan (cdr elist) (cons (car elist)
                                                                  olist) )
                                  (scan (cdr elist) olist)
                              )
                            )

                          )
)

(define  (successors  edges node)
            (map (lambda (lnk) (link-right lnk))
                                    (outgoing edges node))
)
(define (converse edges)
   (map     (lambda (edge)
                    (make-link 'left (link-right edge)
                                     ' right (link-left edge)))
        edges))

(define (incoming edges cur)
         (outgoing (converse edges) cur)
)
(define (in-edge? edges node)
                 (let (
                       (vect (list->vector edges))
                       (found (not (null? (outgoing edges node))))
                      )
                   (do ((i 0 (+ 1 i) ))
                       ((or (>= i (vector-length vect)) found) found)
                       (set! found (member node (successors edges
                                                 (vector-ref vect i))))
                    )
                 )
)

(define (find-edge edges n1 n2)
        (let rep (
              (elist edges)
             )
        (cond
          ( (null? elist) '() ) ;;; (display "no such edge ")
          ( (and (equal? (link-left (car elist)) n1)
                 (equal? (link-right (car elist)) n2))
                     (car elist) )
          (else (rep (cdr elist)) )
         )
       )
 )





(build-module digraph
           (
                 (nodes '())
                 (edges '())
                 (cur   0)
             )
             (
(di-initialize (node)    (lambda (node)
                           (set! nodes (list node))
                           (set! cur node)
                        )
)
(current?  ()     (lambda ()  cur ))
(set-current (node)     (lambda (node)
                           (if (member node nodes)
                               (set! cur node)
                               ;;;;;;;;;;; (display "entity not in graph")
                           )
                        )
)
(nodes?  ()      (lambda () nodes))
(edges?  ()       (lambda () edges))
(add-nodes (lst)   (lambda(lst)(set! nodes (union (list lst nodes)))))
(add-edge (l r pairs)    (lambda(l r pairs)(if (null? (find-edge edges l r))
                               (begin (set! edges
                               (cons (make-link 'left l
                                         'right r 'port-pairs pairs) edges))
                               (when (not (member l nodes))
                                  (set! nodes (cons l nodes))
                               )
                               (when (not (member r nodes))
                                  (set! nodes (cons r nodes))
                               )
                              )
                              ;;;;;;;;;;;;; (print "edge-already exists")
                               )
                   )
)
(di-add   (node)        (lambda (node)
                          (if (member node (successors edges cur))
                              () ;;;;;;;; (display "edge already exists")
                              (begin (set! edges
                               (cons (make-link 'left cur  'right node) edges))
                               (when (not (member node nodes))
                                  (set! nodes (cons node nodes))
                               )
                              )
                          )
                       )
)
(outg?   ()      (lambda () (outgoing edges cur)))
(inc?  ()       (lambda ()(incoming edges cur)))
(successorss? ()  (lambda ()(successors edges cur)))
(del-edge   (node)        (lambda (node)
                            (if (member node (successors edges cur))
                                (let remove (
                                           (olist edges)
                                           (front '())
                                            )
                                  (if (and (equal? (link-left
                                                    (car olist)) cur)
                                           (equal? (link-right
                                                    (car olist)) node)
                                      )
                                      (set! edges (append front (cdr olist)))
                                      (remove (cdr olist) (cons (car olist)
                                                                   front))
                                  )
                                )
                             (display "node not a successor of current")
                            )
                         )

)
(del-node (node)       (lambda (node)
                            (let remove (
                                         (nlist nodes)
                                         (front '())
                                        )
                              (if (member node nodes)
                               (if (in-edge? edges node)
                                   (display "node cannot be deleted")
                                 (begin
                                    (when (equal? cur node) ())
                                       ;;;(display "current must be reset "))
                                     (if (equal? node (car nlist))
                                      (set! nodes (append (cdr nlist) front))
                                      (remove (cdr nlist) (cons (car nlist)
                                                              front))
                                     )
                                   )
                                 )
                                (display "entity is not a node in digraph")
                              )
                             )
                       )
)
(insert-pair (edge port-name1 port-name2)  (lambda (edge port-name1 port-name2)
                                (let rep (
                                      (table (link-port-pairs edge))
                                          )
                                 (cond
                                   ( (null? table)
                                       (set! (link-port-pairs edge)
                                        (cons (cons port-name1 port-name2)
                                               (link-port-pairs edge) ) )
                                   )
                                   ( (equal? (car (car table)) port-name1)
                                         (display port-name1)
                                         (display " already associated")
                                   )
                                   ( else  (rep (cdr table))   )
                                 )
                               )
                             )
)
(del-pair  (edge port-name)       (lambda (edge port-name)
                                (let rep (
                                      (table (link-port-pairs edge))
                                      (front '())
                                          )
                                 (cond
                                   ( (null? table)
                                        (display "error: no such port-name")
                                   )
                                   ( (equal? (car (car table)) port-name)
                                         (set! (link-port-pairs edge)
                                           (append front (cdr table)))
                                   )
                                   ( else  (rep (cdr table) (cons (car table)
                                                        front))
                                   )
                                 )
                               )
                             )
)
(associate  (edge port-name)       (lambda (edge port-name)
                                    (let rep (
                                      (table (link-port-pairs edge))
                                     )
                                 (cond
                                   ( (null? table)
                                        '())
                                   ( (equal? (car (car table)) port-name)
                                         (cdr (car table))  )
                                   ( else  (rep (cdr table))   )
                                 )
                               )
                             )
)
            )
)

;-----------------------

;(define foo

 ; (let (
  ;     (gr (digraph))
   ;    (n1 (make-entity entities 'n1))
    ;   (n2 (make-entity entities 'n2))
     ;  )
;(di-initialize gr n1)
;(di-add gr n2)

;(insert-pair gr (car (outg? gr )) 'a 'b)
;(associate  gr (car (outg? gr)) 'a)
;(del-pair gr (car (outg? gr)) 'a)
 ; )
;)

(define (copy-digraph di tab)
(let (
     (new (digraph))
     )
(add-nodes new (map (lambda(n)(table-look-up tab n)) (nodes? di)))
(for-each (lambda(e)(add-edge new (table-look-up tab (link-left e))
                                  (table-look-up tab (link-right e))
                                  (link-port-pairs e)))
       (edges? di))
new
))

(define (show-names lst)
  (for-each (lambda (node)(display (send node get-name)) (display " ") ) lst)
(newline)
)


(define (show-links lst)
  (for-each (lambda (edge)
              (writeln "edge: "
              (send (link-left edge) get-name) " -> "
              (send (link-right edge) get-name) ": "
              (link-port-pairs edge)
             ))
   lst )
(newline)
)

(define (show-nodes di)
(show-names (nodes? di))
)

(define (show-edges di)
(show-links (edges? di))
)

(define (di-insert-pair di n1 n2 p1 p2)
(insert-pair di (find-edge (edges? di) n1 n2) p1 p2)
)

(define (di-delete-pair di n1 n2 p1)
(del-pair di (find-edge (edges? di) n1 n2) p1)
)
