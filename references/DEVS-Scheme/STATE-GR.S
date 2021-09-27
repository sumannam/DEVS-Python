 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;state-gr.s;;;;;;;;;;;;;;;;;;

(define-structure linkk
      left
      right 
      input-test
      text
      buffer
)

(define   (outgoing  edges cur)
                           (let scan (
                                 (elist edges)
                                 (olist '())
                                )
                            (if (null? elist)
                                olist

                              (if (equal? (linkk-left (car elist))  cur )
                                  (scan (cdr elist) (cons (car elist)
                                                                  olist) )
                                  (scan (cdr elist) olist)
                              )
                            )

                          )
)

(define  (successors  edges node)
            (map (lambda (lnk) (linkk-right lnk))
                                    (outgoing edges node))
)

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
          ( (null? elist) (display "no such edge ")'())
          ( (and (equal? (linkk-left (car elist)) n1)
                 (equal? (linkk-right (car elist)) n2))
                     (car elist) )
          (else (rep (cdr elist)) )
         )
       )
)

(define (find-arc edges input-test text buffer)
        (let rep (
              (elist edges)
             )
        (cond
          ( (null? elist) (display "no such arc ")'())
          ( (and (equal? (linkk-input-test (car elist)) input-test)
                 (equal? (linkk-text (car elist)) text)
                 (equal? (linkk-buffer (car elist)) buffer))
                     (car elist) )
          (else (rep (cdr elist)) )
         )
       )
)


(define-structure sta name function fn-text outg fn)


(build-module state-graph
           (
                 (nodes '())
                 (edges '())
                 (cur   0)
                 (buffer '())
                 (initial-state (make-sta 'name 'ini))
                 (keywords '(!))
             )
             (                  

(add-keyword (word) (lambda(word)(set! keywords (union2 keywords (list word)))))
(initialize-state () (lambda()(set! nodes (union2 nodes (list initial-state)))
                              (set! cur initial-state)))
(set-buffer (lst) (lambda(lst)(set! buffer lst)))
(get-buffer () (lambda() buffer))
(add-buffer (input)
      (lambda(input)(set! buffer (append buffer (list input))))
)
(initial-state? () (lambda() initial-state))
(current-state?  ()     (lambda ()  cur ))
(set-state (node)     (lambda (node)
                           (if (member node nodes)
                               (set! cur node)
                               (display "state not in graph")
                           )
                        )
)
(add-arc (l r input-test text buffer)
              (lambda(l r input-test text buffer)
            (if (null? (find-edge edges l r))
                               (begin (set! edges
                               (cons (make-linkk 'left l
                                         'right r
                                  'input-test input-test
                                  'text text 'buffer buffer) edges))
                               (when (not (member l nodes))
;                                  (set! nodes (append nodes (list (list l))))
        (set! nodes (cons l nodes))
                               )
                               (when (not (member r nodes))
;                                  (set! nodes (append nodes (list (list l))))
        (set! nodes (cons r nodes))
                               )
                              )
                              (print "transition-already exists")
                               )
                   )
)
(outg-arcs?   ()      (lambda () (outgoing edges cur)))
(inc-arcs?  ()       (lambda ()(incoming edges cur)))
(next-states? ()  (lambda ()(successors edges cur)))
(states?  ()      (lambda () nodes))
(arcs?  ()       (lambda () edges))
(keywords? () (lambda() keywords))
(set-states (st) (lambda (st)(set! nodes st)))
(set-arcs (ar)   (lambda (ar) (set! edges ar)))
(set-keywords (ke) (lambda(ke)(set! keywords ke)))
(get-ini () (lambda() initial-state))
(set-ini (ini) (lambda(ini)(set! initial-state ini)))
            )
)


(define (show-names lst)
  (for-each (lambda (node)(display (send node get-name)) (display " ") ) lst)
(newline)
)

(define (show-linkks lst)
  (for-each (lambda (edge)
              (writeln "edge: "
              (send (linkk-left edge) get-name) " -> "
              (send (linkk-right edge) get-name) ": "
             (linkk-input-test edge) " "
             (linkk-text edge)" " (linkk-buffer edge)
             ))
   lst )
(newline)
)


(define (show-states di)
(show-names (states? di))
)

(define (show-arcs di)
(show-linkks (arcs? di))
)

(macro test-for (lambda(e)
(let (
     (const (cadr e))
     )
`(lambda(x)(equal? x ',const))
))
)
          



(define (transit di arc)
(set-state di (linkk-right arc))
)           


(define test-for! (test-for !))

                        

(define (input-tests arcs)
(map (lambda(arc)(linkk-input-test arc)) arcs)
)

(define (texts arcs)
(map (lambda(arc)(linkk-text arc)) arcs)
)

(define (buffers arcs)
(map (lambda(arc)(linkk-buffer arc)) arcs)
)

                       
                                      
(define (quoted-symbol? x)
(and (pair? x) (equal? (car x) 'quote))
)


(define (save-state-graph st-nm)
(let* (     
     (file-nm (string-append (symbol->string st-nm) ".sta"))
     (p (open-output-file file-nm)) 
     (st (eval st-nm))                             
     (states (map (lambda(s)(set! (sta-function s) '()))(states? st)));;takes
                                 ;;;car of changing arcs as well
     (ini (get-ini st))
     (arcs (arcs? st))
     (keywords (keywords? st))
     )       
;(write states p)
(write arcs p)
(write keywords p)
(write ini p)
(close-output-port p)
))
          

(define (restore-state-graph st-nm)
(let* (                                                     
     (file-nm (string-append devs_directory (symbol->string st-nm) ".sta"))
     (p (open-input-file file-nm))
     (states ())                                       
     (sts '())
     (arcs (read p))
     (keywords (read p))
     (ini (read p))
     (st (state-graph))
     (help-nm (symbol-append 'help- st-nm))
     )               
(close-input-port p)           
(set-ini st ini)
(set! states (recover-states arcs))
(set! sts (map (lambda(st)(set! (sta-outg st) '())
                       (set! (sta-function st) (eval (sta-fn st)))
                  ) states))
(set-states st  sts)
(set-arcs st arcs)
(set-keywords st keywords)
(eval `(define ,st-nm ,st) user-initial-environment)
(eval `(define (,help-nm) (interpret ,st)) user-initial-environment)
)) 

(define (recover-states arcs)
(let loop (
     (lst arcs)
     (states '())
     )
(cond
( (null? lst) (remove-mult states))
( else (loop (cdr lst) (cons (linkk-right (car lst)) 
                           (cons (linkk-left (car lst)) states))
        ))
)
))  
                                         
(alias csg construct-state-graph)

                             
(macro construct-state-graph (lambda(e)
    (let (
         (di   (cadr e))
         ( list-of-triples (caddr e))
         ( function (cadddr e))
         ( fn-text (car (cddddr e)))
         )
`(con-state-graph ,di ,list-of-triples ,function ,fn-text ',function)
)))

(define (con-state-graph di list-of-triples function fn-text fn)
(initialize-state di)
(for-each (lambda(state)(set! (sta-outg state) '())) (states? di)) 
(let loop
     (
     (lst  list-of-triples)
     (input-test (caar list-of-triples))
     (text (cadar list-of-triples))
     (buffer (caddar list-of-triples))
     (arc (find-arc (outg-arcs? di)(caar list-of-triples)
          (cadar list-of-triples) (caddar list-of-triples)))
     )
(cond
( (null? lst) (eval `(set! (sta-function (current-state? ,di)) ',function))
              (eval `(set! (sta-fn-text (current-state? ,di)) ',fn-text))
              (eval `(set! (sta-fn (current-state? ,di)) ',fn))
 )

( (not (null? arc))
    (transit di arc)
    (loop (cdr lst) (caadr lst) (cadadr lst) (car (cddadr lst))
             (find-arc (outg-arcs? di)
                 (caadr lst)(cadadr lst)(car (cddadr lst))))
 )
(else (let (
           (new (make-sta 'name (gensym)))
           )
    (if (and (pair? input-test)
             (equal? (car input-test) 'test-for)
        )
        (add-keyword di (cadr input-test))
     )
    (add-arc di (current-state? di) new input-test text buffer)
    (add-arc di (current-state? di) (initial-state? di)
                        'test-for! "[to abort->press: !]" '())
    (set-state di new)
    (loop (cdr lst) (caadr lst) (cadadr lst) (car (cddadr lst))
        (find-arc (outg-arcs? di) (caadr lst)(cadadr lst)(car (cddadr lst)) ))

 ))
)
))                                        



(define (final-state? di)
(sta-function (current-state? di))
)
          

(define (interpret di)
(initialize-state di)
(set-buffer di '())
(let loop (
          (input '())
          )
(cond
( (final-state? di)
(writeln (sta-fn-text (current-state? di)))
(writeln 
    (eval `((eval (sta-function (current-state? ,di))) ,@(get-buffer di)))
) 

    (interpret di))
 (else
    (loop (read-input di))
 )
)
))


(define (req-inp di)
 (newline)
 (writeln "enter one of the following: "
     (texts  (sta-outg (current-state? di))))
(let (
     (x (read))
     (assigned '())
     )
(when (symbol? x)
(set! assigned (eval `(access ,x user-initial-environment)))
)  
(if (and 
         (equal? assigned #!unassigned)      
         (not (member x (keywords? di)))      
     )
    (begin
    (writeln "input is not bound: try again")
    (req-inp di)
    )
  x  
)))               
                                             

(define (read-input di)
(when (null? (sta-outg (current-state? di)))
      (set! (sta-outg (current-state? di)) (outg-arcs? di)))

(let loop (
          (tests (input-tests  (sta-outg (current-state? di))))
          (test (car (input-tests  (sta-outg (current-state? di) ))))
          (buffs (buffers  (sta-outg (current-state? di) )))
          (buff (car (buffers  (sta-outg (current-state? di) ))))
          (arcs  (sta-outg (current-state? di) ))
          (arc (car (sta-outg (current-state? di) )))

          (inp  (req-inp di))
          )              
(cond
((equal? inp '!)(writeln "aborted! ")(interpret di))
((null? tests) (writeln "try again: ") (read-input di))
( (eval `( ,test ',inp)) 
        (when buff   (add-buffer di inp)) (transit di arc) )
 ( else  (loop (cdr tests) (cadr tests) (cdr buffs) (cadr buffs)
               (cdr arcs) (cadr arcs) inp))
)))                                      

