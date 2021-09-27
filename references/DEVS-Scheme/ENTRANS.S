;;;; 3-22-90:
;;;; change (construct-pruned ent-name) to (construct-pruned indexed-name)

       
(define (transform en) 
(set-current-item en 'root-asp) 
     (let* ( 
     (ent-name  (item-name (car (ents en))))
     (m (transform-ent en ent-name '(root-asp) )) ;;;;;
     (proc (send m get-processor))
     (r-name  (symbol-append '|R:| ent-name))
     (r (make-entity root-co-ordinators r-name))
     )
(eval `(define ,r-name ,r) user-initial-environment)
(init r proc)
m )) 

;;;;;;;; 3/27/89 ;;;;;;;;
(define (transform-ent en ent-name path)
(set-current-item en ent-name)
(let* (
     (ent-name (true-name ent-name))
     (extended-path (cons ent-name path))
     (inst-name (back-up en ent-name path (list ent-name)))
     (ctrl-ent  (ctrl en ent-name extended-path))           ;;;;;;;
      )
(print extended-path)
(set-current-item en ent-name)
(cond
   ((atomic en)
      (let* (
              (atomic&subcls (sub-classes (%sc-name atomic-models)))
              (digrap&subcls (sub-classes (%sc-name digraph-models)))
              (a-model (car (clean (map (lambda(cl)
                 (retrieve (eval cl) ent-name inst-name)) atomic&subcls))))
              (d-model 
                 (when (null? a-model)
                    (car (clean (map (lambda(cl)
                     (retrieve (eval cl) ent-name inst-name)) digrap&subcls)))))
            )
       (cond
           ( (not (null? a-model)) a-model)
           ( (not (null? d-model)) d-model)
           (else
               (let* ( ;;;;;;;;;;;;;;;;;;;;;;;
      (nm-lst (find-all ent-name))
      (first (true-name (car (last-pair nm-lst))))
      (inst-nm (fix-up inst-name))
                     ;;;;;;;;;;;;;;;;;;;;;;
                  (d-model   (construct-pruned first)) ;;;; ent-name) )
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
   ( (equal? (item-sub-type (cur? en)) mult-ent)
       (let* (                                        ;;;;;;;;;;
                 (mult-nm ent-name)
                 (mult-ap (car (aspects en)))
                 (mult-ch-nm  (car (children en)))
                 (mult-coup-type (item-mult-coup-type mult-ap))
                 (mult-models-type (symbol-append mult-coup-type '-models))
                 (ker-prefix (symbol-append (string->symbol
                             (lowcase (subsymbol mult-coup-type 0 2))) '-))

                     ; (cond ((equal? mult-coup-type 'broadcast) '|br-|)
                     ;              ((equal? mult-coup-type 'hypercube) '|hc-|)
                     ;              ((equal? mult-coup-type 'cellular) '|ce-|)
                     ;              ((equal? mult-coup-type 'controlled) '|co-|)
                     ;              ((equal? mult-coup-type 'tree) '|tr-|)
                     ;              )) ;;;
                 (ker-name (symbol-append ker-prefix mult-nm))
                 (ker-inst-name (symbol-append ker-prefix inst-name))
                 (model (retrieve (eval mult-models-type)
                                                      ker-name ker-inst-name))
  

             )
       (if (not (null? model))
         (begin
           (newline)
           (writeln ent-name " with name " inst-name " found. "
               "Use it or continue transform? (u/c) ")
           (if (equal? (read) 'u)  model

            (begin
            (set! extended-path (cons  (car (all-children en)) extended-path))
            (construct-kernel-model en ent-name inst-name extended-path)
            ))
        )
        (begin
         (set! extended-path (cons  (car (all-children en)) extended-path))
         (construct-kernel-model en ent-name inst-name extended-path)
         )                
    )
   )) 

   ((not(null? ctrl-ent))
                                     ;;; if mult-coup-type CONTROLLED found
   (let (                            ;;; extend path and transform ctrl-ent
        (all-children (all-children en))
        )

   (set! extended-path (cons (car all-children) extended-path))
   (transform-ent en ctrl-ent extended-path)
  ))


  (else             
       (let (
            (model (retrieve digraph-models ent-name inst-name))
            )
       (if (not (null? model))
         (begin
           (newline)
           (writeln ent-name " with name " inst-name " found. "
               "Use it or continue transform? (u/c) ")
           (if (equal? (read) 'u)  model
             (begin                  
             (set! extended-path (cons (car (all-children en)) extended-path))
              (set! model (construct-digraph-model en ent-name extended-path))
              (if (equal? ent-name inst-name) model             
                 (begin0
                 (send model make-new inst-name)
                 (send (eval inst-name user-initial-environment)
                        copy-state model)
                 )
              )
             ) )
          )
          (begin                  
            (set! extended-path (cons (car (all-children en)) extended-path))
            (set! model (construct-digraph-model en ent-name extended-path))
            (if (equal? ent-name inst-name) model 
                 (begin0
                 (send model make-new inst-name)
                 (send (eval inst-name user-initial-environment)
                        copy-state model)
                 )
            ) 

            ))
    )
  )
)))

;;;3-22-90
(define (construct-pruned indexed-name)          ;;
(let* (                          
        (ent-name (ex-base-name indexed-name)) ;;
        (fi (string-append en-base (symbol->string ent-name) ".p"))
        (en-name (symbol-append 'p: ent-name))
        (pt 0)
        (en (entity-structure))
        (env (make-environment en))
        (model 0)
        (co-name (symbol-append '|C:| ent-name))
        (co (make-entity co-ordinators co-name))
      )
(when (file-exists? fi)
(set! pt (open-input-file fi))
(eval `(restore-entstr en (read pt)) env)
(close-input-port pt)
(set! model (eval `(transform en)  env))   
(eval `(define ,ent-name ,model) user-initial-environment)
(eval `(define ,co-name ,co) user-initial-environment)
(attach co model)
(set! model (send model make-new indexed-name)) ;;;
model                                              
)))                           

(define (ex-base-name indexed-name)
   (let rep (
               (base-name '())
               (name (explode indexed-name))
               (int (explode '1234567890&<)) ;;;;;;;;;;;
            )
      (if (or (member (car name) int) (null? name))
          (implode base-name)
          (rep (append base-name (list (car name))) (cdr name) int)
      )
   )
)

;;;; end 3-22-90

                                                      
(define (back-up en ent-name path path-name)
(set-current-item en ent-name)
(case  (length (in-branches en))
 ( 0 (compactify path-name))
 ( 1 (back-up en (car path) (cdr path) path-name))
 ( else (if (>= (length (connected-to-root en ent-name)) 2)
             (back-up en (car path) (cdr path) (append  path-name (list '.in.)
                                                   (list (car path)) ))
     (back-up en (car path) (cdr path) path-name))         
))
)

                                               
(define (house-clean class)
(for-each (lambda(m)(writeln "Destroy model " (send m get-name)" (y/n)?")
                    (when (equal? (read) 'y) (send m destroy)))
   (send (%sc-class-env class) get-lst)
))

(define (compactify path-name)
(string->symbol
(let rep (
         (first (symbol->string (car path-name)))
         (rest (cdr path-name))
         )
 (if (null? rest)
    first
    (rep (string-append first (symbol->string (car rest)))
         (cdr rest))
 ))
))

(define (add-name nm-counter nm)
   (gen-name nm-counter  nm)
    #T
)

(define (construct-digraph-model en ent-name extended-path)
(set-current-item en ent-name)
  (let* (
     (parent ent-name)
     (children (children en))
     (aspect (car (aspects en)))
     (coup (item-coupling aspect))
     (coup-ct (clean (map (lambda(lk)
                (if  (or (equal? (link-left lk) parent)
                        (equal? (link-right lk) parent))
                        lk)) coup)))
     (coup-di  (difference coup coup-ct))
     (m (make-entity digraph-models parent))
     (ct (send m get-composition-tree))
     (di (send m get-influence-digraph))
     (tab (table))
     (co-name (symbol-append '|C:| parent))
     (co (make-entity co-ordinators co-name))
   )
         (table-insert-pair tab parent m)
         (for-each  (lambda(e)(table-insert-pair tab e
                                 (transform-ent en e extended-path)
                                          )) children)
         (for-each (lambda(ch) (add-name name-ctr (base-name ch)))
                      children)     ;;;;;;;;;
         (send m build-composition-tree m
                        (map (lambda(e)(table-look-up  tab e)) children ))
         (for-each (lambda(lk)(bi-insert-pair ct
                        (table-look-up tab (link-left lk))
                        (table-look-up tab (link-right lk))
                        (car (link-port-pairs lk)) (cdr (link-port-pairs lk))))
                                  coup-ct)
         (for-each (lambda(lk)
                (add-edge di  (table-look-up tab (link-left lk))
                              (table-look-up tab (link-right lk))
                        '())
                (di-insert-pair di  (table-look-up tab (link-left lk))
                                    (table-look-up tab (link-right lk))
                          (car (link-port-pairs lk)) (cdr (link-port-pairs lk))))
           coup-di)
        (send m set-priority (map (lambda(e)(table-look-up tab e))
                                 (item-priority-list aspect)))
        (send  m tell-atomic-children-their-names) ;;; added 3-19-90
        (eval `(define ,parent ,m) user-initial-environment)
        (eval `(define ,co-name ,co) user-initial-environment)
        (attach co m)
  m
))   ;;;;;;;;



(define (construct-kernel-model en ent-name inst-name extended-path)
(cond
  ( (do-runtime-pruning? en ent-name inst-name extended-path))
  (else
(set-current-item en ent-name)
(let* (
        (mult-nm ent-name)
        (mult-ap (car (aspects en)))
        (parent-aspect (car (parent-aspects en)))  ;;;;;;;;;;;;;;;;;;;;;;;;;
        (mult-coup-type (item-mult-coup-type mult-ap))
        (ker-class (eval (symbol-append mult-coup-type '-models)user-initial-environment))
        (mult-ch-nm-lst  (children en))
        (ker-prefix (symbol-append (string->symbol
                       (lowcase (subsymbol mult-coup-type 0 2))) '-))

                ; (cond ((equal? mult-coup-type 'broadcast) '|br-|)
                ;          ((equal? mult-coup-type 'hypercube) '|hc-|)
                ;          ((equal? mult-coup-type 'cellular) '|ce-|)
                ;          ((equal? mult-coup-type 'controlled) '|co-|)
                ;          ((equal? mult-coup-type 'tree) '|tr-|)
                ;          ))
        (ker-name (symbol-append ker-prefix mult-nm))
        (ker-inst-name (symbol-append ker-prefix inst-name))
        (out-in-couple (item-coupling mult-ap))                 ;;;;;
        (children-ms (map (lambda(mult-ch-nm)
             (transform-ent en mult-ch-nm extended-path)) mult-ch-nm-lst))
        (ker '())
        (controller (when (equal? mult-coup-type 'controlled)
             (back-down en ent-name  extended-path)))
     )
     (for-each (lambda(mult-ch-nm)
                  (add-name name-ctr (base-name  mult-ch-nm)))
                mult-ch-nm-lst)  ;;;;;;
     (when (not (null? controller)) (add-name name-ctr (base-name controller)))
     (send (car children-ms) make-class mult-nm)
     (set-current-item en (car mult-ch-nm-lst))
     (newline)
     (send (make-instance ker-class) ent->model  mult-nm
        ker-name
        children-ms
        controller
        en
        extended-path
     )
     (add-name name-ctr (base-name ker-name))
     (let (
             (ker-m (eval ker-name))
          )
          (set! ker  (if (not (equal? ker-name ker-inst-name))
                        (begin
                          (add-name name-ctr (base-name  ker-inst-name))
                          (send ker-m  make-new ker-inst-name)
                         )
                       ker-m
                    )
          )
      )
      (set-current-item en ent-name)
      (send ker complete-translation out-in-couple
        mult-nm
        en
      )
      (when controller (send ker tell-controller-its-influencees))
      (send ker tell-atomic-children-their-names) ;;; added 3-19-90
      ker
))
))


;;;; 6-26-89

(define (do-runtime-pruning? en ent-name inst-name extended-path)
(set-current-item en ent-name)
(let* (
        (mult-nm ent-name)
        (mult-ap (car (aspects en)))
        (parent-aspect (car (parent-aspects en)))  ;;;;;;;;;;;;;;;;;;;;;;;;;
        (mult-coup-type (item-mult-coup-type mult-ap))
        (ker-class (eval (symbol-append mult-coup-type '-models)user-initial-environment))
        (mult-ch-nm-lst  (children en))
        (mult-ch-nm (car mult-ch-nm-lst))
        (ker-prefix (symbol-append (string->symbol
                             (lowcase (subsymbol mult-coup-type 0 2))) '-))
        (ker-name (symbol-append ker-prefix mult-nm))
        (ker-inst-name (symbol-append ker-prefix inst-name))
        (out-in-couple (item-coupling mult-ap))                 ;;;;;
        (children-ms '())
        (ker '())
        (controller (when (equal? mult-coup-type 'controlled)
             (back-down en ent-name  extended-path)))
        (m (make-entity atomic-models '%dum%))
             ;;(transform-ent en mult-ch-nm extended-path)) deferred
        (sim (make-entity simulators 's:%dum%))
        (fi (string-append en-base (symbol->string mult-ch-nm) ".e"))
        (en-nm (symbol-append 'e: mult-ch-nm))        ;;; for cut-mult
     )
     (eval `(define %dum% ,m)user-initial-environment)
     (attach sim m)
(if (group-pruning? (item-attr-lst (cur? en))) '() ;; no runtime pruning  
(begin                                             ;; if group pruning already 
     (send m make-class mult-nm)  ;;needed below
     (set-current-item en mult-ch-nm)
     (if (and (null? (aspects en)) (file-exists? fi)) ;;fi usually won't exist if
      (begin                                          ;; cut not chosen in prune
      (newline)
      (writeln "entstr " en-nm " exits in entstr base. Use it? (y/n) ")
       (if (equal? (read) 'y)             ;;;
           (let (
                (pseudo-class (eval mult-nm))
                )
            (eval `(load-entstr ,en-nm))
            (set-originator pseudo-class (eval en-nm))
            );;let
            (begin
            (set! m (transform-ent en mult-ch-nm extended-path)) ;;;
            (send m make-class mult-nm) ;;;;
            );;begin
       );;if
       );;begin
       (begin
       (set! m (transform-ent en mult-ch-nm extended-path)) ;;;
       (send m make-class mult-nm) ;;;;
       );;begin
    );;if
     (set-current-item en mult-ch-nm)
     (set! children-ms (list m))
     (newline)
     (send (make-instance ker-class) ent->model  mult-nm
        ker-name
        children-ms
        controller
        en
        extended-path
     )

     (let (
             (ker-m (eval ker-name))
          )
          (set! ker  (if (not (equal? ker-name ker-inst-name))
                       (send ker-m  make-new ker-inst-name)
                       ker-m
                    )
          )
      )
      (set-current-item en ent-name)
      (send ker complete-translation out-in-couple
        mult-nm
        en
      )
      ker
))
))

(define (group-pruning? item-attributes-lst)
 (let rep (
           (lst item-attributes-lst)
          )
  (cond
     ( (null? (car lst)) '())
     ( (equal? (caar lst) 'num-groups) #!true)
     ( else (rep (cdr lst)))
  )
 )
)

;;;;;;;;;;;;;;;;

(define (connected-to-root en ent-name) ;;assumes ent-name names an existing item
(sci en ent-name)                       ;;also (length (in-branches en)) = 2
(let (
     (inbr (in-branches en))
     )
(cond
 ( (null? inbr) '())
 ( (equal? (item-name (branch-left (car inbr))) 'root-asp) (list #!true))
 ( else (clean (map
                (lambda(br)(connected-to-root en (item-name (branch-left br))))
            inbr)))
)))


;;; inverse-transform from model-structrue to entstr ;;;

(define (inv-transform root-co-ord)
   (if (not (specialized-class root-co-ord 'root-co-ordinators))
       (writeln "argument is not root-co-ordinators : chech it")
       (let* (
               (coor (send root-co-ord get-child))
               (root-model (send coor get-devs-component))
               (model-to-be-saved (select-representative-member root-model))
             )                                                              
          (inv-transform1 model-to-be-saved)
          (save-en (eval (symbol-append 'e: (model->ent-name root-model))))
       )
   )
)

(define (inv-transform1 root-model)
   (make-entstr (model->ent-name root-model))                              
   (delete-item (eval (symbol-append 'e: (model->ent-name root-model)))
                         (model->ent-name root-model))
   (let rep (
              (model root-model)  
              (en (eval (symbol-append 'e: (model->ent-name root-model))))
              (cur-it 'root-asp)
            )
      (set-current-item en cur-it)
      (if (specialized-class model 'atomic-models)
          (set-its/brs-pair en model)
          (begin               
             (set-its/brs-pair en model)
             (set-current-item en 
                               (item-name (branch-right (car (branches? en)))))
             (set-its/brs-pair en model)
             (for-each (lambda(e) (rep e en (car (clean (map (lambda(br)
                         (if (equal? (model->ent-name (send e get-parent)) 
                             (item-name (branch-left br)))
                             (item-name (branch-right br)))) (branches? en))))))
                (send model get-children)))
      )                                        
   )
)                                              

                  
;;; set items-branches pair of entstr from model ;;;
         
(define (set-its/brs-pair en model)
   (let* (
           (item '())
           (branch '())
           (ent-nm (model->ent-name model))
           (asp-nm (asp-name model))
           (m-class (send model spec-class-of-object))
           (name (if (equal? (item-type (cur? en)) 'ent) asp-nm ent-nm))
           (type (if (equal? (item-type (cur? en)) 'ent) 'asp 'ent))
           (mult-type (subsymbol m-class 0 (- (symbol-length m-class) 7)))
           (sub-type (item-sub-ty en model))
           (mult-coup-type (if (equal? sub-type 'mult-asp)mult-type 'undefined))
           (coupling (if (equal? type 'asp) (coupling? model))) 
         )
      (set! item (make-item 'type type
                            'name name                                     
                            'mult-coup-type mult-coup-type
                            'coupling coupling
                            'sub-type sub-type))       
      (set! branch (make-branch 'left (cur? en) 
                                'right item))                        
      (set-items en (cons item (items? en)))       
      (set-branches en (cons branch (branches? en)))
   )
)

;;; generate ent name form model name ;;;

(define (model->ent-name model)                                                 
   (let (
          (name (send model get-name))
          (parent (send model get-parent))
        )
      (if (specialized-class parent 'kernel-models)
          (cond ((specialized-class model 'atomic-models)
                    (base-name name))
                ((specialized-class model 'digraph-models)
                    (base-name name))
                ((specialized-class model 'kernel-models)
                    (base-name (subsymbol name 3 (symbol-length name))))
                (else 
                    (error "Invalid model class" 
                            (send model spec-class-of-object)))
          )
          name)
   )
)

;;; generate asp name based on model ;;;
 
(define (asp-name model)
   (let (
          (en-name (model->ent-name model))
          (suffix (if (specialized-class model 'kernel-models)'-mult-asp '-asp))
        )
      (symbol-append en-name suffix)
   )
)
                        
;;; set item-sub-type field of item in entstr based on model ;;;

(define (item-sub-ty en model)
   (let (
          (prefix 'mult-)
          (type (if (equal? (item-type (cur? en)) 'ent) 'asp 'ent))
        )
      (if (specialized-class model 'kernel-models)
          (symbol-append prefix type)
          (if (equal? (item-sub-type (cur? en)) 'mult-asp)
              (symbol-append prefix 'child)
          )
      )
   )
)
                                     
;;; gen coupling field of item in entstr corresponding to model coupling ;;;

(define (coupling? model)
   (let* (
           (parent (send model get-parent))
           (kernel-parent (and (not (equal? 0 (send parent get-parent)))
                               (specialized-class parent 'kernel-models)))
         )
      (map (lambda(e)(make-link 
           'left (if (car e)
                     (if kernel-parent
                         (base-name (drop-prefix (car e)))
                         (drop-prefix (car e)))
                 )
           'right (if (cadr e)
                      (if kernel-parent
                          (base-name (drop-prefix (cadr e)))
                          (drop-prefix (cadr e)))
                  )
           'port-pairs (caddr e))) (send model get-coupling)
      )
   )
)

;;; drop name prefix for kernel-models ;;;

(define (drop-prefix model-nm)
   (if (specialized-class (eval model-nm) 'kernel-models)
       (subsymbol model-nm 3 (symbol-length model-nm))
       model-nm
   )
)
       
;;; make num of members in kernel-models to be one ;;;

(define (select-representative-member root-model)
   (when (not (specialized-class root-model 'atomic-models))
       (when (not (specialized-class root-model 'digraph-models))
           (if (equal? #!UNASSIGNED (send root-model get-children))
               (error "empty children" (send root-model get-name)))
           (let (
                  (class (eval (send root-model get-class)))
                  (children (send root-model get-children))
                )
              (send (%sc-class-env class) set-lst (list (car children)))
           )
       )
       (for-each (lambda(ch)(select-representative-member ch)) 
          (send root-model get-children)
       )
   )
   root-model
)




(define (back-down en ent-name path)     ;; back to aspect and find the controller
(when (not (equal? (caddr path) 'root-asp))
(set-current-item en (caddr path))
(let (
     (br-list (out-branches en))
     )
(sci en (cadr path))
(if(not(equal? (branch-right(car br-list)) (cur? en)))
   (item-name (branch-right(car br-list)))
   (item-name (branch-right(cadr br-list)))
))
))


;;; applied when curren-item is entity
;;; trace the mult-coup-type of each child
;;; if mult-cup-type CONTROLLED found
;;; then return the child's item-name as controlled-entity

(define (ctrl en ent-name path)
 (sci en ent-name)
 (case (length (aspects en))
  (1
       (let (
             (children (children en))
            )
    (if (equal? (length children) 2)
        (begin
         (let rep (
                  (children children)
                  )  
         (sci en (car children))
        (cond
             ( (and (atomic en) (not(null? (cdr children))))
              (rep (cdr children)))
             ( (not(atomic en))
               (if (equal? (item-mult-coup-type(car(aspects en))) 'controlled)
                   (item-name(cur? en))))
        )))
    )))
   (else '())
))

;;;;;;;; 1/23/89 original ;;;;;;;;;;;;;

(define (find-all mult-name)
(define (find-one mult-name)
   (let rep (
               (base-name '())
               (name (explode mult-name))
               (int (explode '_))
            )
      (if (or (member (car name) int) (null? name))
          (list (implode base-name) (cdr name))
          (rep (append base-name (list (car name))) (cdr name) int)
      )
   )
)
(let rep(
        (name (explode mult-name))
        (lst '())
        )
(if (null? name) lst
    (let (
         (result (find-one name))
         )
    (rep (cadr result) (cons (car result) lst))
    )
)
))

(define (true-name name-dot-p)
(if (symbol-match name-dot-p '*.p)
 (let (
      (rev-lst (reverse (explode name-dot-p)))
      )
(implode (reverse (cddr rev-lst)))
 )
 name-dot-p
))

(define (fix-up inst-name)
(define (flatten lst)
(let rep(
     (rem (cdr lst))
     (result (car lst))
     )
(if (null? rem) result
    (rep (cdr rem) (append result '(_) (car rem)))
)
))

(let (
     (lst (reverse (find-all inst-name)))
     )
(set! lst (cons (true-name (car lst)) (cdr lst)))
(set! lst (flatten (map (lambda(el)(explode el)) lst)))
(implode lst)
))
;;;;;;;;;;;;;;;;;;;




;;;;;;; 3/27/89 ; 4-27-89 ; 6-12-89 ;;;;;;;;;

(define (retrieve class ent-name inst-name)
;(writeln " retrieve class is : " (%sc-name class))
(let* (
      (nm-lst (find-all ent-name))
      (first (true-name (car (last-pair nm-lst))))
      (inst-nm (fix-up inst-name))
    ;;;;;;;;;;;;;;;;
      (ent-model (retrieve-one class ent-name inst-nm))
      (fir-model (when (null? ent-model)
                    (retrieve-one class first inst-nm)))
      (model (cond
               ( (not (null? ent-model)) ent-model)
               ( else fir-model)
             ))
    ;;;;;;;;;;;;;;;;;;;
     )
(cond
((null? model) '())
((= (length nm-lst) 1) model)
((not (specialized-class model 'forward-models)) model)
(else
 ;;;;;;;;;;;;;;;;;;
 (if (not (null? ent-model))  model    ;; if model "ent-name" exists
 ;;;;;;;;;;;;;;;;; 
   (let* (
        (m-lst
         (clean (map (lambda(nm)(retrieve-one forward-models nm nm)) 
                 (reverse nm-lst)))              ;;only forward-models can be inherited
        )
       )
 (for-each (lambda(mod)
   (if (and 
         (not (member (car (state-ext-activities (send mod get-s)))
                      (state-ext-activities (send model get-s))))
         (not (member (car (state-int-activities (send mod get-s)))
                      (state-int-activities (send model get-s)))))
       (send-if-handles model inherit-from mod))
   ) (cdr m-lst))
  model          ;; first one has been inherited when applying MAKE-NEW
  )              ;; in procedure RETRIEVE-ONE
 )
))
))

;;;; 6-26-89
(define (retrieve-one class ent-name inst-name)
(define (ex-base-name indexed-name)
   (let rep (
               (base-name '())
               (name (explode indexed-name))
               (int (explode '1234567890&<)) ;;;;;;;;;;;
            )
      (if (or (member (car name) int) (null? name))
          (implode base-name)
          (rep (append base-name (list (car name))) (cdr name) int)
      )
   )
)
 
;  (writeln " retrieve-one class is : " (%sc-name class))
  (let* (
          (ent-name (ex-base-name ent-name))
          (model (eval`(when (not (unbound? ,ent-name user-initial-environment))
                         ,ent-name)
                  user-initial-environment))
          )
        (when (equal? ent-name #!UNASSIGNED) (eval `(access ,ent-name '())
                                               user-initial-environment))
        (set! model
            (if (null? model)
               (eval
                 `(begin
                    (when (not (load-if-exists (string-append mo-base
                                    (symbol->string ',ent-name) ".fm")))
                      (load-if-exists (string-append mo-base
                                    (symbol->string ',ent-name) ".m")))
                    (when (not (unbound? ,ent-name user-initial-environment))
                      ,ent-name)
                   ) user-initial-environment)
               (if (pair? model) (car model) model)
            )
        )
 
        (when (not (null? model))
           (let (
                  (name (send model get-name))
                  (proc (send model get-processor))
                  (inst-mo (eval
                            `(when (not (unbound? ,inst-name 
                                     user-initial-environment)) ,inst-name)
                                     user-initial-environment))                
                 )
               (when (not (environment? proc))
                  (eval `(set! ,name '()) user-initial-environment)
                  (bkpt  " lacks processor:was destroyed; restart ->" name))
               (if (equal? (%sc-name class) (class-of-object model))
               ;;;;;;;;;;;;;;;;;;;;;;;;;
                   (if (not (equal? ent-name inst-name))           ;;;;;;
                      (if (null? inst-mo)
                          (send model make-new inst-name)
                          inst-mo)
                    model   
                ;;;;;;;;;;;;;;;;;;;;;;;;;  
                   )
               )
         )
     )
 )
)






