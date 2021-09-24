;; broad-me.s


(define-method (broadcast-models get-influencees) (child)
(remove child (get-children))
)

(define-method (broadcast-models get-receivers)()
(get-children)
)

(define-method (broadcast-models translate)(n1 n2 port-name)
     (if (or
       (equal? n1 this-model) (equal? n2 this-model))
                                           port-name
       (table-look-up out-in-coup port-name)
))


(define-method (broadcast-models print-graph)()
(let* (
     (pair (cons this-model wind))
     (orig-size (window-get-size wind))
     (orig-pos (window-get-position wind))
     (children (get-children))
     (len  (+ (length children) 5))
     )
(window-reduce-stack pair)
(wpd pair)
(wss wind len 50)
(wc wind)
(display-window wind "  broadcast-model:"  #\newline #\newline "children: ")
(for-each (lambda(child)
    (display-window wind (send child get-name) " ")
    ) children)
(display-window wind #\newline #\newline "out-int-coup table: "
               (get-table out-in-coup))
(wss wind (car orig-size)(cdr orig-size))
(wsp wind (car orig-pos)(cdr orig-pos))
))


(define-method (broadcast-models init-new)()
(window-popup initialize-window)
(display-window initialize-window "init-new for " (get-name) )

(let* (
       (nm-or-list '())
       (list-of-model-names '())
       (nm '())
       (num '())
       (new-init-cell '())
      )
(if (closure? (get-originator (eval class)))(make-pruned)
    (begin
     (display-window initialize-window
         #\newline "enter basic name of component and number desired "
         #\newline "or enter a list of models for components ")
     (set! nm-or-list  (read initialize-window))
     (set! list-of-model-names (when (pair? nm-or-list) nm-or-list))
     (set! nm (when (symbol? nm-or-list) nm-or-list))
     (set! num  (when nm (read initialize-window)))
     (cond
      (list-of-model-names
       (set-pseudo-class-lst class '())
       (for-each (lambda(el)(let (
                             (model (retrieve-special el))
                             (new-nm '())
                             )
                             (cond
                                (model (set! new-nm (gen-name name-ctr el))
                                    (add-instance (eval class)
                                      (send (eval el) make-new new-nm))
                                )
                                (else (display-window initialize-window
                                         "model does not exist->  " el))
                             )
                       )
              ) list-of-model-names)

       )
       (nm   (set-pseudo-class-lst (eval class) '())
         (make-members nm num))
      )
    )
)
     (display-window initialize-window  #\newline
                         "enter out-in-coup table" #\newline
                         "as list of output-input port pairs ")
       (set-table out-in-coup '())
       (for-each (lambda(pair)(add-port-pair (car pair)(cadr pair)))
                      (read initialize-window))

 
   (set! new-init-cell (send-if-handles init-cell init-new))
   (when (not (null? new-init-cell))
      (send new-init-cell set-name (send init-cell get-name))
      (set-init-cell new-init-cell)
      (send-if-handles new-init-cell set-this-model new-init-cell)
   )
   (tell-atomic-children-their-names)
   this-model
))



(define-method (broadcast-models make-new)(new-inst-name)
   (let* ( 
          (models-class (eval (class-of-object (eval name))))
          (br-inst-nm (gen-mem-name new-inst-name))
          (br-inst-name (gen-name name-ctr (base-name br-inst-nm)))
          (m (make-entity models-class br-inst-name))
          (co-nm  (symbol-append '|C:| br-inst-name))
          (co (make-entity co-ordinators co-nm))        
          (old-children (get-children))                          
          (old-init-cell (get-init-cell))
          (#-children (length old-children))
          (mem-names (map (lambda(ch) (send ch get-name)) old-children))
          (mem-name (car mem-names))
         ; (mem-name (send (car old-children) get-name))
          (base-nm (base-name mem-name))
          (class-name (gen-name name-ctr (symbol-append base-nm 's)))
          (originator (get-originator (eval class)))
         ) 
      (attach co m)
      (eval
        `(begin
            (send ,old-init-cell make-class ',class-name)
            (send ,m set-this-model ,m)
            (send ,m set-out-in-coup (copy-table,out-in-coup))
            (send ,m set-class ,class-name)
            (send ,m make-init-cell)
            (send ,m make-true-members ',mem-names)
         ;  (send ,m make-members ',base-nm ,#-children)
            (message-mode-off)
            (send (send ,m get-init-cell) copy-state ,old-init-cell)         
            (message-mode-on)
            (define ,br-inst-name ,m) 
            (define ,co-nm ,co) 
         ) user-initial-environment
      )
      (set-originator (send m get-class) originator)
      (writeln "broadcast model and co-ordinator made: "
                br-inst-name  " " co-nm)
      m
   ) ;let
)

(define-method (broadcast-models make-members) (nm n)
   (make-kernel-members nm n)
   (get-children)
)


;;;;;;;;;;;;;; called from construct-kernel in entrans.s


(define-method (broadcast-models ent->model)(mult-nm . lst)
  (let (
       (children-ms (cadr lst))
       )
       (eval `(make-broadcast ,mult-nm) user-initial-environment)
       (set-pseudo-class-lst (eval mult-nm) children-ms)
))

(define-method (broadcast-models complete-translation)(out-in-couple . lst)
       (for-each (lambda(coup)(add-port-pair
            (car coup) (cadr coup))) out-in-couple)
)
;;;;;;;;;;;;;;;;;;


;;;; working but very slow because of delete-methods-inherited ;;;
;(define-method (broadcast-models make-class)(class-name)
;   (send this-model delete-methods-inherited broadcast-models models)
;   (eval `(make-broadcast-class ,class-name (eval ,name)) 
;                              user-initial-environment)
;   (send this-model resume-methods-deleted broadcast-models models)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(define-method (broadcast-models make-class)(class-name)
;   (send-if-handles this-model delete-methods)
;   (send-if-handles (make-instance kernel-models) delete-methods)
;   (send-if-handles (make-instance coupled-models) delete-methods)
;   (send-if-handles (make-instance models) delete-methods)
;   (gc)
;   (eval `(make-broadcast-class ,class-name (eval ,name)) 
;                              user-initial-environment)
;   (send (make-instance models) resume-methods)
;   (send (make-instance coupled-models) resume-methods)
;   (send (make-instance kernel-models) resume-methods)
;   (send this-model resume-methods)
;)

(macro make-broadcast-class (lambda(e)
  (let (
       (class-name (cadr e))
       (m (caddr e))
       )
`(begin
    (define-class ,class-name
       (classvars)
       (instvars
          (class (send ,m get-class))
          (out-in-coup (send ,m get-out-in-coup))
          (init-cell (send ,m get-init-cell))
       )
      (mixins broadcast-models)
    )
(eval '(compile-class ,class-name))
  )
)))

(define-method (broadcast-models isomorphic-coupling?) (m)
  (isomorphic-tab? (get-out-in-coup) (send m get-out-in-coup))
)

(define-method (broadcast-models resume-methods)()
   (reload "broad-me.f")
)

;;;; working but very slow because of eval of delete-method ;;;
;(define-method (broadcast-models delete-methods)()
;   (let (
;          (methods-deleted '(make-members make-new init-new print-graph
;                             translate get-receivers get-influencees
;                             isomorphic-coupling?))
;        )
;      (for-each (lambda(method)
;         (if (member method (methods broadcast-models))
;             (eval `(delete-method (broadcast-models ,method))))
;      ) methods-deleted)
;   )
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define-method (broadcast-models delete-methods)()
   (delete-method (broadcast-models make-members))
   (delete-method (broadcast-models make-new))
   (delete-method (broadcast-models init-new ))
   (delete-method (broadcast-models print-graph))
   (delete-method (broadcast-models translate)) 
   (delete-method (broadcast-models get-receivers ))
   (delete-method (broadcast-models get-influencees))
   (delete-method (broadcast-models ent->model))
   (delete-method (broadcast-models complete-translation))
   (delete-method (broadcast-models isomorphic-coupling?))
   (delete-method (broadcast-models delete-methods))
)
;
;
;(make-broadcast a)  ;a is an existing subclass of entities
;                 makes |br-A| a coupled model AS w/ broadcast coupling


(macro make-broadcast (lambda (e)
  (let* (
          (class (cadr e))     ;on which broadcast is based
          (class-name (symbol->string class))
          (broadcast (string->symbol (string-append  "br-" class-name)))
          (co-ord (string->symbol (string-append "C:br-" class-name)))
        )
`(begin
    (mk-ent broadcast-models ,broadcast) (newline)
    (send ,broadcast set-class ,class)
    (send ,broadcast set-this-model ,broadcast)
    (mk-ent co-ordinators ,co-ord)
    (send ,broadcast make-init-cell)
    (attach ,co-ord ,broadcast)
  ) 
)))













