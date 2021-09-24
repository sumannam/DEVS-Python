;; kernl-me.s


(define-method (kernel-models tell-atomic-children-their-names)()
   (for-each (lambda(ch)(when (specialized-class ch 'atomic-models)
               (send ch get-your-name))
             )(get-children))
)

(define-method (kernel-models get-children)()
(get-pseudo-class-lst (eval class))
)


(define-method (kernel-models add-port-pair) (port-name1 port-name2)
   (table-insert-pair out-in-coup port-name1 port-name2)
)

(define-method (kernel-models delete-port-pair)(port-name)
(table-delete-pair out-in-coup port-name)
)

(define-method (kernel-models dis-all)()
    (display-window initialize-window
        "Depth? (Depth of "
         (send (car (send this-model get-children)) get-name) " is 0) ")
    (let ( (depth (read initialize-window)) )
         (if (and (number? depth) (>= depth 0))
             (for-each (lambda (chd)
                           (display-nw-by-depth depth chd)
                       ) (get-children)
             )
             (begin
               (if (number? depth)
                 (display-window initialize-window "Depth must be >= 0 ")
                 (display-window initialize-window "Depth must be number! ")
               )
               (display-window initialize-window #\newline)
               (dis-all)
            ) ;; begin
         )
    )
)




;; called by kernel-models method (dis-all)

(define (display-nw-by-depth depth model)
      (cond
         ((equal? depth 0)
           (send model set-nw 'display #t)
           (when (not (atomic-eq? model)) (send model hide-nw-children))
           (hide-nw-parent model)
         )
         (else
            (if (atomic-eq? model)
                (begin
                   (send model set-nw 'display #t)
                   (hide-nw-parent model)
                )
                   ;; depth is greater then current level
               (for-each (lambda (chd)
                                 (display-nw-by-depth (- depth 1) chd)
                         ) (send model get-children)
               )
            ) ;; if
         ) ;; else
      ) ;; cond
)




(define-method (kernel-models init-all)()
   (for-each (lambda (chd) (send chd ninitial-state)) (get-children))
)



(define-method (kernel-models init-one)()
   (when (not (null? (get-children)))
      (window-popup initialize-window)
      (display-window initialize-window
              "choose one as representative for all: "
                    (map (lambda(ch)(send ch get-name)) (get-children)) #nl )
      (let (
             (repres (eval (check-and-accept (read initialize-window)
                           (map (lambda(ch)(send ch get-name)) (get-children))
                            initialize-window)))
           )
          (window-popup-delete initialize-window)
          (send repres ninitial-state)
          (for-each (lambda(ch) (send ch copy-state repres)) (get-children))
      )
   )
)



(define-method (kernel-models set-cellposition-init-cell)()
   (when (or (equal? 0 (send (get-parent) get-parent))(not (is-parent-kernl)))
      (let rep (
                  (model (get-init-cell))
                  (cell-pos 'init-cell)
               )
          (send model set-cell-position 'init-cell)
          (send model set-parent this-model)
          (when (specialized-class model 'coupled-models)
                (for-each (lambda(e)(rep e cell-pos)) (send model get-children))
          )
       )
       (send (get-init-cell) ninitial-state)
       (clear-screen)
       (print-root (send (model->root-devs this-model) get-processor))
   )
)



;;; initializes initial-cell in kernel class for new-window display

(define (init-cell-wind cell)
   (cond
     ( (atom? cell)
       (if (atomic-eq? cell)
           (atomic-wind cell)
           (res-wind cell)
       )
     )
     (else (for-each (lambda (c) (init-cell-wind c)) cell))
   )
)

(define-method (kernel-models is-parent-kernl)()
   (let rep (
              (m (get-parent))
              (parent-kernel? ())
            )
      (if (or parent-kernel? (equal? 0 (send m get-parent)))
          parent-kernel?
          (rep (send m get-parent) (specialized-class m 'kernel-models))
      )
   )                                            
)




(define-method (kernel-models initial-state)()
   (set-cellposition-init-cell)
   (let (
          (init-methods (clean (map (lambda(m)
                               (when (equal? 'init- (subsymbol m 0 5)) m))
                               (all-methods (eval (spec-class-of-object))))))
        )
      (window-popup initialize-window)
      (if (equal? 'init-cell (get-cell-position))
        (begin
          (display-window initialize-window "Wish to initialize  " 
                   (get-name) " ? (y/n)" #\newline)
             (when (equal? (read initialize-window) 'y)
                 (send  (send this-model get-init-cell) initial-state))
         )
        (begin
          (display-window initialize-window "Wish to initialize  " 
                   (get-name) " ? (y/n)" #\newline)
            (if (equal? (read initialize-window) 'y)                         
              (begin
                (display-window initialize-window "for " (get-name) #\newline
                          "choose one of:  " init-methods #\newline)
                 (let (
                    (method (check-and-accept (read initialize-window) init-methods
                                                     initialize-window))
                     )
                  (eval `(,method))
                   (when (equal? 'init-new method)
                    (place-model this-model 4 21)
                    (window-popup-delete initialize-window)
                    (initial-structure this-model) ;;;;;;;;;;;********
                    (send this-model initial-state)
                  )
                ) 
              ) ;;else not intializing
             (initial-window this-model)
          )
       )
    )
      (window-popup-delete initialize-window)  
   )
)

;; initial-state for model-window

(define-method (kernel-models ninitial-state)()
;   (set-cellposition-init-cell)
   (let (
          (init-methods (clean (map (lambda(m)
                               (when (or (equal? 'init- (subsymbol m 0 5))
                                         (equal? 'dis- (subsymbol m 0 4))
                                     )
                                m))
                               (all-methods (eval (spec-class-of-object))))))
        )
      (window-popup initialize-window)
;      (if (equal? 'init-cell (get-cell-position))
;       (begin
;         (display-window initialize-window "Initialize or Display  "
;                                    (get-name) " ? (i/d/n)" #\newline)

;         (case (read initialize-window)
;           ( (d D)  ;; display and set-state
;             (let ( (chd-lst (send (get-parent) get-children)) )
;               (for-each (lambda (chd)
;                         (begin
;                           (set-nw 'display #t)
;                           (if  (atomic-eq? (car chd-lst))
;                                (send chd set-nw 'display #f)
;                                (send (car chd-lst) hide-nw-children)
;                           )
;                         )) chd-lst
;               )
;               (hide-parent-nw (car chd-lst))
;             )
;             (ninitial-state)
;           )
;           ( (i I)  ;; no display but initial-state
;             (send (send this-model get-init-cell) ninitial-state)
;           )
;         ) ;; case

;        ) ;; begin
        (begin
         (display-window initialize-window "Initialize or Display  "
                   (get-name) " ? (i/d/n)" #\newline)

          (case (read initialize-window)
           ( (i I)
             (display-window initialize-window "for " (get-name) #\newline
                       "choose one of:  " init-methods #\newline)
              (let (
                 (method (check-and-accept (read initialize-window) init-methods
                                                  initialize-window))
                  )
                (eval `(,method))
                (when (equal? 'dis-all method)
                      (send this-model ninitial-state)
                )
                (when (equal? 'init-new method)
                 (place-model this-model 4 21)
                 (window-popup-delete initialize-window)
                 (initial-structure this-model) ;;;;;;;;;;;********
                 (send this-model ninitial-state)
                )
             )
           ) ;; (i I)
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

       ) ;; begin
;    ) ;; if
      (window-popup-delete initialize-window)
   )
)





(define-method (kernel-models make-kernel-members) (nm n)
   (set-pseudo-class-lst (eval class) '())
   (let (
         (cnt (counter))
         (new-nm '())
        )
     (set-count cnt n)
     (let loop ((num n))
       (let rep ((new-nm (gen-name name-ctr nm)))
         (if (not (eval `(when (not (unbound? ,new-nm user-initial-environment))
                          ,new-nm) user-initial-environment))
             (add-instance (eval class)
               (send (get-init-cell) make-new new-nm))
           (rep (gen-name name-ctr nm))
         )  ;;; avoid making members with same names as existing environments  
       )
       (if (not (decrement&test cnt))
             (loop num))
     )
   )
)

(define-method (kernel-models make-true-members) (mem-lst)
  (for-each (lambda(mem)
             (add-instance (eval class)
              (send (eval mem) make-new (gen-name name-ctr (base-name mem))))
       ) mem-lst)
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



(define-method (kernel-models gen-mem-name)(ker-inst-name)
   (if (or (<= (symbol-length ker-inst-name) 3)
       (and (> (symbol-length ker-inst-name) 3)
             (not (equal? (gen-name-prefix) (subsymbol ker-inst-name 0 3)))))
       (symbol-append (gen-name-prefix) ker-inst-name)
       ker-inst-name
   )
)



(define-method (kernel-models gen-name-prefix)()
(let (
     (class-name  (spec-class-of-object))
     )
 (symbol-append (string->symbol
             (lowcase (subsymbol class-name 0 2))) '-))
)




(define-method (kernel-models get-coupling)()
   (map (lambda(coup) (list () () coup)) (get-table (get-out-in-coup)))
)


(define-method (kernel-models isomorphic?) (m)
   (let (
          (corresp-tab (get-corresp-tab m))
          (isomorphic-coup? (isomorphic-coupling? m))
          (isomorphic-init-cell? '())
        )
      (if (not corresp-tab)
          corresp-tab
          (begin
             (set! isomorphic-init-cell? 
                (send (get-init-cell) isomorphic? (send m get-init-cell)))
             (and isomorphic-coup? isomorphic-init-cell?)
          )
      )
   )
)

(define-method (kernel-models resume-methods)()
   (reload "kernl-me.f")
)

;;; working but very slow because of eval of delete-methods ;;;;
;(define-method (kernel-models delete-methods)()
;   (let (
;          (methods-deleted '(get-coupling get-children gen-name-prefix
;                             gen-mem-name make-new-members init-procs  
;                             assign-level report-level make-kernel-members
;                             initial-state set-cellposition-init-cell init-all
;                             init-one is-parent-kernl add-port-pair
;                             delete-port-pair isomorphic?))
;        )
;      (for-each (lambda(method)
;         (if (member method (methods kernel-models))
;             (eval `(delete-method (kernel-models ,method))))
;      ) methods-deleted)
;   )
;)


(define-method (kernel-models external-message?) (source-model port)
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
          (if (and (member  source-model (get-children))
                   (table-look-up out-in-coup port)
              )  ;; if I/O within children
              (set! response #f)
              (set! response #t)
          )
     )
  ) ;; cond
  response
))






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-method (kernel-models delete-methods)()
   (delete-method (kernel-models get-coupling))
   (delete-method (kernel-models get-children))
   (delete-method (kernel-models gen-name-prefix))
   (delete-method (kernel-models gen-mem-name))
   (delete-method (kernel-models init-procs))  
   (delete-method (kernel-models assign-level)) 
   (delete-method (kernel-models report-level)) 
   (delete-method (kernel-models make-kernel-members))
   (delete-method (kernel-models make-true-members))
   (delete-method (kernel-models initial-state))
   (delete-method (kernel-models set-cellposition-init-cell)) 
   (delete-method (kernel-models init-all))
   (delete-method (kernel-models init-one))
   (delete-method (kernel-models is-parent-kernl)) 
   (delete-method (kernel-models add-port-pair))
   (delete-method (kernel-models delete-port-pair)) 
   (delete-method (kernel-models isomorphic?))
   (delete-method (kernel-models tell-atomic-children-their-names))
   (delete-method (kernel-models make-class))
   (delete-method (kernel-models delete-methods))
)

;;; can't inherit make-class from model-me.f??
(define-method (kernel-models make-class)(pseudo-class-name)
  (let (
     (psc (pseudo-class))
     )
(set-pseudo-class-nm psc pseudo-class-name)
(set-parent-class-nm psc (class-of-object (eval name)))
(set-originator psc (eval name))
   (eval `(define ,pseudo-class-name ,psc)
              user-initial-environment)
))

;;;;; added 6-23-89 for kernel-model subclasses' init-new ;;;;;;;

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

