
; influencees of each child in the tree-models can be one or multiple of :
;             parent
;             all-children
;             leftmost-child
;             rightmost-child
;             specified-children, ie. first-child, second-child
;             right-sibling  (right-cousin)
;             left-sibling   (left-cousin)
;             random !!! not used now !!!
; Influencees can be specified using method add-port-pair.
;   ex: (send tree-m add-port-pair 'parent 'out 'in)
;       (send tree-m add-port-pair 'right-sibling 'done 'ready)
;       (send tree-m add-port-pair 'second-child 'out1 'in1)
;       (send tree-m add-port-pair 'third-child 'out2 'in2)
; Influencees can be computed using out-in-coup table


(define-method (tree-models def-infl)()
(for-each (lambda(ch)(eval `(define influencees 'u) ch))
                     (get-children))
)

(define-method(tree-models compile-influencees)()
(for-each (lambda(ch)(compute-influencees ch))(get-children))
)


(define-method (tree-models compute-influencees) (child)
(let (
      (inf
       (clean (append
           (list (parent-of child))
           (children-of child)
           (list (right-sibling-of child))
           (list (left-sibling-of child))
           (list (left-cousin-of child))
           (list (right-cousin-of child))
       ))
      )
     )
(if (eval `(equal? influencees 'u) child)
     (begin (eval `(define influencees ',inf) child) inf)
     (access influencees child)
)
))

(define-method (tree-models get-influencees)(child)
(access influencees child)
)




;;;;too slow

;(define-method (tree-models get-influencees) (child)
;   (let rep (
;             (inf-type-lst (map (lambda(e) (caar e)) (get-table out-in-coup)))
;             (inf-lst '())
;            )
;      (if (not inf-type-lst)
;         (clean inf-lst)
;         (begin
;           (case (car inf-type-lst)
;             ('parent
;               (set! inf-lst (union2 inf-lst (list (parent-of child)))))
;             ('all-children
;               (set! inf-lst (union2 inf-lst (children-of child))))
;             ('leftmost-child
;               (set! inf-lst (union2 inf-lst (list (leftmost-child-of child)))))
;             ('rightmost-child
;               (set! inf-lst (union2 inf-lst (list (rightmost-child-of child)))))
;             ('right-sibling
;               (set! inf-lst (union2 inf-lst (list (right-sibling-of child)))))
;             ('left-sibling
;               (set! inf-lst (union2 inf-lst (list (left-sibling-of child)))))
;           )
;           (rep (cdr inf-type-lst) inf-lst)
;         )
;      )
;   )
;)

(define-method (tree-models get-receivers)()             
   (case ext-inp-coup
     ('root-only  (list root-child))
     ('all-leftmost leftmost-child-lst)
     ('all-rightmost rightmost-child-lst)
     ('all-leaves leaf-child-lst)
     (else 
       (back 'console)
       (error "ext-inp-coup should be one of 
              {root-only, all-leftmost, all-rightmost, all-leaves}")) 
   )
)

(define-method (tree-models print-graph)()
(let* (
     (pair (cons this-model wind))
     (orig-size (window-get-size wind))
     (orig-pos (window-get-position wind))
     (children (get-children))
     (len (+ (length children) 5))
     )
(window-reduce-stack pair)
(wpd pair)
(wss wind len 50) 
(wc wind)
(display-window wind "  tree-model:" #\newline #\newline 
                     "(levels branches): " (list levels branches) #\newline)
(display-window wind "children: ")
(for-each (lambda(child)
    (display-window wind (send child get-name) " ")
    ) children)          
(display-window wind #\newline #\newline "external input coupling: " 
    (get-ext-inp-coup))
(display-window wind #\newline "external output coupling: " 
    (get-ext-out-coup))
(display-window wind #\newline "out-int-coup table: " (get-table out-in-coup))
(wss wind (car orig-size)(cdr orig-size))
(wsp wind (car orig-pos)(cdr orig-pos))
))

(define-method (tree-models make-members) (nm levels branches)
   (when (bi-nodes? children-tree) 
      (set-children-tree (bi-tree)))
   (set-levels levels)
   (set-branches branches)
   (make-kernel-members nm 
       (if (= branches 1)
           (1+ levels)
           (1+ ( / (* branches (-1+ (expt branches levels))) (-1+ branches)))))
   (build-children-tree)
   (get-children)            
)

(define-method (tree-models build-children-tree)()
   (let* (
           (children (get-children))
           (root (car children))
         )
      (set-root-child root)
      (set-leftmost-child-lst (list root))
      (set-rightmost-child-lst (list root))
      (set-leaf-child-lst '())
      (send root set-cell-position '(0 0))
      (set-root children-tree root)
      (let rep1 (
                 (ch-left (cdr children))
                 (num-lev 1)
                 (num-ch 0)
                )
         (when ch-left
            (for-each (lambda(leaf)
               (bi-set-current children-tree leaf)
               (let rep2 ((num-br 0))
                   (when (<? num-br branches)
                      (bi-add children-tree (car ch-left))
                      (send (car ch-left) set-cell-position 
                         (list num-lev num-ch))
                      (if (= num-ch 0)
                          (set! leftmost-child-lst
                            (append leftmost-child-lst (list (car ch-left)))))
                      (if (= num-ch (-1+ (expt branches num-lev)))
                          (set! rightmost-child-lst
                            (append rightmost-child-lst (list (car ch-left)))))
                      (If (= num-lev levels)
                          (set! leaf-child-lst
                             (append leaf-child-lst (list (car ch-left)))))
                      (set! num-ch (1+ num-ch))
                      (set! ch-left (cdr ch-left))
                      (rep2 (1+ num-br))
                   )
                )
            ) (reverse (leaves? children-tree)))
            (rep1 ch-left (1+ num-lev) 0)
         )
       )
    )
)

(define-method (tree-models print-children-tree) ()
  (if (bi-nodes? children-tree)
      (begin
         (display-window
             'console 
             (send root-child get-name) 
             (make-string 5 #\space)
             (make-string (car (send root-child get-cell-position)) #\space) 
             (send root-child get-cell-position) #\newline)
         (let rep (
                    (chs (children-of root-child))
                  )
             (when chs
               (display-window 
                 'console 
                 (make-string (car (send (car chs) get-cell-position)) #\-)
                 (send (car chs) get-name)
                 (make-string 
                    ( - (+ 5 (print-length (send root-child get-name)))
                        (print-length (send (car chs) get-name)))
                    #\space)
                 (make-string (car (send (car chs) get-cell-position)) #\space) 
                 (send (car chs) get-cell-position)  #\newline)
             (for-each (lambda(e) (rep (list e))) (children-of (car chs)))
             (rep (cdr chs))
           )
        )
     )
     (writeln "Children tree is empty")
    )
)

(define-method (tree-models level-of) (child)
   (car (send child get-cell-position))
)                           



(define-method (tree-models column-of)(child)
(cadr (send child get-cell-position))
)

(define-method (tree-models parent-of) (child)
   (if (equal? root-child child)
       '()
       (begin
          (bi-set-current children-tree child)
          (let rep (
                    (succ (bi-successors? children-tree))
                    (child-level (car (send child get-cell-position)))
                   )
             (if (< (car (send (car succ) get-cell-position)) child-level) 
                (car succ)
                (rep (cdr succ) child-level)
             )
          )
      )
   )
)

(define-method (tree-models children-of) (child)
   (bi-set-current children-tree child)
   (if (equal? root-child child)
       (bi-successors? children-tree)
       (remove (parent-of child) (bi-successors? children-tree))
   )
)

(define-method (tree-models leftmost-child-of) (child)
   (car (children-of child))
)

(define-method (tree-models rightmost-child-of) (child)
   (car (reverse (children-of child)))
)

(define-method (tree-models right-sibling-of) (child)
   (if (equal? child root-child)
       '()
      (let rep (
                (child-x-pos (cadr (send child get-cell-position)))
                (siblings (children-of (parent-of child)))
               )
         (cond
           ((not siblings) 
              '())
           ((= (cadr (send (car siblings) get-cell-position)) 
                     (1+ child-x-pos)) 
              (car siblings))
           (else (rep child-x-pos (cdr siblings)))
         )
      )
   )
)

(define-method (tree-models left-sibling-of) (child)
   (if (equal? child root-child)
       '()
      (let rep (
                 (child-x-pos (cadr (send child get-cell-position)))
                 (siblings (children-of (parent-of child)))
               )
         (cond
           ((not siblings) 
              '())
           ((= (cadr (send (car siblings) get-cell-position))
                     (-1+ child-x-pos)) 
              (car siblings))
           (else (rep child-x-pos (cdr siblings)))
         )
      )
   )
)

(define-method (tree-models right-cousin-of) (child)
   (cond
     ((equal? child root-child)
        '())
     ((right-sibling-of child) '())
;       (writeln "This child " (send child get-name)
;               " is not a rightmost child"))
     ((= (-1+ (expt branches (car (send child get-cell-position))))
              (cadr (send child get-cell-position)))
       (list-ref leftmost-child-lst (car (send child get-cell-position))))
     (else
       (send this-model leftmost-child-of
          (send this-model right-sibling-of
              (send this-model parent-of child))))
   )
)

(define-method (tree-models left-cousin-of) (child)
   (cond
     ((equal? child root-child)
       '())
     ((left-sibling-of child) '())
;       (writeln "This child " (send child get-name)
;                " is not a leftmost child"))
     ((= 0 (cadr (send child get-cell-position)))
       (list-ref rightmost-child-lst (car (send child get-cell-position))))
     (else
       (send this-model rightmost-child-of
          (send this-model left-sibling-of
              (send this-model parent-of child))))
   )
)

(define-method (tree-models add-port-pair) (influencee port-name1 port-name2)
  (table-insert-pair out-in-coup (list influencee port-name1) port-name2)
)

(define-method (tree-models translate)(n1 n2 port-name)
   (cond
     ((equal? n1 this-model)                  ;; external input
        port-name)
     ((equal? n2 this-model)                  ;; external output
        (cond
          ((and (equal? ext-out-coup 'root-only)
                (equal? n1 root-child))
              port-name)
          ((and (equal? ext-out-coup 'all-leftmost)
                (member n1 leftmost-child-lst))
              port-name)
          ((and (equal? ext-out-coup 'all-rightmost)
                (member n1 rightmost-child-lst))
              port-name)
          ((and (equal? ext-out-coup 'all-leaves)
                (member n1 leaf-child-lst))
              port-name)
          (else
              '())))
     (else  (let (
              (port '())
                 )
              (set! port
                (table-look-up out-in-coup
                 (list
                   (cond
                     ((equal? n2 (eval `(parent-of ,n1) this-model)) 'parent)
                     ((equal? n2 (eval `(leftmost-child-of ,n1) this-model)) 'leftmost-child)
                     ((equal? n2 (eval `(rightmost-child-of ,n1) this-model)) 'rightmost-child)

                     ((equal? n2 (eval `(right-sibling-of ,n1)this-model)) 'right-sibling)
                     ((equal? n2 (eval `(left-sibling-of ,n1)this-model)) 'left-sibling)
                     ((equal? n2 (eval `(left-cousin-of ,n1)this-model)) 'left-cousin)
                     ((equal? n2 (eval `(right-cousin-of ,n1)this-model)) 'right-cousin)
                   )
                    port-name)
                  );;table
               );;set
              (if port port
              (when  (member n2 (children-of n1))
                   (table-look-up out-in-coup  (list 'all-children port-name))
              );;when
            );;if
          );;let
      );;else
    );;cond

);;def

(define-method (tree-models make-new)(new-inst-name)
   (let* (
          (models-class (eval (class-of-object (eval name))))
          (tr-inst-nm (gen-mem-name new-inst-name))
          (tr-inst-name (gen-name name-ctr (base-name tr-inst-nm)))
          (m (make-entity models-class tr-inst-name))
          (co-nm  (symbol-append '|C:| tr-inst-name))
          (co (make-entity co-ordinators co-nm))
          (old-children (get-children))
          (old-init-cell (get-init-cell))
          (lev levels)
          (br branches)
          (mem-name (send (car old-children) get-name))
          (base-nm (base-name mem-name))
          (class-name (gen-name name-ctr (symbol-append base-nm 's)))
        )
      (attach co m)
      (eval
         `(begin
             (send ,old-init-cell make-class ',class-name) 
             (send ,m set-this-model ,m)
             (send ,m set-class ,class-name)
             (send ,m set-ext-inp-coup  ',ext-inp-coup)
             (send ,m set-ext-out-coup  ',ext-out-coup)
             (send ,m set-out-in-coup (copy-table ,out-in-coup))
             (send ,m make-init-cell)
             (send ,m make-members ',base-nm ,lev ,br)
             (message-mode-off)  
             (send (send ,m get-init-cell) copy-state ,old-init-cell)         
             (message-mode-on)
             (define ,tr-inst-name ,m) 
             (define ,co-nm ,co)
          ) user-initial-environment
       )
      (writeln "tree model and co-ordinator made: "
                tr-inst-name  " " co-nm)
      m
   ) ;let
)
(define-method (tree-models init-new)()
(window-popup initialize-window)
   (let* (
           (nm '())
           (levels 0)
           (branches 0)
           (old-children (get-children))
           (new-init-cell '())
         )
   (display-window initialize-window "init-new for " (get-name)
             #\newline "enter basic name of member, levels,"
             "and branches desired as list of triples")
   (let ((red (read initialize-window)))
      (set! nm (car red))
      (set! levels (cadr red))
      (set! branches (caddr red))
   )
   (display-window initialize-window
            "choose ext-inp-coup type of : "
            "(root-only all-leftmost all-rightmost all-leaves) ")
   (set-ext-inp-coup (check-and-accept (read initialize-window)
       '(root-only all-leftmost all-rightmost all-leaves) initialize-window))
   (display-window initialize-window
            "choose ext-out-coup type of : "
            "(root-only all-leftmost all-rightmost all-leaves) ")
   (set-ext-out-coup (check-and-accept (read initialize-window)
       '(root-only all-leftmost all-rightmost all-leaves) initialize-window))
   (display-window initialize-window  #\newline
                         "enter out-in-coup table" #\newline
                         "as list of influencee-output-input port triples ")
   (set-table out-in-coup '())
   (for-each (lambda(triple)(add-port-pair
                         (car triple)(cadr triple)(caddr triple)))
                      (read initialize-window))
   (set-pseudo-class-lst (eval class) '())
   (set! new-init-cell (send-if-handles init-cell init-new))
   (when (not (null? new-init-cell))
      (set-init-cell new-init-cell)
      (send new-init-cell set-name (send init-cell get-name))
      (send-if-handles new-init-cell set-this-model new-init-cell)
   )
   (make-members nm levels branches)
   this-model    
 ) ;let
)

(define-method (tree-models make-ps-class)(pseudo-class-name)
(when (member make-class (all-methods tree-models))
   (delete-method (tree-models make-class))
)
(let (
     (psc (pseudo-class))
     )
(set-pseudo-class-nm psc pseudo-class-name)
(set-parent-class-nm psc (class-of-object this-model))
(set-originator psc this-model)
   (eval `(define ,pseudo-class-name ,psc)
              user-initial-environment)
))

(define-method (tree-models make-class)(cl)
(make-ps-class cl)
)

(define-method (tree-models isomorphic-coupling?) (m)
   (and
      (isomorphic-tab? (get-out-in-coup) (send m get-out-in-coup))
      (equal? (get-ext-inp-coup) (send m get-ext-inp-coup))
      (equal? (get-ext-out-coup) (send m get-ext-out-coup))
   )
)
          
;
;(make-tree a)  ;a is an existing subclass of entities
;                 makes |tr-A| a coupled model AS w/ tree coupling


(macro make-tree (lambda (e)
  (let* (
          (class (cadr e))     ;on which tree is based
          (class-name (symbol->string class))
          (tree (string->symbol (string-append  "tr-" class-name)))
          (co-ord (string->symbol (string-append "C:tr-" class-name)))
        )
`(begin
    (mk-ent tree-models ,tree) (newline)
    (send ,tree set-class ,class)
    (send ,tree set-this-model ,tree)
    (mk-ent co-ordinators ,co-ord)
    (send ,tree make-init-cell)
    (attach ,co-ord ,tree)
  ) 
)))


