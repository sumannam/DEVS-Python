;;dimod-me.s

(define ($logic-and bool-lst)
 (not (member '() bool-lst)) 
) 

(define ($influencees child clist)
                         (let  rep (
                                   (clist clist)

                                   )
                            (cond
                              ( (null? clist) '())
                              ( (equal? (caar clist) child)
                                                       (cdar clist))
                              (else  (rep (cdr clist)))
                            )
                          )
 )


(define ($construct-int-coup children child-inf-list)
    (letrec
       (  (pivot (make-entity entities 'p))
          (inf-graph (digraph))

       )

     (di-initialize inf-graph pivot)
     (for-each (lambda (ch) (di-add inf-graph ch)) children)
     (for-each (lambda (child)
                  (set-current inf-graph child)
                  (when (not (null? ($influencees child
                                     child-inf-list)))
                    (for-each (lambda(influencee)
                                (di-add inf-graph influencee))
                                    ($influencees child child-inf-list)))
               )
                                      children)
     (set-current inf-graph pivot)
     (for-each (lambda (child) (del-edge inf-graph child)) children)
     (del-node inf-graph pivot)
     inf-graph
   )
)
;------------------------------------------

(define-method (digraph-models get-influencees) (child)
    (successors  (edges? influence-digraph) child)
)

(define-method (digraph-models get-receivers)()
    (successors  (bi-edges? composition-tree) this-model)
)
;-----------------------------------------
(define-method (digraph-models build-composition-tree)  (this ch)
                      (set! this-model this)
                      (set-root composition-tree this)
                      (set! children ch)
                      (for-each (lambda (child)
                                 (bi-add composition-tree child)
                                 (send child set-parent this)
                                )
                                 children)

)
(define-method (digraph-models set-ext-inp-coup )(child port-pairs)
                        (for-each (lambda (pair)
                                  (bi-insert-pair composition-tree             
                                               this-model child
                                                (car pair) (cdr pair)))
                                    port-pairs)
)
(define-method (digraph-models set-ext-out-coup) (child port-pairs)
                        (for-each (lambda (pair)
                                  (bi-insert-pair composition-tree
                                                child this-model
                                                (car pair) (cdr pair)))
                                    port-pairs)
)
(define-method (digraph-models set-inf-dig) (child-inf-list)
                                 (set! influence-digraph
                                        ($construct-int-coup children
                                           child-inf-list))

)

(define-method (digraph-models set-int-coup)  (ch1 ch2 port-pairs)
                        (for-each (lambda (pair)
                                  (insert-pair influence-digraph
                                     (find-edge (edges? influence-digraph)
                                                ch1 ch2)
                                                (car pair) (cdr pair)))
                                    port-pairs)
)



(define-method (digraph-models translate)(n1 n2 port-name)
     (if (or
       (equal? n1 this-model) (equal? n2 this-model))
                  (bi-associate composition-tree
                                (find-edge (bi-edges? composition-tree) n1 n2)
                                           port-name)
       (let (
            (edge (find-edge (edges? influence-digraph)
                                                        n1 n2))
            )
            (when edge (associate influence-digraph   edge
                                          port-name))
      )
    )
)


(define-method (digraph-models print-graph)()
(let* (
     (pair (cons this-model wind))
     (inf-dig influence-digraph)
     (tree composition-tree)
     (orig-size (window-get-size wind))
     (orig-pos (window-get-position wind))
     (edges (edges? inf-dig))
     (branches (bi-edges? tree))
     (len (min 20 (+ (length edges) (length branches) 7)))
     (priority-list priority-list)
     )
(window-reduce-stack pair)
(wpd pair)
(wss wind len 50)
(wc wind)
(display-window wind "composition-tree: " #\newline #\newline)
(for-each (lambda(edge)
    (display-window wind (send (link-left edge) get-name) " --> "
                         (send (link-right edge) get-name) " port-pairs: "
                         (link-port-pairs edge) #\newline)
         )
branches)
(display-window wind #\newline "influence-digraph: " #\newline )
(for-each (lambda(edge)
    (display-window wind (send (link-left edge) get-name) " --> "
                         (send (link-right edge) get-name) " port-pairs: "
                         (link-port-pairs edge) #\newline)
         )
edges)

(display-window wind #\newline "priority-list: " (map (lambda(e)(send e
                              get-name)) priority-list)  )
(wss wind (car orig-size)(cdr orig-size))
(wsp wind (car orig-pos)(cdr orig-pos))
))

(define-method (digraph-models set-selectfn) (fn)
     (set! selectfn fn)
)                                                            


;;;;;;;;;;;;;;;;;April 12, 1989 improvement of digraph-models;;;;;


;;;add

(define-method (digraph-models specify-children)(ch)
  (build-composition-tree (eval name user-initial-environment) ch)
  (set! influence-digraph (digraph))
  (add-nodes influence-digraph (digraph))
)

(define-method (digraph-models add-couple)(source dest port1 port2)
(cond
   ((and (equal? source this-model)(member dest children))
        (bi-insert-pair composition-tree source dest port1 port2))
   ((and (equal? dest this-model)(member source children))
        (bi-insert-pair composition-tree source dest  port1 port2))
   ((and (member source children)(member dest children))
         (add-edge influence-digraph source dest '())
         (insert-pair influence-digraph
                   (find-edge (edges? influence-digraph)
                          source dest) port1 port2))
   (else (writeln "The pair (" (send source get-name) ", "
                   (send dest get-name)") is not valid"))
))

;(make-pair atomic-models 'a)
;(make-pair atomic-models 'b)

;(make-pair digraph-models 'd)
;(send d specify-children (list a b))
;(send d add-couple d a 'in 'in)
;(send d add-couple b d 'out 'out)
;(send d add-couple a b 'out 'in)
;(send d add-couple a b 'send 'receive)
;(send d translate b a 'x) ;;no-longer goes into error editor

;;;;;;;;; 3/22/1989 ,6-29-89 , 7-20-89;;;;;;;;;;;;
(define-method (digraph-models make-new)(m-nm)
(let* (
     (tab (table))
     (class (eval (class-of-object (eval name))))
     (m (make-entity class m-nm))
     (co-nm  (string->symbol(string-append "C:"(symbol->string m-nm))))
     (co (make-entity co-ordinators co-nm))
     (new-children '())
     (priority-lst  priority-list)
    )
(attach co m)
(table-insert-pair tab this-model m)
(for-each (lambda(ch)
            (table-insert-pair tab ch (send ch make-new
               (gen-name name-ctr (base-name (send ch  get-name)))
             ;;  (gen-name name-ctr (send ch get-name))
            ))
           (set! new-children (append new-children
                     (list (table-look-up tab ch))))
          ) children)
(eval `(begin
(send ,m set-this-model ,m)
(send ,m set-composition-tree (copy-tree ,composition-tree ,tab))
(send ,m set-influence-digraph (copy-digraph ,influence-digraph ,tab))
(send ,m set-selectfn ,selectfn)
(send ,m set-priority (map (lambda(e) (table-look-up ,tab e)) ',priority-lst))
))
(eval `(define ,m-nm ,m) user-initial-environment)
(eval `(define ,co-nm ,co) user-initial-environment)
(send m set-children new-children)                           
(writeln "digraph model and co-ordinator made: " m-nm " " co-nm)
m
))


(define-method (digraph-models initial-state)()
(window-popup initialize-window)
(display-window initialize-window "Wish to initialize  " 
                   (get-name) " ? (y/n)" #\newline)
(if (equal? (read initialize-window) 'y)
   (for-each (lambda(child)
      (send child initial-state)) (get-children)
   ) ;;else
(initial-window this-model)
)                                           
(window-popup-delete initialize-window)  
)

;; for model window display

(define-method (digraph-models ninitial-state)()
  (window-popup initialize-window)
  (display-window initialize-window "Initialize or Display  "
                   (get-name) " ? (i/d/n)" #\newline)

  (case (read initialize-window)
   ( (i I)
     (for-each (lambda(child)
        (send child ninitial-state)) (get-children)
     )
   )
   ( (d D)
     (set-nw 'display #t)
     (hide-nw-children)
     (hide-nw-parent (eval name))
     (ninitial-state)
   )
   (else
     (when display-message-window (initial-window this-model))
   )
  ) ;; case

  (window-popup-delete initialize-window)
)



;;;;;;;;;;;;;;;;;;;;;;;;

(define-method (digraph-models adjust-composition-tree)()
   (let* (
           (tab (table))
           (comp-tree composition-tree)
           (old-root (show-root comp-tree))
         )
            (table-insert-pair tab old-root (eval name))
            (for-each (lambda(ch) (table-insert-pair tab ch ch)
            ) children)
         (set-composition-tree (copy-tree comp-tree tab))
   )
)

;;; working but very slow because of delete-methods-inherited ;;;
;(define-method (digraph-models make-class)(class-name)
;   (send this-model delete-methods-inherited digraph-models models models)
;   (eval `(make-digraph-class ,class-name (eval ,name)) 
;          user-initial-environment)
;   (send this-model resume-methods-deleted digraph-models models)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(define-method (digraph-models make-true-class)(class-name)
;   (send-if-handles (make-instance models) delete-methods)
;   (send-if-handles (make-instance coupled-models) delete-methods)
;   (send-if-handles this-model delete-methods)
;   (gc)
;   (eval `(make-digraph-class ,class-name (eval ,name)) 
;          user-initial-environment)
;   (send (make-instance models) resume-methods)
;   (send (make-instance coupled-models) resume-methods)
;   (send this-model resume-methods)
;)

;;; can't inherit from model-me.f??
(define-method (digraph-models make-class)(pseudo-class-name)
  (let (
     (psc (pseudo-class))
     )
(set-pseudo-class-nm psc pseudo-class-name)
(set-parent-class-nm psc (class-of-object (eval name)))
(set-originator psc (eval name))
   (eval `(define ,pseudo-class-name ,psc)
              user-initial-environment)
))

(macro make-digraph-class (lambda(e)
  (let (
       (class-name (cadr e))
       (m (caddr e))
       )
`(begin
    (define-class ,class-name
       (classvars)
       (instvars
          (this-model (send ,m get-this-model))
          (composition-tree (send ,m get-composition-tree))
          (children (send ,m get-children))
          (influence-digraph (send ,m get-influence-digraph))
          (selectfn (send ,m get-selectfn))
       )
      (mixins digraph-models)
    )
(eval '(compile-class ,class-name))
  )
)))


;;; return coupling as list of structure link ;;;

(define-method (digraph-models get-coupling)()
   (let (
           (edges (edges? (get-influence-digraph)))
           (branches (bi-edges? (get-composition-tree)))
           (ext-coup '())
           (int-coup '())
           (coupling '())  
        ) 
      (set! int-coup
         (map (lambda(edge)  
            (map (lambda(port-pair) 
                        (list (send (link-left edge) get-name)
                              (send (link-right edge) get-name)
                              port-pair)
                 ) (link-port-pairs edge))
             ) edges)
          )
      (set! ext-coup
         (map (lambda(edge)
            (map (lambda(port-pair) 
                        (list (send (link-left edge) get-name)
                              (send (link-right edge) get-name)
                              port-pair)
                  ) (link-port-pairs edge))
             ) branches)
       )
       (for-each (lambda(e) (set! coupling  (append  e coupling)))
          (clean (append int-coup ext-coup)))
       coupling
    )
)
       
(define-method (digraph-models isomorphic?)(m)
   (let (
          (corresp-tab (get-corresp-tab m))
          (isomorphic-coup? (isomorphic-coupling? m))
          (isomorphic-ch? '())
        )
      (if (not corresp-tab)
          corresp-tab
          (begin
             (set! isomorphic-ch? ($logic-and (map (lambda(ch) 
                (send ch isomorphic? (table-look-up corresp-tab ch))) children)
             ))
             (and isomorphic-coup? isomorphic-ch?)
          )
      )
   )
)


(define-method (digraph-models isomorphic-coupling?) (m)
   (let (
          (corresp-tab (get-table (get-corresp-tab m)))
          (corresp-name-tab (table))
        )
      (for-each (lambda(e)
         (table-insert-pair corresp-name-tab (send (car e) get-name)
                                             (send (cdr e) get-name))
         ) corresp-tab)
      (let rep (
                 (coup1 (get-coupling))
                 (coup2 (send m get-coupling))
               )
          (cond
             ( (not (equal? (length coup1) (length coup2)))
                  #!false)
             ( (and (null? coup1) (null? coup2))
                  #!true)
             ( else
                  (let* (
                          (next-coup1 (car coup1))
                          (m1   (car next-coup1))
                          (m2   (cadr next-coup1))
                          (m1-> (table-look-up corresp-name-tab m1))
                          (m2-> (table-look-up corresp-name-tab m2))
                          (next-coup2 ())
                        )
                      (set! next-coup2 (list m1-> m2-> (caddr next-coup1)))
                      (rep (cdr coup1) (remove next-coup2 coup2))
                   ))
           )
        )
   )
)
    
(define-method (digraph-models make-copy)(m-nm)
;(make-pair digraph-models m)
(newline)
(let* (
     (tab (table))
     (class (eval (class-of-object (eval name))))
     (m (make-entity class m-nm))
     (co-nm  (string->symbol(string-append "C:"(symbol->string m-nm))))
     (co (make-entity co-ordinators co-nm))        
     (m m)
     )        
(eval `(define ,m-nm ,m) user-initial-environment)                             
(eval `(define ,co-nm ,co) user-initial-environment)
(writeln "digraph model and co-ordinator made: " m-nm " " co-nm)
(attach co m)
(table-insert-pair tab this-model m)
(for-each (lambda(ch)
            (writeln "enter replacement for: " (send ch get-name))
            (table-insert-pair tab ch (eval(read)))
          ) children)
(eval `(begin
(send ,m set-this-model ,m)
(send ,m set-composition-tree (copy-tree ,composition-tree ,tab))
(send ,m set-children (leaves? (send ,m get-composition-tree)))
(send ,m set-influence-digraph (copy-digraph ,influence-digraph ,tab))
(send ,m set-selectfn ,selectfn)
(send ,m print-graph)
))))


(define-method (digraph-models resume-methods)()
   (reload "dimod-me.f")
)



;;----------------------------------------------------------
;;     external-message? :
;;
;;   Checks whether the current message is external to
;;   the model (out going message) or not.
;;----------------------------------------------------------





(define-method (digraph-models external-message?)(source-model port)
  (let ((response #t))
    (cond
     ( (pair? port)
       (when (or (member (eval (car port)) children)
               (let ((internal #f))
                 (for-each (lambda (c)
                             (when
                                (equal? (component-relation?  c (car port))
                                   'sub-component
                                )
                                (set! internal #t)
                             )
                           )
                           children
                 )
                 internal
               ) ;; let
                   ;; (car port) is destination model name
             )  ;; or
             (set! response #f)
       )
     )
     (else
        (for-each  (lambda (chd)
                           (when
                            (and (translate source-model chd port)
                              (not (translate source-model this-model port))
                            )
                               (set! response #f)
                           )
                   )
                   (get-children)
       ) ;; for-each
     ) ;; else
    ) ;; cond
    response
  )
)






;;; working but very slow because of eval of delete-method ;;;
;(define-method (digraph-models delete-methods)()
;   (let (
;          (methods-deleted '(get-coupling initial-state make-new make-copy
;                             print-graph translate set-int-coup set-inf-dig
;                             set-ext-out-coup set-ext-inp-coup get-receivers
;                             build-composition-tree get-influencees isomorphic?
;                             adjust-composition-tree   isomorphic-coupling?))
;        )
;      (for-each (lambda(method)
;         (if (member method (methods digraph-models))
;             (eval `(delete-method (digraph-models ,method))))
;      ) methods-deleted)
;   )
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-method (digraph-models delete-methods)()
   (delete-method (digraph-models get-coupling))
   (delete-method (digraph-models initial-state)) 
   (delete-method (digraph-models make-new)) 
   (delete-method (digraph-models make-copy))
   (delete-method (digraph-models print-graph)) 
   (delete-method (digraph-models translate)) 
   (delete-method (digraph-models set-int-coup)) 
   (delete-method (digraph-models set-inf-dig))
   (delete-method (digraph-models set-ext-out-coup)) 
   (delete-method (digraph-models set-ext-inp-coup)) 
   (delete-method (digraph-models get-receivers))
   (delete-method (digraph-models build-composition-tree))
   (delete-method (digraph-models get-influencees)) 
   (delete-method (digraph-models isomorphic?))  
   (delete-method (digraph-models isomorphic-coupling?)) 
   (delete-method (digraph-models adjust-composition-tree)) 
   (delete-method (digraph-models add-couple))
   (delete-method (digraph-models specify-children))
   (delete-method (digraph-models set-priority))
   (delete-method (digraph-models delete-methods))
)



