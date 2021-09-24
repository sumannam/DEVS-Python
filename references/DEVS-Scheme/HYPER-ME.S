
(define-method (hypercube-models get-influencees) (child)
   (when (equal?  num-infl #!unassigned)
      (back 'console)
      (error "number of influencees is not defined yet" name))
   (let* (
          (child-cell-pos (send child get-cell-position))
          (neighbors-cell-pos (hamming-dist-one child-cell-pos))
          (dimension (length child-cell-pos))
          (num-coup-neighbors (- dimension (get-num-infl)))
          (infl-cell-pos (list-tail neighbors-cell-pos num-coup-neighbors))
         )
      (clean (map (lambda(child) 
          (if (member (send child get-cell-position) infl-cell-pos) child))
          (reverse (get-children)))
      )
   )             
)

(define-method (hypercube-models get-receivers)()             
   (when (equal? ext-coup #!unassigned)
      (back 'console)
      (error"ext-coup type (origin-only or broadcast) is not defined yet" name))
   (if (equal? ext-coup 'origin-only)
       (list origin-cell)
       (get-children)
   )
)


(define-method (hypercube-models print-graph)()
(let* (
     (pair (cons this-model wind))
     (orig-size (window-get-size wind))
     (orig-pos (window-get-position wind))
     (children (get-children))
     (dim (round (log (length children) 2)))
     (len  (+ dim 9))
     )
(window-reduce-stack pair)
(wpd pair)
(wss wind len 50) 
(wc wind)
(display-window wind "  hypercube-model:" #\newline #\newline 
                     "cube-dimension: " dim #\newline)
(display-window wind "children: ")
(for-each (lambda(child)
    (display-window wind (send child get-name) " ")
    ) children)          
(display-window wind #\newline #\newline "external coupling: " (get-ext-coup))
(display-window wind #\newline #\newline 
             "# neighbors internally coupled for each cell: " (get-num-infl))
(display-window wind #\newline "out-int-coup table: " (get-table out-in-coup))
(wss wind (car orig-size)(cdr orig-size))
(wsp wind (car orig-pos)(cdr orig-pos))
))



(define-method (hypercube-models make-new)(new-inst-name)
   (let* ( 
          (models-class (eval (class-of-object (eval name))))
          (hc-inst-nm (gen-mem-name new-inst-name))
          (hc-inst-name (gen-name name-ctr (base-name hc-inst-nm)))
          (m (make-entity models-class hc-inst-name))
          (co-nm  (symbol-append '|C:| hc-inst-name))
          (co (make-entity co-ordinators co-nm))        
          (old-children (get-children))
          (old-init-cell (get-init-cell))
          (#-children (length old-children))
          (dim-children (round (log #-children 2)))
          (mem-name (send (car old-children) get-name))
          (base-nm (base-name mem-name))
          (class-name (gen-name name-ctr (symbol-append base-nm 's)))
          (originator (get-originator (eval class)))
        ) 
      (attach co m)
      (eval
         `(begin
             (send ,old-init-cell make-class ',class-name) 
             (send ,m set-this-model ,m)
             (send ,m set-out-in-coup (copy-table ,out-in-coup))
             (send ,m set-class ,class-name)
             (send ,m set-ext-coup  ',ext-coup)
             (send ,m set-num-infl ,num-infl)
             (send ,m make-init-cell)
             (send ,m make-members ',base-nm  ,dim-children)
             (message-mode-off)  
            (send (send ,m get-init-cell) copy-state ,old-init-cell)         
             (message-mode-on)
             (define ,hc-inst-name ,m) 
             (define ,co-nm ,co) 
          ) user-initial-environment
       )
      (set-originator (send m get-class) originator)
      (writeln "hypercube model and co-ordinator made: "
                hc-inst-name  " " co-nm)
      m
   ) ;let
)

(define-method (hypercube-models make-members) (nm n)
   (make-kernel-members nm (expt 2 n))
   (set-allcell-positions)
   (get-children)            
)

;;; working but very slow because of delete-methods-inherited ;;;;
;(define-method (hypercube-models make-class)(class-name)
;   (send this-model delete-methods-inherited hypercube-models models)
;   (eval `(make-hypercube-class ,class-name (eval ,name)) 
;                              user-initial-environment)
;   (send this-model resume-methods-deleted hypercube-models models)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(define-method (hypercube-models make-class)(class-name)
;   (send-if-handles (make-instance models) delete-methods)
;   (send-if-handles (make-instance coupled-models) delete-methods)
;   (send-if-handles (make-instance kernel-models) delete-methods)
;   (send-if-handles this-model delete-methods)
;   (gc)
;   (eval `(make-hypercube-class ,class-name (eval ,name)) 
;                              user-initial-environment)
;   (send (make-instance models) resume-methods)
;   (send (make-instance coupled-models) resume-methods)
;   (send (make-instance kernel-models) resume-methods)
;   (send this-model resume-methods)
;)

(macro make-hypercube-class (lambda(e)
  (let (
       (class-name (cadr e))
       (m (caddr e))
       )
`(begin
    (define-class ,class-name
       (classvars)
       (instvars
          (class (send ,m get-class))
          (ext-coup (send ,m get-ext-coup))
          (init-cell (send ,m get-init-cell))
          (num-infl (send ,m get-num-infl))
          (out-in-coup (send ,m get-out-in-coup))
       )
      (mixins hypercube-models)
    )
(eval '(compile-class ,class-name))
  )
)))


(define-method (hypercube-models set-allcell-positions)()
   (let* (
          (children (reverse (get-children)))
          (dimension (round (log (length children) 2)))
          (cnt 0)
        )
      (for-each (lambda (child)
          (send child set-cell-position (decimal->binary cnt dimension))
          (display-window 'console "cell-position of a "
          (subsymbol (send child spec-class-of-object) 0 
                     (-1+ (symbol-length (send child spec-class-of-object))))
                "  " (send child get-name)" is "(decimal->binary cnt dimension) 
                #\newline)
          (if (equal? cnt 0) (set! origin-cell child))
              (set! cnt (1+ cnt))
          ) children
      )
   )
)

(define-method (hypercube-models isomorphic-coupling?) (m)
   (and
      (isomorphic-tab? (get-out-in-coup) (send m get-out-in-coup))
      (equal? (get-ext-coup) (send m get-ext-coup))
      (equal? (get-num-infl) (send m get-num-infl))
   )
)


(define-method (hypercube-models resume-methods)()
   (reload "hyper-me.f")
)

;;; working but very slow because of eval of delete-method ;;;;
;(define-method (hypercube-models delete-methods)()
;   (let (
;          (methods-deleted '(set-allcell-positions make-members make-new
;                             init-new print-graph translate
;                             get-receivers get-influencees 
;                             isomorphic-coupling?))
;        )
;      (for-each (lambda(method)
;         (if (member method (methods hypercube-models))
;             (eval `(delete-method (hypercube-models ,method))))
;      ) methods-deleted)
;   )
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-method (hypercube-models delete-methods)()
   (delete-method (hypercube-models set-allcell-positions))
   (delete-method (hypercube-models make-members))
   (delete-method (hypercube-models make-new))
   (delete-method (hypercube-models init-new)) 
   (delete-method (hypercube-models print-graph)) 
   (delete-method (hypercube-models translate))
   (delete-method (hypercube-models get-receivers)) 
   (delete-method (hypercube-models get-influencees)) 
   (delete-method (hypercube-models ent->model))
   (delete-method (hypercube-models complete-translation))
   (delete-method (hypercube-models isomorphic-coupling?)) 
   (delete-method (hypercube-models delete-methods))
)

;;
;;
;;  (make-hypercube a)  ;a is an existing subclass of entities
;;         ;makes |hy-a| a coupled model AS w/ hypercube coupling

(macro make-hypercube (lambda (e)
  (let* (
       (class (cadr e))     ;on which hypercube is based
       (class-name (symbol->string class))
       (hypercube (string->symbol (string-append  "hy-" class-name)))
       (co-ord (string->symbol (string-append "C:hy-" class-name)))
      )
`(begin
   (mk-ent hypercube-models ,hypercube)(newline)
   (send ,hypercube set-class ,class)
   (send ,hypercube set-this-model ,hypercube)
   (mk-ent co-ordinators ,co-ord)
   (send ,hypercube make-init-cell)
   (attach ,co-ord ,hypercube)
))))






(define-method (hypercube-models add-port-pair)  ;;;influencee of origin
                   (influencee port-name1 port-name2)
   (table-insert-pair out-in-coup (list influencee port-name1) port-name2)
)


(define-method (hypercube-models translate)(n1 n2 port-name)
   (if (or (equal? n1 this-model) (equal? n2 this-model))
       (if (equal? ext-coup 'origin-only)
           (if (or (member n1 (get-receivers)) (member n2 (get-receivers)))
               port-name
           ) 
           port-name
       )
       (if (member n2 (get-influencees n1))
              (let* (
                   (cpos1 (send n1 get-cell-position))
                   (cpos2 (send n2 get-cell-position))
                   (influencee  (map (lambda(co-or) 
                                      (begin0
                                         (modulo (+ (car cpos2) co-or) 2)
                                      (set! cpos2 (cdr cpos2))
                                      )
                                     ) cpos1))
                   )              
           (table-look-up out-in-coup (list influencee port-name))
           )
       ) 
   )
)              


(define-method (hypercube-models init-new)()
(window-popup initialize-window)
   (let* (
           (nm '())
           (dim 0)
           (old-children (get-children))
           (new-init-cell '())
         )
   (display-window initialize-window "init-new for " (get-name)
             #\newline "enter basic name of member and dimension desired ")
   (set! nm (read initialize-window))
   (set! dim (read initialize-window))
          (display-window initialize-window
                      "choose ext-coup-type of : (origin-only  broadcast) ")
          (set! ext-coup (check-and-accept (read initialize-window)
                            '(origin-only broadcast) initialize-window))
          (display-window initialize-window
                         "choose num of influencees : [0 .. " dim "] ")
          (set! num-infl (read initialize-window))
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
   (make-members nm dim)
   this-model    
 ) ;let
)

;;;;; called from construct-kernel in entrans.s

(define-method (hypercube-models ent->model)(mult-nm . lst)
  (let (
       (children-ms (cadr lst))
       )
       (eval `(make-hypercube ,mult-nm) user-initial-environment)
       (set-pseudo-class-lst (eval mult-nm) children-ms)
))

(define-method (hypercube-models complete-translation)(out-in-couple . lst)
         (let* (
                (int-coup (clean (map (lambda(e)
                                   (if (not (equal? 'ext-coup (car e))) e))
                                 out-in-couple)))
                (ext-coup (car (clean (map (lambda(e)
                                        (if (equal? 'ext-coup (car e)) e))
                                 out-in-couple))))
                (ext-inp-coup (cadr ext-coup))
                (ext-out-coup (caddr ext-coup))
                (en (cadr lst))
                (mult-nm (car lst))
              )

           (for-each (lambda(coup)
              (add-port-pair (car coup) (cadr coup) (caddr coup))
           ) int-coup)
))
;;;;;;;;;;;;;;;;;;

