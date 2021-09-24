;; pseudo.s


;;;;;;;;;;;;;kernel-models



(define-method (kernel-models tell-atomic-children-their-names)()
   (for-each (lambda(ch)(when (specialized-class ch 'atomic-models)
               (send ch get-your-name))
             )(get-children))
)

(define-method (kernel-models get-children)()
(get-pseudo-class-lst (eval class))
)


(define-method (kernel-models make-kernel-members) (nm n)
   (set-pseudo-class-lst (eval class) '())
   (let (
         (cnt (counter))
         (new-nm '())
        )
      (set-count cnt n)
      (let loop ((num n))
      (set! new-nm (gen-name name-ctr nm))
         (add-instance (eval class)
             (send (get-init-cell) make-new new-nm))
         (if (not (decrement&test cnt))
             (loop num))
      )
   )
)


(define-method (kernel-models make-init-cell)()
 (if  (closure? (get-originator (eval class)))
   (begin
     (let* (
            (init-cell-nm 'dum)
            (m (make-entity atomic-models init-cell-nm))
            (sim-nm (symbol-append '|S:| init-cell-nm))
            (s (make-entity simulators sim-nm))
          )
     (attach s m)
     (eval `(define ,init-cell-nm ,m) user-initial-environment)
     (eval `(define ,sim-nm ,s) user-initial-environment)
     (set-init-cell m)  
   ))

   (let* (
            (originator  (get-originator (eval class)))
            (originator-class
                  (when (specialized-class originator 'kernel-models)
                        (send originator get-class)))
            (originator-class-lst (when originator-class
                      (get-pseudo-class-lst originator-class)))
            (init-cell-nm (symbol-append (get-name) '-init-cell))
            (init-cell (begin (when (and originator-class
                                         (null? originator-class-lst))
                               (send originator make-members 'dum 1))
                            (send originator make-new init-cell-nm)))
         )
      (eval
         `(begin
             (message-mode-off)
             (send-if-handles ,init-cell adjust-composition-tree)
             (send ,this-model set-init-cell ,init-cell)
             (send-if-handles ,init-cell set-this-model ,init-cell)
             (set-pseudo-class-lst ,(eval class) '())
             (message-mode-on)
          ) user-initial-environment
      )
   )
))


;;;;; added 6-23-89 for kernel-models' init-new ;;;;;;;

(define (retrieve-special nm)
      (let* (
              (atomic&subcls (sub-classes (%sc-name atomic-models)))
              (digrap&subcls (sub-classes (%sc-name digraph-models)))
              (a-model (car (clean (map (lambda(cl)
                 (retrieve (eval cl) nm nm)) atomic&subcls))))
              (d-model
                 (when (null? a-model)
                    (car (clean (map (lambda(cl)
                     (retrieve (eval cl) nm nm)) digrap&subcls)))))
            )
       (cond
           ( (not (null? a-model)) a-model)
           ( (not (null? d-model)) d-model)
           (else
               (let* ( 
                      (nm-lst (find-all ent-name))
                      (first (true-name (car (last-pair nm-lst))))
                      (inst-nm (fix-up inst-name))
                      (d-model   (construct-pruned first)) ;;;; ent-name
                    )
               (if (not (null? d-model)) ;;;;;;d-model
                     (if (equal? first inst-nm) d-model             
                      (begin0
                      (send d-model make-new inst-nm)
                      (send (eval inst-nm user-initial-environment)
                         copy-state d-model)
                      )
                     )
                          
                   (bkpt "does not exist: " ent-name)
               ))
           )
     ))
   )




;;;;;;;;;;;; broadcast-models

(define-method (broadcast-models get-influencees) (child)
(remove child (get-children))
)

(define-method (broadcast-models get-receivers)()
(get-children)
)


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


;;;;;;;;;;;;;;;cellular-models

(define-method (cellular-models init-new)()
   (window-popup initialize-window)
   (let* (
           (nm '())
           (boundaries 0)
           (old-children (get-children))
           (new-init-cell '())
         )
   (display-window initialize-window "init-new for " (get-name)
             #\newline "enter basic name of member ")
    (set! nm (read initialize-window))
    (display-window initialize-window #\newline
             "enter boundaries as list of (min max) of each dimension desired ")
    (set! boundaries (read initialize-window))
    (display-window initialize-window  #\newline
                      "choose ext-coup-type of : (fixed variable) ")
    (set! structure (check-and-accept (read initialize-window)
                            '(fixed variable) initialize-window))
    (display-window initialize-window  #\newline
                      "choose ext-coup-type of : (origin-only  broadcast) ")
    (set! ext-coup (check-and-accept (read initialize-window)
                           '(origin-only broadcast) initialize-window))
     (display-window initialize-window  #\newline
                         "list of influencees of origin-cell" #\newline
                         "as list of cell-positions ")
          (set! infl-origin (read initialize-window))
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
   (make-init-active-cells  nm boundaries)
   this-model
 ) ;let
)

;;;;;;;;;;;;;;;;;;hypercube-models

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

;;;;;;;;;;;;;;;;;;controlled-models

(define-method (controlled-models tell-controller-its-influencees)()
   (eval `(set! (state-influencees (send ,controller get-s))
             (show-pseudo-class (eval ,class))
)))

(define-method (controlled-models get-children) ()
(append (get-pseudo-class-lst (eval class))  (list controller))
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

(define-method (controlled-models init-one)()
  (display-window initialize-window  #\newline
        "initialize controller?" #\newline)
   (when (equal? (read initialize-window) 'y)
        (send controller initial-state))
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
          (send repres initial-state)
          (for-each (lambda(ch) (send ch copy-state repres))
                        (get-pseudo-class-lst (eval class)))
      )
   )
)


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
          (mem-name (when (> #-children 0)
                   (send (car old-children) get-name)))
          (base-nm (when (> #-children 0)
                       (base-name mem-name)))
          (class-name (if (> #-children 0)
                     (gen-name name-ctr (symbol-append base-nm 's))
                     (gen-name name-ctr (symbol-append new-inst-name 's))
                     )
           )
          (new-controller (send controller make-new
                       (gen-name name-ctr (send controller get-name))))
          (originator (get-originator (eval class)))
         )
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
                 (send ,m make-members ',base-nm ,#-children))
;            (message-mode-off)
            (send (send ,m get-init-cell) copy-state ,old-init-cell)
 ;           (message-mode-on)
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


(define-method (cellular-models ent->model)(mult-nm . lst)
  (let (
       (children-ms (cadr lst))
       )
       (eval `(make-cellular ,mult-nm) user-initial-environment)
       (set-pseudo-class-lst (eval mult-nm) children-ms)
))

(define-method (cellular-models complete-translation)(out-in-couple . lst)
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


(define-method (tree-models ent->model)(mult-nm . lst)
  (let (
       (ker-name (car lst))
       (children-ms (cadr lst))
       )
       (eval `(make-tree ,mult-nm) user-initial-environment)
       (set-pseudo-class-lst (eval mult-nm) children-ms)

))

(define-method (tree-models complete-translation)(out-in-couple . lst)
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
;           (send ker set-levels levels)
;           (send ker set-branches branches)
           (set-levels (get-attribute-value en mult-nm 'levels))
           (set-branches (get-attribute-value en mult-nm 'branches))
           (build-children-tree)
           (set-ext-inp-coup ext-inp-coup)
           (set-ext-out-coup ext-out-coup)
           (for-each (lambda(coup)
              (add-port-pair (car coup) (cadr coup) (caddr coup))
           ) int-coup)
       )
)

