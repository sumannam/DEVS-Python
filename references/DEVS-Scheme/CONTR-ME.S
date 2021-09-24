;; contr-me.s

(mk-st 'atomic-models '(influencees name)) 
                     ;;; guarantees that influencees and name always appear 
                     ;;; in these positions used in init-new


(define-method (controlled-models tell-controller-its-influencees)()
   (eval `(set! (state-influencees (send ,controller get-s))
             (show-pseudo-class (eval ,class))
)))

(define-method (controlled-models get-children) ()
(append (get-pseudo-class-lst (eval class))  (list controller))
)



(define-method (controlled-models get-influencees) (child)
(if
 (equal? child controller)   ;;;controller sends to  specified subset
     (map (lambda(nm)(eval nm user-initial-environment))
                (state-influencees (send controller get-s)))
   (list controller)  ;;other children send to controller
))


(define-method (controlled-models get-receivers)()
(list controller)   ;;from outside send only to controller
)

(define-method (controlled-models translate)(n1 n2 port-name)
(cond
  ( (and (equal? n1 this-model) (equal? n2 controller)) port-name)
           ;;;external input
  ( (and (equal? n2 this-model) (equal? n1 controller)) port-name)
           ;;;external output
  ( (and (member n1 (get-pseudo-class-lst (eval class)))
           (equal? n2 controller)) port-name)
           ;;;controllees to controller
  ( (and (member n2  (get-influencees controller))
           (equal? n1 controller))
       (let (
            (out-port (table-look-up out-in-coup port-name) )
            )
         (if out-port out-port port-name)
        )
  )    
            ;;;controller to controllees: if in out-in-coup use, else identity
))


(define-method (controlled-models print-graph)()
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
(display-window wind "  controlled-model:"  #\newline #\newline "children: ")
(for-each (lambda(child)
    (display-window wind (send child get-name) " ")
    ) children)
(display-window wind #\newline #\newline "out-int-coup table: "
               (get-table out-in-coup))
(wss wind (car orig-size)(cdr orig-size))
(wsp wind (car orig-pos)(cdr orig-pos))
))



(define-method (controlled-models init-new)()
(window-popup initialize-window)
(display-window initialize-window "init-new for " (get-name))
(let* (
       (nm-or-list '())
       (list-of-model-names '())
       (nm '())
       (num '())
       (new-init-cell '())
     )
(if (closure? (get-originator (eval class)))(make-pruned)
   (begin
    (when (null? controller)
     (display-window #\newline "enter controller ")
     (set! controller (eval (read initialize-window)))
    )
    (display-window initialize-window
         #\newline "enter basic name of controllee and number desired "
         #\newline "or enter a list of models for controllees ")
    (set! nm-or-list (read initialize-window))
    (set! list-of-model-names (when (pair? nm-or-list) nm-or-list))
    (set! nm (when (symbol? nm-or-list) nm-or-list))
    (set! num (when nm (read initialize-window)))
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
     (nm (make-members nm num))
     (else (error "invalid input " nm))
    )
  )
 )
  (display-window initialize-window  #\newline
                         "enter out-in-coup table" #\newline
                         "as list of output-input port pairs " )
  (set-table out-in-coup '())
  (for-each (lambda(pair)(add-port-pair (car pair)(cadr pair)))
                      (read initialize-window))
   (set! new-init-cell (send-if-handles init-cell init-new))
   (when (not (null? new-init-cell))
      (send new-init-cell set-name (send init-cell get-name))
      (set-init-cell new-init-cell)
      (send-if-handles new-init-cell set-this-model new-init-cell)
   )

   (tell-controller-its-influencees)
   (tell-atomic-children-their-names)
   this-model
))


(define-method (controlled-models init-all)()
   (for-each (lambda (chd) (send chd ninitial-state)) (get-children))
)


(define-method (controlled-models init-one)()
  (display-window initialize-window  #\newline
        "initialize controller?" #\newline)
   (when (equal? (read initialize-window) 'y)
        (send controller ninitial-state))
   (when (not (null? (get-pseudo-class-lst (eval class))))
      (window-popup initialize-window)
      (display-window initialize-window
              "choose one as representative for all: "
                    (map (lambda(ch)(send ch get-name))
                    (get-pseudo-class-lst (eval class))
                    ) #nl )
      (let (
             (repres (eval (check-and-accept (read initialize-window)
                           (map (lambda(ch)(send ch get-name))
                           (get-pseudo-class-lst (eval class)))
                            initialize-window)))
           )
          (window-popup-delete initialize-window)
          (send repres ninitial-state)
          (for-each (lambda(ch) (send ch copy-state repres))
                        (get-pseudo-class-lst (eval class)))
      )
   )
)



(define-method (controlled-models make-new)(new-inst-name)
   (let* (
          (models-class (eval (class-of-object (eval name))))
          (co-inst-nm (gen-mem-name new-inst-name))
          (co-inst-name (gen-name name-ctr (base-name co-inst-nm)))
          (m (make-entity models-class co-inst-name))
          (co-nm  (symbol-append '|C:| co-inst-name))
          (co (make-entity co-ordinators co-nm))
          (old-children (remove controller (get-children)))
          (old-init-cell (get-init-cell))
          (#-children  (length old-children))
          (mem-names (when (> #-children 0)
                      (map (lambda(ch) (send ch get-name)) old-children)))
          (mem-name (when (not (null? mem-names)) (car mem-names)))
          (base-nm  (when (not (null? mem-name)) (base-name mem-name)))
;          (mem-name (when (> #-children 0)
;                   (send (car old-children) get-name)))
;          (base-nm (when (> #-children 0)
;                       (base-name mem-name)))
          (class-name (if (> #-children 0)
                     (gen-name name-ctr (symbol-append base-nm 's))
                     (gen-name name-ctr (symbol-append new-inst-name 's))
                     )
           )
          (new-controller (send controller make-new
                   (gen-name name-ctr (base-name (send controller get-name)))))
          (originator (get-originator (eval class)))
         )
      (newline)
      (attach co m)
      (send new-controller copy-state controller)
      (eval
        `(begin
            (send ,old-init-cell make-class ',class-name)
            (send ,m set-this-model ,m)
            (send ,m set-out-in-coup (copy-table,out-in-coup))
            (send ,m set-class ,class-name)
            (send ,m set-controller ,new-controller)
            (send ,m make-init-cell)
            (when (> ,#-children 0)
                  (send ,m make-true-members ',mem-names))
;                 (send ,m make-members ',base-nm ,#-children))
            (send (send ,m get-init-cell) copy-state ,old-init-cell)
            (define ,co-inst-name ,m)
            (define ,co-nm ,co)
         ) user-initial-environment
      )
      (set-originator (send m get-class) originator)
      (writeln "controlled model and co-ordinator made: "
                co-inst-name  " " co-nm)
      m
   ) ;let
)
 
(define-method (controlled-models make-members) (nm n)
   (make-kernel-members nm n)
   (remove controller (get-children))
)

;(define-method (controlled-models make-class)(class-name)
;   (send-if-handles this-model delete-methods)
;   (send-if-handles (make-instance kernel-models) delete-methods)
;   (send-if-handles (make-instance coupled-models) delete-methods)
;   (send-if-handles (make-instance models) delete-methods)
;   (gc)
;   (eval `(make-controlled-class ,class-name (eval ,name)) 
;                              user-initial-environment)
;   (send (make-instance models) resume-methods)
;   (send (make-instance coupled-models) resume-methods)
;   (send (make-instance kernel-models) resume-methods)
;   (send this-model resume-methods)
;)

(macro make-controlled-class (lambda(e)
  (let (
       (class-name (cadr e))
       (m (caddr e))
       )
`(begin
    (define-class ,class-name
       (classvars)
       (instvars
          (class (send ,m get-class))
          (controller (
              (send controller make-new
                       (gen-name name-ctr (send controller get-name)))))
          (out-in-coup (send ,m get-out-in-coup))
          (init-cell (send ,m get-init-cell))
       )
      (mixins controlled-models)
    )
(eval '(compile-class ,class-name))
  )
)))

(define-method (controlled-models isomorphic-coupling?) (m)
  (isomorphic-tab? (get-out-in-coup) (send m get-out-in-coup))
)

(define-method (controlled-models resume-methods)()
   (reload "contr-me.f")
)





;;----------------------------------------------------------
;;     external-message? :
;;
;;   Checks whether the current message is external to
;;   the model (out going message) or not.
;;----------------------------------------------------------




(define-method (controlled-models external-message?) (source-model port)
(let ((response #t))
  (cond
    ( (pair? port)
       (when (or (member (eval (car port)) (get-children))
               (let ((internal #f))
                 (for-each (lambda (c)
                             (when
                                (equal? (component-relation?  c (car port))
                                   'sub-component
                                )
                                (set! internal #t)
                             )
                           )
                           (get-children)
                 )
                 internal
               ) ;; let
                   ;; (car port) is destination model name
             )  ;; or
             (set! response #f)
       )
    )
    (else
          (if (table-look-up out-in-coup port)
                ;; if I/O within children
              (set! response #f)
              (set! response #t)
          )
     )
  ) ;; cond
  response
))



(define-method (controlled-models delete-methods)()
   (delete-method (controlled-models make-members))
   (delete-method (controlled-models make-new))
   (delete-method (controlled-models init-new ))
   (delete-method (controlled-models print-graph))
   (delete-method (controlled-models translate))
   (delete-method (controlled-models get-receivers ))
   (delete-method (controlled-models get-influencees))
   (delete-method (controlled-models tell-controller-its-influencees))
   (delete-method (controlled-models ent->model))
   (delete-method (controlled-models complete-translation))
   (delete-method (controlled-models isomorphic-coupling?))
   (delete-method (controlled-models delete-methods))
)
;
;
;(make-controlled a)  ;a is an existing subclass of entities
;                 makes |co-A| a coupled model AS w/ controlled coupling


(macro make-controlled (lambda (e)
  (let* (
          (class (cadr e))     ;on which controlled is based
          (class-name (symbol->string class))
          (controlled (string->symbol (string-append  "co-" class-name)))
          (co-ord (string->symbol (string-append "C:co-" class-name)))
        )
`(begin
    (mk-ent controlled-models ,controlled) (newline)
    (send ,controlled set-class ,class)
    (send ,controlled set-this-model ,controlled)
    (mk-ent co-ordinators ,co-ord)
    (send ,controlled make-init-cell)
    (attach ,co-ord ,controlled)
  ) 
)))

;;;;;; called from construct-kernel in entrans.s

(define-method (controlled-models ent->model)(mult-nm . lst)
  (let (
       (ker-name (car lst))
       (children-ms (cadr lst))
       (controller (list-ref lst 2))
       (en (list-ref lst 3))
       (extended-path (list-ref lst 4))
       )
       (eval `(make-controlled ,mult-nm) user-initial-environment)
       (set-pseudo-class-lst (eval mult-nm) children-ms)
       (transform-ent en controller (cddr extended-path))
       (eval `(send ,ker-name set-controller ,controller)
                  user-initial-environment)

))

(define-method (controlled-models complete-translation)(out-in-couple . lst)
       (for-each (lambda(coup)(add-port-pair
            (car coup) (cadr coup))) out-in-couple)
)

;;;;;;;;;;;;;;;;;;




