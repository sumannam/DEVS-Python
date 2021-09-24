;;;;;;;;;;;;;;;;;;;;;;;;;;;;;enmodul.s;;;;;;;;;;;;;;;;;;

(alias ent 'ent)
(alias asp 'asp)
(alias spec 'spec)
(alias mult-ent 'mult-ent)
(alias mult-asp 'mult-asp)
(alias mult-child 'mult-child)
(alias ci current-item?)
(alias sci set-current-item)
(alias ai add-item)
(alias dei delete-item)
(alias am add-mult)
(alias amc add-mult-couple)
(alias smct set-mult-coup-type)
(alias amm add-mult-mult)
(alias pe print-ent)
(alias en-base entstr-base_directory)
(alias mo-base  model-base_directory)


(define-structure link
      left                 ;item-name
      right                ;item-name
      (port-pairs  '())    ;pair (a.b) a,b are port-names
)


(define-structure item
              type                         ;ent, asp, spec
              name
              attr-lst                     ;list of attributes 
              (mult-coup-type 'undefined)  ;broadcast, hypercube, cellular,
                                           ;controlled, tree
              num-mult-children            ;number of multi children
              (coupling '())               ;list of links
              (sel-constraint '())         ;selection contraints
              sub-type                     ;mult-ent, mult-asp, mult-child
              (priority-list '())          ;priority list for selectfn 
)

(define-structure branch left right) 


(define (find-item items it-name)
        (let rep (
              (ilist items)
             )
        (cond
          ( (null? ilist) '()) ;;; (display "no such item ")
          ( (equal? (item-name (car ilist)) it-name) (car ilist))
          (else (rep (cdr ilist)) )
         )
       )
 )


(define root-asp (make-item 'name 'root-asp 'type asp))



(define %mult-coup-list (map (lambda (nm)(subsymbol-to  nm '-))
     (delete! 'kernel-models (sub-classes 'kernel-models))))
              ;;   '(broadcast hypercube cellular controlled tree))



(build-module entity-structure
          (
                 (items (list root-asp))
                 (branches '())
                 (cur  root-asp )
                 (range-mult-coup  %mult-coup-list)
                 (constraints (let ((rel (relation)))
                     (set-attributes rel '(spec-ent1 from-spec1 action
                             spec-ent2 from-spec2 ))
                      rel))

             )
             (
(get-constraints () (lambda()constraints))
(cur? () (lambda()cur))
(current-item?  ()     (lambda () (item-name cur )))
(items?  ()      (lambda () items))
(branches?  ()       (lambda () branches))
(range-mult-coup?() (lambda() range-mult-coup))
(set-items (itlist) (lambda(itlist) (set! items itlist)))
(set-current-item (it-name)     (lambda (it-name)
                           (if (vector? (find-item items it-name))
                               (set! cur (find-item items it-name))
                               '()  ;;(display "entity not in graph ")
                           )
                        )
)
(attributes? (it-name) (lambda(it-name)
                           (item-attr-lst (find-item items it-name))
                       )
)
(get-attribute-value (it-name att) (lambda(it-name att)
                          (let* (
                                  (item (find-item items it-name))
                                  (att-pair (assoc att (item-attr-lst item)))
                                )
                             (if (null? att-pair)
                                 (writeln att 
                                          " is not an attribute of " it-name)
                                 (cadr att-pair))
                           )
))           
(set-branches (blist) (lambda(blist)(set! branches blist)))
(set-range-mult-coup (rmclist)(lambda(rmclist) (set! range-mult-coup rmclist)))
(add-items (lst)   (lambda(lst)(set! items (union (list lst items)))))
(add-item (type name) (lambda (type name)
                         (when (not (axiom-violated? cur items type name))
                             (let (
                                    (item (find-item  items name))
                                  )
                                (when (not (vector? item))
                                   (set! item   (make-item  'name name
                                                  'mult-coup-type 'undefined
                                                  'type type 'coupling '() )))  
                                (if (not (equal? cur item))
                                     (set! branches (cons (make-branch
                                              'left cur  'right item) branches))
                                )
                                (when (not (member item items))
                                   (set! items (cons item items))
                                )
                             )
                           )
                        ) 
)
(delete-item (it-name) (lambda(it-name)
                          (let rep (
                                     (item (find-item items it-name))
                                     (br->left (map (lambda(br)(branch-left br))
                                             branches))
                                     (del-br 0)
                                   )
                             (cond 
                                ((not (member item items))
                                    (writeln it-name
                                          " is not in entity-structure"))
                                ((member item br->left)
                                    (writeln it-name
                                          " is not a leaf : cannot be deleted"))
                                (else
                                    (set! items (remove item items))
                                    (for-each (lambda(br)
                                       (if (equal? (branch-right br) item)
                                           (set! del-br br)
                                       )) branches)        
                                    (set! branches (remove del-br branches))
                                    (set! cur (branch-left del-br))
                                    (if (or (equal? 'mult-asp (item-sub-type 
                                                     (branch-left del-br)))
                                             (equal? 'mult-ent (item-sub-type 
                                                     (branch-left del-br))))
                                        (rep (branch-left del-br) 
                                             (map (lambda(br)(branch-left br))
                                                   branches) 0)
                                    )                 
                                 )
                               )
                             )
                           )
)

(add-attribute (it-name att value)
                    (lambda (it-name att value)
                         (let* (
                                 (item (find-item items it-name))
                                 (attri-lst (item-attr-lst item))
                               )
                            (if (not (equal? 'ent (item-type item)))
                                (writeln "item type is not ent: "
                                         "attribute can't be attached to")
                                (let* (
                                        (old-attr (assoc att attri-lst))
                                      ) 
                                   (set! attri-lst (delete! old-attr attri-lst))
                                   (set! (item-attr-lst item) 
                                         (append attri-lst 
                                             (list (list att value))))
                                )
                            )
                         )                                        
                    )
)
(delete-attribute (it-name att)
                        (lambda(it-name att)
                          (let* (
                                 (item (find-item items it-name))
                                 (attri-lst (item-attr-lst item))
                                 (attr-deleted (assoc att attri-lst))
                                )
                              (if (null? attr-deleted)
                                  (display-window 'console att 
                                     " is not a attribute of " it-name)
                                  (set! (item-attr-lst item) 
                                        (remove attr-deleted attri-lst))
                              )
                           )
                        )
)

(add-sel-constraint (it-name sel-constraint)
                    (lambda (it-name sel-constraint)
                         (let* (
                                ;; (items (items? en)) jim, 90
                                 (item (find-item items it-name))
                                 (old-constr (item-sel-constraint item))
                               )
                            (if (not (or (equal? 'spec (item-type item))
                                         (equal? 'asp (item-type item)))
                                )
                                (writeln it-name " is not a spec or asp: "
                                    "selection constraint can't be attached to it")
                                (set! (item-sel-constraint item)
                                    (if (not old-constr)
                                        (list sel-constraint)
                                        (append old-constr
                                            (list sel-constraint))))
                            )
                         )
                    )
)


(delete-sel-constraint (it-name sel-constraint)
                        (lambda(it-name sel-constraint)
                          (let* (
                                 (item (find-item items it-name))
                                 (sel-constr (item-sel-constraint item))
                                )
                              (if (not (member sel-constraint sel-constr))
                                  (display-window 'console sel-constraint 
                                     " is not attached to " it-name)
                                  (set! (item-sel-constraint item) 
                                        (remove sel-constraint sel-constr))
                              )
                           )
                        )
)
(add-couple (from-name to-name port-name1 port-name2)
                    (lambda (from-name to-name port-name1 port-name2)
                         (set! (item-coupling cur)
                              (cons (make-link 'left from-name 'right to-name
                                      'port-pairs (cons port-name1 port-name2))
                                    (item-coupling cur)))
                    )
)
(set-coupling (aspect coup)
                   (lambda(aspect coup)(set! (item-coupling aspect) coup))
)
))

(define (add-constraint en text)
(add-sel-constraint en (current-item? en) text)
)



