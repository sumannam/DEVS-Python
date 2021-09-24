;;;;;;;;;;;;;; enpeprun.s


(define %unused-branches% '()) ;;global needed
                               ;;temporary store for unused branches


(define %selections% (relation)) ;;global needed since can't make it work otherwise
(set-attributes %selections% '(action spec-ent from-spec))

(define %constraints% (relation))
(set-attributes %constraints% '(spec-ent1 from-spec1 action
                             spec-ent2 from-spec2 ))

(define (infer-selections se-fs)
(let (
     (tuples (*get-related %constraints% se-fs))
     )
(for-each (lambda(tuple)(assert-rel %selections% (cddr tuple))) tuples)
))


(define (add-constraints$ en  lst)
                             ;spec-ent1 from-spec1 action spec-ent2 from-spec2)
(let (
     (constraints (get-constraints en))
     )
(assert-rel constraints lst)
                       ;(list spec-ent1 from-spec1 action spec-ent2 from-spec2))
))



(define (inherit en ent-name)   ;ent-name names an entity in a spec of curr?
; (define (conc-nm spec-nm gen-nm)
; (symbol-append spec-nm '_ gen-nm)
; )       
 (define (conc-nm spec-nm gen-nm)
 (if (member $linksym (explode spec-nm))     ;;;don't underscore when already -
      spec-nm                          
      (symbol-append spec-nm '_ gen-nm)
 ))

(let* (
     (cur (cur? en))
     (entity  (find-item (items? en) ent-name))                            
     (new-ent-name (conc-nm ent-name (item-name cur))) ;;;
     )
(if (vector? entity)
(begin               
(when (equal? (item-sub-type cur) mult-ent)
                    (set! (item-sub-type entity) mult-ent))
(for-each (lambda(aspect)
   (if (and (not (equal? (item-sub-type aspect) 'mult-asp))
            (item-coupling aspect))
     (replace-coupling en aspect (item-name cur) new-ent-name))) ;;;;
         (union2 
           (begin (set-current-item en ent-name)(aspects en)) 
           (begin (set-current-item en (item-name cur))(parent-aspects en))))
(for-each (lambda(aspect)
   (if (item-priority-list aspect)
      (replace-priority aspect (item-name cur) new-ent-name))) (parent-aspects en))

(replace-branches (branches? en) (cur? en) entity) 
(set-current-item en ent-name)
(set! (item-name entity) new-ent-name)
)
(writeln "no such entity")
)))


;;; new select-ent 4-20-90

(define (select-ent en ent-name spec-name)   ;current is general entity
(cond
( (equal? (item-type (cur? en)) ent)
    (let rep (
         ( blist (out-branches en))
         )
     (cond
       ( (null? blist) (writeln "no such  specialization") '())
       (  (and (equal? spec-name (item-name (branch-right (car blist))))
               (equal? spec  (item-type (branch-right (car blist)))))
           (let* (
                (cur-item (item-name (cur? en)))
                (spec-br (car blist))
                (spec-brs
                     (clean (map (lambda(br)
                        (when (equal? spec-name (item-name (branch-left br)))
                               br)) (branches? en))))
                (spec-ents (map (lambda(br) (item-name (branch-right br)))
                            spec-brs))
                (del-brs (append spec-brs (list spec-br)))
                (del-ents (remove ent-name spec-ents))
                (unused-brs '()) ;; 4-18-90
                )
             (for-each (lambda(br) (remove-branch en br)) del-brs)  ;;;;
             (for-each (lambda(enti) (set! unused-brs (union2 unused-brs
                                          (sub-entstr-brs en enti)))) del-ents)
             (set! %unused-branches% (union2 %unused-branches% unused-brs))
             ;; temporarily store unused branches
             ;;  1) reusable for uniformity
             ;;  2) negative check for multiply occurring entities
             ;; clean-entstr will delete all unused items and branches
             ;;  at the end of pruning

             (set-current-item en cur-item)
             (inherit en  ent-name)     ;;;removed sci en ent-name
             (writeln "entity " ent-name
                  " from specialization " spec-name " selected")

;;;;;infer selections from constraints and just made selection

             (infer-selections
               (list (list 'spec-ent1 ent-name)
                  (list 'from-spec1 spec-name)))
           )
;;;;;;end infer
       )
       ( else   (rep  (cdr blist)))
    )
  ))

(else (writeln "current-item " (current-item? en) " is not of type ent"))
))

;;;;;;;;;8-25-89 add context sensitive pruning;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (add-spec-and-prune en)
   (writeln "select starting entity from the following: "
          (map (lambda(it)(item-name it)) (ents? en)) )
   (select-root en (check-and-accept (read)
                (map (lambda(it) (item-name it))(ents? en)) 'console))
   (eval-sel-constraints en)
   ;;remove all previous selections and load in constraints from current en
   (set-tuples %selections% ())
   (set-tuples %constraints% (get-tuples (get-constraints en)))
   ;;end remove and load
   (set! %unused-branches% ()) ;;remove all previous unused branches
   (prune-from-ent en 'attri '(root-asp))
)

(define (make-copy-and-prune en extended-path) ;;are at mult-occur entity
;; check first if first-parent is not multiple asp
;(writeln extended-path)
   (let* (
           (parents  (clean (map (lambda(br)
               (when (and (not (member br %unused-branches%)) ;;4-18-90
                          (or (equal? (item-type (link-left br)) 'asp)
                              (equal? (item-type (link-left br)) 'spec))) ;; 
                      (link-left br))) (in-branches en))))
           (parent-items  (map (lambda(par)(item-name par)) parents))
           (ent-name (current-item? en))
           (first-parent (car extended-path))
           (en-group '())
        )

(when (and
          (> (length parents) 1)
          (member first-parent parent-items)
          (not (equal? (item-sub-type (find-item (items? en) first-parent)) 
                       'mult-asp))               
       )
 (set! parent-items (cons first-parent (remove first-parent parent-items)))
   (writeln "this is a multiply occurring entity")
   (writeln "do context sensitive pruning? (y/n)")
   (when (equal? (read) 'y)

        (let rep (
                  (pars parent-items) ;;at least 2
                  (num 1)
                  (extracted-en (extract-sub-entstr en 'e:@sub))
                  (en-nm (gen-name ent-nm-ctr 'e:@sub))
                 )
           (cond
              ((null? pars))
              ( (> num 0)
                 (set! en-group
                       (begin
                          (eval `(copy-entstr-in-core ,extracted-en ,en-nm))
                           (append en-group (list (eval en-nm)))))
                     (rep (cdr pars) (-1+ num) extracted-en
                                       (gen-name ent-nm-ctr 'e:@sub))
              )
              (else  (set! en-group
                       (append en-group (list (car pars))))
                     (rep (cdr pars) (-1+ num) extracted-en '()))

          )
        )
       (delete-sub-entstr1 en ent-name)        
       (newline)
       (writeln "pruning in the context of: " first-parent " : ")
       (newline)
      (for-each (lambda(en1)
       (set-current-item en (car parent-items))
        (cond
          ((symbol? en1) ;;after first  just add back ent-name
             (add-item en ent ent-name)
          )
          ((equal? (car parent-items) first-parent);;prune first parent
            (select-root en1 ent-name)
            (prune-from-ent en1 'attri   extended-path)
            (let (
                 (vers-en1 (mk-entstr-version  en1))
                 (root-vers-en1 '())
                 (f-asp (find-item (items? en) first-parent))
                 )                           
             (set-current-item vers-en1 'root-asp)
             (set! root-vers-en1 (item-name (car (ents vers-en1))))
             (add-sub-entstr en vers-en1)
             (replace-coupling en f-asp ent-name root-vers-en1)
             (replace-priority f-asp ent-name root-vers-en1)
           )
          )
         );cond
         (set! parent-items (cdr parent-items))
          ) en-group)
        (message-mode-off)
       (for-each (lambda(en1)
          (if (not (symbol? en1))
            (let (
                 (en-fname (string-append en-base (gen-en-fname en1)))
                 ) 
             (when (file-exists? en-fname)
             (dos-delete en-fname)
             (delete-en en-mgr (get-en-name en-mgr en1))
            ))
           )
       ) en-group)  ;;;correction required here??
       (delete-en en-mgr 'e:@sub)
       (message-mode-on)
   );; when
 ));when 
)

;; 4-18-90
(define (spec-brs-in-use branches spec-lst)
   (let rep (
            (specs spec-lst)
            (brs branches)
            (brs-in-use ())
            )
     (cond
        ((null? specs) brs-in-use)
        (else
          (set! brs-in-use
                (append brs-in-use
                  (clean (map (lambda(br)
                         (equal? (car specs) (item-name (branch-left br))) br)
                         brs))))
          (set! brs (difference brs brs-in-use))
          (rep (cdr specs) brs brs-in-use)
         )
      )
))

;;;; prune-form-ent

(define (prune-from-ent en set-attri extended-path)
(writeln "working from entity " (current-item? en))

(when (not (make-copy-and-prune en extended-path))

  (if (and (item-attr-lst (cur? en)) set-attri)
      (for-each (lambda(e)
        (when (null? (cadr e))
          (writeln "value of attribute "(car e)
                   " attached to " (current-item? en) " : ")
          (add-attribute en (item-name (cur? en)) (car e) (read))
       ))
       (item-attr-lst (cur? en)))
   )
;;;;;;;;;;;;;; at leaf check for available SES or PES
 (when (leaf-ent en)    ;;4-18-90
   (message-mode-off)
    (let* (
          (cur-it (current-item? en))
          (leaf-nm (subsymbol-to cur-it '_))
          (leaf-base-nm (base-name leaf-nm))
          )       ;;up to '_ represents leaf after inheritance sequence

      (if ;;there is a pruned-entstr
          ;; (and (not (is-in-model_base? leaf-nm)) ;; use entstr first
          ;;      (is-in-entstr_base?  leaf-nm))
          (is-in-entstr_base? leaf-base-nm)
            (if
               (not (is-entstr leaf-base-nm))  ;;there is no entstr
                (begin
                 (writeln " there is a PES")
                 (add-spec&ents-at-leaf en cur-it))
                  ;;else there is an entstr
                (if (begin
                      (message-mode-on)
                      (writeln "there are both entstr and pruned entstrs")
                      (writeln "wish to select from pruned entstrs? (y/n)")
                      (message-mode-off)
                      (equal? (read) 'y)
                    )
                     (add-spec&ents-at-leaf en cur-it)
                     (add-entstr-at-leaf en cur-it leaf-nm)
                );;if
            );;if
           ;;else there is no pruned-entstr
            (when (is-entstr leaf-base-nm) ;;there is entstr
                    (add-entstr-at-leaf en cur-it leaf-nm)
            );when

        );if
        (set-current-item en cur-it)
   );let
   (message-mode-on)
 )

;;;; if not a leaf can be made one
 (when (not (null? (aspects en)))
   (writeln "make this a leaf? (y/n)")
   (when (equal? (read) 'y)
      (for-each (lambda(br)(remove-branch en br)) (out-branches en))))

;;;;;;;;;;; do specializatins or choose an aspect
 (let   (
          (gen-name (current-item? en))
          (sp '())
          (asp-lst '())
          (spec-lst '())
          (selected-ent '())
          (rp/gp '())  ;;;runtime or group pruning
       )

;;;;;;;;;;;;;;;do specializations
   (when (not (null? (specializations en)))
     (set! spec-lst (map (lambda(sp)(item-name sp)) (specializations en)))
   
     (writeln "select a specialization from the following: " spec-lst)
     (if (equal? (length spec-lst) 1)
         (set! sp (car spec-lst))
         (set! sp (check-and-accept (read) spec-lst 'console))
     )
     (writeln "specialization " sp " is selected")
     (set-current-item en sp)
     (when (null? (ents en))
       (set! %unused-branches% (difference %unused-branches%
                               (spec-brs-in-use %unused-branches% spec-lst)))
     )
     ;;put spec brs in use back, 4-18-90

;;;;;;;;;;;;; enable selections made by previous constraints
;(writeln "doing sel" (car extended-path))
  (set! selected-ent      ;;(cond ((result1))((result2)))
   (cond

   ((let* (
          (ent-lst (map (lambda(e) (item-name e)) (ents en)))
          (spec-name (car extended-path))
          (sel (project-on-attr %selections%
              (car (*get-related %selections% (list (list 'action 'select)
                                                (list 'from-spec sp))))
                                              'spec-ent)
          )
          (sel1 (when (not sel)
                 (project-on-attr %constraints%
                   (car (*get-related %constraints% (list
                             (list 'spec-ent1 'context)
                             (list 'from-spec1 spec-name)
                             (list 'action 'select)
                             (list 'from-spec2 sp))))  'spec-ent2)
                ))
          )
        (when (or
                 (member sel ent-lst)
                 (member sel1 ent-lst)
               )
          (set-current-item en gen-name)
          (if sel sel sel1)
        )
    ))
    (
        (let rep (
                   (cur-it (current-item? en))
                   (ent-lst (map (lambda(e) (item-name e)) (ents en)))
                 )
          (let* (
              (sels (*get-related %selections% (list (list 'action 'deselect)
                                                     (list 'from-spec sp))))
              (spec-ents (map (lambda(sel)
                              (project-on-attr %selections% sel 'spec-ent))
                           sels))
               )
          (set! ent-lst (difference ent-lst spec-ents))
         )
         (when ent-lst
           (writeln "select an entity from the following: " ent-lst)
           (set-current-item en gen-name)
           (let* (
                  (ent-selected
                      (if (null? (cdr ent-lst))
                          (car ent-lst)
                          (check-and-accept (read) ent-lst 'console)))
                   (is-ok? '())
                 )
               (if (not (is-in-entstr_base? ent-selected))
                  (begin
                     (inherit-attributes en gen-name ent-selected)
                     ent-selected)
                  (if (not (member $linksym (explode ent-selected)))
                     ent-selected
                  (let* (
                         (en-nm (symbol-append 'p: ent-selected))
                        )
                     (newline)
                     (eval `(load-entstr ,en-nm))
                     (display "==> is this correct? (y/n) ")
                     (set! is-ok? (equal? (read) 'y))
                     (newline)
                     (if is-ok?
                         ent-selected
                         (rep cur-it ent-lst))
                  );let
                );if
              );if
           );let
         );let
        );when
    )
   );cond
  );set
  (if (null? selected-ent)
    (error "invalid entity-structure: null specialization" sp)
    (begin
      (select-ent en  selected-ent sp)
      (set-current-item en selected-ent)
;;;;;;;new spec. go back to see if additional SES or PES    
      (prune-from-ent en set-attri extended-path)
      (if (and (item-attr-lst (cur? en)) set-attri)
        (for-each (lambda(e)
          (when (null? (cadr e))
             (writeln "value of attribute " (car e)
                   " attached to "(current-item? en) " : ")
             (add-attribute en (item-name (cur? en)) (car e) (read))
          ))
          (item-attr-lst (cur? en)))
      )          
;;;;;;;if still have specs go back
      (if (specializations en)
       (prune-from-ent en set-attri extended-path))
     );begin
   );if
  );when

;;;;;;;;;;;;end enable selections--choose an aspect

  (when (not (null? (aspects en)))
    (if (not (group-pruning? (item-attr-lst (cur? en)))) 
    ;;;;; if asp generated by group pruning , then quit  
      (begin
        (set! asp-lst (map (lambda(as)(item-name as)) (aspects en)))
        (writeln "select an aspect from the following: " asp-lst)
        (if (equal? (length asp-lst) 1)
          (select-asp en (car asp-lst))
          (select-asp en (check-and-accept (read)  asp-lst 'console))
        )
        (if (and (null? (member (item-mult-coup-type (cur? en))
                                 (range-mult-coup? en)))
              (equal? (item-sub-type (cur? en)) 'mult-asp))
          (begin
            (writeln "select an mult-coup-type from the following : "
                   (range-mult-coup? en))
            (set! (item-mult-coup-type (cur? en))
                  (check-and-accept (read) (range-mult-coup? en) 'console))
            (when (equal? (item-mult-coup-type  (cur? en)) 'controlled)
               (writeln "WARNING: you must have an atomic-model sibling
                         for this controlled-model to be valid")
            )

            (display "Delay pruning to runtime? (y/n) ")
            (if (equal? (read) 'y)
              (let (
                   (cu-nm (item-name (car (ents en))))
                   (en (eval en))
                   )
              (set! rp/gp 'r)    ;;; runtime pruning
              (cut-mult en cu-nm)

              )
              (begin

              ;; set out-in-coupling for broadcast and controlled models ;;
              ;; should take care of hypercube and cellular later on ;;

                (when (or (equal? (item-mult-coup-type (cur? en)) 'broadcast)
                          (equal? (item-mult-coup-type (cur? en)) 'controlled))
                 (writeln "enter out-in-couple as list of output-input port pairs")
                 (set-coupling en (cur? en) (read))
                )
                (if (equal? (item-mult-coup-type (cur? en)) 'tree)
                (mk-tree-and-prune en)
                  (begin
                   (writeln "do you want Grouping for multiple children? (y/n)")
                   (if (equal? 'y (read)) 
                     (begin
                      (set! rp/gp 'g)  ;;; group pruning
                      (grouping-and-prune en))))
                   )
                 )
               )
           ) ;begin
        );if
        (when (null? rp/gp)   ;;; general pruning
          (let (
               (asp-name (current-item? en))
               (entities (ents en))
               )
;;;;;; prune from each child of asp-name
            (for-each (lambda(e)(set-current-item en (item-name e))
                  (prune-from-ent en set-attri (cons asp-name extended-path)))
             entities)
           );let
          ) ; when general pruning
      );begin
    ); if not group pruning 
   ) ; when not null? aspects en
  ) ;let
 ) ;when
) ;define

;;; extract index from an indexed-name ;;;
;;; index returned as a symbol         ;;;
;;; may replaced by ex-base-name, etc  ;;;

(define (extract-index indexed-name)
   (let rep (
               (index '())
               (name (reverse (explode indexed-name)))
               (int (explode '1234567890)) ;;;;;;;;;;;
            )
      (if (or (not (member (car name) int)) (null? name))
          (implode (reverse index))
          (rep (append index (list (car name))) (cdr name) int)
      )
   )
)

;;; make entstr with indexed item-name, 5-15-90  ;;;
(define (mk-entstr-indexed en index)
  (let* (
        (index (if (integer? index)
                   (string->symbol (integer->string index 10))
                index))
        (en-nm (get-en-name en-mgr en))
        (en-ver-nm (symbol-append (get-en-name en-mgr en) index))
        (en-ver ())
        )
   (eval `(copy-entstr-in-core ,en  ,en-ver-nm))
   (set! en-ver (eval en-ver-nm))
   (set-current-item en-ver 'root-asp)
   (let (
         (it-nm (item-name (car (ents en-ver))))
        )
        (set! (item-name (car (ents en-ver)))
              (symbol-append
                 (subsymbol-to it-nm '<) index
                 (subsymbol it-nm
                    (symbol-length (subsymbol-to it-nm '<))
                    (symbol-length it-nm)
                 )
              )
           )
      )
      (set-current-item en-ver (item-name (car (ents en-ver))))
      (let rep (
                 (its (map (lambda(br) (branch-right br))
                          (out-branches en-ver)))
                 (prefix (current-item? en-ver))
               )
           (for-each (lambda(it)
              (set-current-item en-ver (item-name (branch-left
                                                (car (out-branches en-ver)))))
              (set! (item-name it)
                   (cond
                      ( (symbol-match (item-name it) '*-mult-asp)
                          (symbol-append prefix '-mult-asp))
                      ( (equal? 'spec (item-type it))
                           (symbol-append (item-name it) index))
                      ( (equal? 'asp (item-type it))
                          (symbol-append (item-name it) index))
                      ( (equal? 'ent (item-type it))
                          (let (
                               (it-nm (item-name it))
                               )
                             (symbol-append
                                (subsymbol-to it-nm '<)  index
                                (subsymbol it-nm
                                  (symbol-length (subsymbol-to it-nm '<))
                                  (symbol-length it-nm)
                                )
                           )))
                          ;  '<
                          ;  item-name parent-ent en-ver
                   )
               )) its)
           (for-each (lambda(it)
               (set-current-item en-ver (item-name it))
               (rep (map (lambda(br) (branch-right br))(out-branches en-ver))
                    (current-item? en-ver))
               ) its)
         )
     ;(dos-delete (string-append en-base (gen-en-fname en-ver)))
     (delete-en en-mgr (get-en-name en-mgr en-ver))
     (for-each (lambda(it)
        (set-current-item en-ver (item-name it))
        (when (and (equal? 'asp (item-type it))
                   (not (equal? 'mult-asp (item-sub-type it)))
                   (item-coupling it))
           (adjust-couple en-ver))
;        (when (item-sel-constraint it)
;           (adjust-sel-constaints en-ver))
        (when (and (equal? 'asp (item-type it))
                   (not (equal? 'mult-asp (item-sub-type it)))
                   (item-priority-list it))
           (adjust-priority en-ver))
     ) (items? en-ver))
     en-ver
 )
)

;;; extended to handle indexed entities 5-15-90

(define (add-entstr-at-leaf en leaf-ent leaf-nm)
  (set-current-item en leaf-ent)
   (let* (
          (index (extract-index leaf-nm))
          (leaf-base-nm (ex-base-name leaf-nm))
          (en-nm (symbol-append 'e: leaf-base-nm))
          (entstr (if (member en-nm (get-tmp:lst en-mgr)) (eval en-nm)
                      (load-en leaf-base-nm)));;leaf-nm is how to get entstr
          (parent-items (map (lambda(br)(item-name (link-left br))) 
                        (in-branches en)))
          (tmp-en-nm 'e@tmp)
          (tmp-en ())
         )
       (eval `(copy-entstr-in-core ,entstr ,tmp-en-nm))
       (set! tmp-en  (if (> (symbol-length index) 0) ;; index exists
                         (mk-entstr-indexed (eval tmp-en-nm) index)
                         (eval tmp-en-nm)))
       (change-root tmp-en leaf-nm leaf-ent);; adjust the root-name to be leaf-ent
       (delete-sub-entstr1 en leaf-ent)
      ; (add-sub-entstr en tmp-en)
       (let loop (
                 (pars parent-items)
                 )
         (set-current-item en (car pars))
          (cond
            ((= (length pars) 1)
             (add-sub-entstr en tmp-en)
            ;(dos-delete (string-append en-base (gen-en-fname tmp-en))) 
             (delete-en en-mgr tmp-en-nm))
             (else  (add-item en ent leaf-ent) 
                    (loop (cdr pars))) 
        ) 
       ) 
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


(define (cut-mult p:en ent-cut)
     (set-current-item p:en ent-cut)
     (extract-sub-entstr p:en (symbol-append 'e: ent-cut))
     (delete-sub-entstr p:en ent-cut)
     (add-item p:en ent ent-cut)
     (save-entstr (eval (symbol-append 'e: ent-cut))) ;;;;;;;;
     (writeln "ent " ent-cut " was made a leaf")
)

;;; 7-30-90
;;; 7-30-90
;;; add save-en in (prune1 en)
;;; use copy-entstr-in-core in adjust-en-name

(define (prune1 en) 
   (let* (
           (items (map (lambda(it) (copy-item it)) (items? en)))
           (branches (map (lambda(br) 
                       (make-branch 'left (car (member (branch-left br) items))
                                    'right (car (member (branch-right br)items))
                     )) (branches? en)))
           (tmp-en-name 'p@tmp)
           (ext (begin (display "give extension for pruned-entstr name : ")
                       (symbol-append $linksym (read))))
           (prun-en-nm ())
        )
      (eval
         `(begin
            (define ,tmp-en-name (entity-structure))
            (set-items ,tmp-en-name ',items)
            (set-branches ,tmp-en-name ',branches)
            (add-spec-and-prune ,tmp-en-name)
            (clean-entstr ,tmp-en-name)
          )
      )
    (writeln #\newline "save the pruned entity structure? (y/n) ")
    (if (equal? (read) 'y)
      (begin
      (set! prun-en-nm (adjust-en-name (eval tmp-en-name) ext))
      (save-en (eval prun-en-nm)) ;; 7-30-90
      (add-p:lst en-mgr prun-en-nm)
      (add-tmp:lst en-mgr prun-en-nm)
      (set! p@tmp 0)
      (display-window 'console #\newline "Pruned entstr P:"
                            (lowcase
                               (subsymbol prun-en-nm   2
                                   (symbol-length prun-en-nm)))
                            " made.")
      )
      (writeln #\newline "temporary pruned entity structure in p@tmp")
   )
 (gc)
)
)


;;;;; file-nm can be passed for pruning with file ;;; 2-15-89
(define prune 
  (lambda(en . file-nm)
   (let (
          (en-fname (gen-en-fname en))
        )
     (when (not (file-exists? (string-append en-base en-fname)))
        (display "Do you want to save the original entstr in a file? (y/n) ")
       (when (equal? 'y (read)) (save-en en))
     )
     (if file-nm  ;;;; check file name for pruning with file ;;;;
        (let* (
              (f-nm (if (string? (car file-nm)) 
                       (car file-nm)
                       (error "file name should be string" (car file-nm))))
              (fi (open-input-file f-nm))
              )
            (set-fluid! input-port fi)
            (prune1 en)
            (close-input-port fi)
            (set-fluid! input-port 'console)
       )
       (prune1 en)
   )
 )
))

;;; 7-30-90
(define (adjust-en-name p:en-with-tmp-name extension)
   (let* (
          (root-nm ())
          (p:en-name ())
          (file-nm ())
          (all-p:ens (dir-enbase))
        )
      (set-current-item p:en-with-tmp-name 'root-asp)
      (set! root-nm (item-name (car (ents p:en-with-tmp-name))))
      (set! root-nm (adjust-root-name root-nm))
      (set! p:en-name (symbol-append root-nm extension))
      (set! file-nm (string-append (symbol->string p:en-name) ".P"))
      (if (member file-nm all-p:ens)
          (set! p:en-name  (symbol-append (symbol-append root-nm $linksym)
             (begin
                (writeln  #\newline  "!!!! "
                          (symbol-append 'p: p:en-name)
                          " is already existing !!!!")
                (writeln "existing pruned entstr's : "
                         (p:ens-with-root-nm root-nm))
                (display "give extension name again : ")
                (read)))))
      (set! p:en-name (symbol-append 'p: p:en-name))
      (eval `(copy-entstr-in-core ,p:en-with-tmp-name ,p:en-name))
;;;      (eval `(define ,p:en-name ,p:en-with-tmp-name))  ;;;does not save
      p:en-name
   )
)

;;;;; 8-25-89
(define (change-root en root new-root)
(set-current-item en root)
(let (
     (cur (cur? en))
     )
(set! (item-name cur) new-root)
(for-each (lambda(aspect)
   (if (and (not (equal? (item-sub-type aspect) 'mult-asp))
            (item-coupling aspect))
     (replace-coupling en aspect root new-root)))
              (aspects en))
))

(define (adjust-root-name root-name) ;;strips a_b_c@d down to c
   (let* (
         (rev (implode (reverse (explode root-name))))
         (rev-name (subsymbol-to rev '_))
         (root-name (implode (reverse (explode rev-name))))
         )
       (if (member (symbol->string root-name) (dir-enbase))
           (subsymbol-to root-name $linksym)
           root-name
       )
   )
)
             
;;;;; end 8-25-89
;; make tree for multiple children and prune entstr ;;
(define (mk-tree-and-prune en)
   (writeln "give levels and branches for tree of children "
            "as list of two integers pairs")
   (let* (
           (child-name (item-name (branch-right (car (out-branches en)))))
           (parent-name (item-name (branch-left (car (in-branches en)))))
           (multchildren-tree (bi-tree))
           (le&br (read))
           (levels (car le&br))
           (branches (cadr le&br))
          )
      (mk-tree multchildren-tree child-name levels branches)
      (add-attribute en parent-name 'mulch-tree multchildren-tree)
      (add-attribute en parent-name 'levels levels)
      (add-attribute en parent-name 'branches branches)
      (grouping-and-prune en)
   )
)

;; make multiple children tree with name child-name ;;
(define (mk-tree multchildren-tree child-name levels branches) 
  (let* (
          (children '())
        )
       (set! children
         (let rep ( 
                 (num-ch (1+ (/ (* branches (-1+ (expt branches levels))) 
                             (-1+ branches)))) 
                 (num 0) (ch-lst '()) 
                  ) 
            (if (>= num num-ch) 
               ch-lst
              (rep num-ch 
                  (1+ num) 
                  (append ch-lst (list (gen-name name-ctr child-name)))
              ) 
            )   
          )
        )
        (set-root multchildren-tree (cons (car children) (list 0 0)))
        (let rep1 (
                   (ch-left (cdr children))
                   (num-lev 1)
                   (num-ch 0)
                  )
           (when ch-left
              (for-each (lambda(leaf)
                 (bi-set-current multchildren-tree leaf)
                 (let rep2 ((num-br 0))
                     (when (<? num-br branches)
                        (bi-add multchildren-tree 
                          (cons (car ch-left) (list num-lev num-ch)))
                        (set! num-ch (1+ num-ch))
                        (set! ch-left (cdr ch-left))
                        (rep2 (1+ num-br))
                     )
                  )
              ) (reverse (leaves? multchildren-tree)))
              (rep1 ch-left (1+ num-lev) 0)
          ) 
      )
   )
)

;; print tree with level ;;
(define (print-multchildren-tree children-tree group-table)
  (define (parent-node bid-tree node)
     (if (equal? (root? bid-tree node) node)
         '()
         (begin
            (bi-set-current bid-tree node)
            (let rep (
                      (succ (bi-successors? bid-tree))
                      (child-level (cadr node))
                     )
                (if (< (cadar succ) child-level)
                    (car succ)
                    (rep (cdr succ) child-level)
                )
            )
         )
      )
  )
  (define (children-node bid-tree node)
     (bi-set-current bid-tree node)
     (if (equal? (show-root bid-tree) node)
         (bi-successors? bid-tree)
         (remove (parent-node bid-tree node) (bi-successors? bid-tree))
     )
  )
  (if (bi-nodes? children-tree)
      (begin
         (display-window 
             'console 
             (car (show-root children-tree))
             (make-string 5 #\space)
             (cdr (show-root children-tree))) 
         (let (
                (group (table-look-up 
                          group-table (car (show-root children-tree))))
              )
             (when group
                 (display-window 'console " ===> Group " group))
         )   
         (newline)
         (let rep (
                   (chs (children-node children-tree (show-root children-tree)))
                  )
             (when chs
               (display-window 
                 'console 
                 (make-string (cadar chs) #\-)
                 (caar chs)
                 (make-string 
                    ( - (+ 5 (print-length (car (show-root children-tree))))
                        (print-length (caar chs)))
                    #\space)
                 (make-string (cadar chs) #\space) 
                 (cdar chs))
               (let (
                     (group (table-look-up group-table (caar chs)))
                    )
                  (when group
                     (display-window 'console " ===> Group " group))
               )   
               (newline)
               (for-each (lambda(e) (rep (list e))) 
                 (children-node children-tree (car chs)))
               (rep (cdr chs))
           )
        )
     )
     (writeln "Children tree is empty")
    )
)

;;; grouping and prune entstr ;;;
(define (grouping-and-prune en)
   (writeln "give number of Groups for multiple children: ")
   (let* (
           (g-num (read ))
           (mult-coup-type (item-mult-coup-type (cur? en)))
           (coupling (item-coupling (cur? en)))
           (mult-asp-name (current-item? en))
           (parent-name (item-name (branch-left (car (in-branches en)))))
           (child-name  (item-name (branch-right (car (out-branches en)))))
           (asp-name (symbol-append parent-name '-asp))
           (en-group '())
           (en-table (table))
           (group-table (table))
        )
        (add-attribute en parent-name 'num-groups g-num)
        (set-current-item en child-name) 
        (let rep (
                  (num g-num)
                  (extracted-en (extract-sub-entstr en 'e:@sub)) 
                  (en-nm (gen-name ent-nm-ctr 'e:@sub))
                 )
              (when (> num 0)
                 (set! en-group 
                    (append en-group 
                       (begin
                          (eval `(copy-entstr-in-core ,extracted-en ,en-nm)) 
                          (list (eval en-nm)))))
                 (rep (-1+ num) extracted-en (gen-name ent-nm-ctr 'e:@sub))
              )
        )      
       (delete-sub-entstr1 en mult-asp-name)
       (set-current-item en parent-name)
       (message-mode-off)
       (add-item en 'asp asp-name)
       (set-current-item en asp-name)
       (set! (item-sub-type (cur? en)) 'mult-asp)
       (set! (item-mult-coup-type (cur? en)) mult-coup-type)
       (set! (item-coupling (cur? en)) coupling)
       (message-mode-on)
       (writeln "each of " g-num " Group(s) will be pruned")
       (newline)
       (set! g-num 1)
       (for-each (lambda(en1)
          (select-root en1 child-name)
          (writeln "prune for Group " g-num)
          (newline)
          (add-spec-and-prune en1)
          (newline)
          (if (equal? mult-coup-type 'tree)
             (let (
                   (ch-tree (get-attribute-value en parent-name 'mulch-tree))
                   (ch-lst '())
                  )
                 (newline)
                 (print-multchildren-tree ch-tree group-table)
                 (newline)
                 (writeln "give list of children (or type rest) in Group " 
                           g-num " with root-name: "
                          (begin (set-current-item en1 'root-asp)
                            (item-name (car (ents en1)))))
                 (set! ch-lst 
                    (let ( (ch-list (read)) )
                      (if (equal? ch-list 'rest) '(rest) ch-list)))
                 (for-each (lambda(e)                
                    (table-insert-pair en-table e en1)
                 )  ch-lst)
                 (for-each (lambda(e)
                    (table-insert-pair group-table e g-num)
                 )  ch-lst)
                 (if (equal? g-num (length en-group))
                     (add-children-in-tree en ch-tree en-table))
             )
             (begin
                (writeln "give number of members in Group " g-num
                         " with root-name : "
                    (begin (set-current-item en1 'root-asp)
                          (item-name (car (ents en1))))
                )
                (add-sub-entstrs en en1 (read))
             )
          )
          (set! g-num (1+ g-num))
          (newline)
          ) en-group)
       (for-each (lambda(en1)
         ; (dos-delete (string-append en-base (gen-en-fname en1)))
          (delete-en en-mgr (get-en-name en-mgr en1))
       ) en-group)
       (delete-en en-mgr 'e:@sub)
       (set-current-item en parent-name)
   )
)

;(define (attach-num-mult-children en )
;   (writeln "give number of mult-children : ")
;   (let (
;          (parent-name (item-name (branch-left (car (in-branches en)))))
;          (num-mult (read ))
;        )
;      (writeln "uniform mult-children or general mult-children (u/g)?")
;      (if (equal? 'u (read ))
;         (begin
;            (add-attribute en parent-name 'num-groups num-mult)
;            (prune-from-ent en  '()))
;         (mult-asp->asp en (current-item? en) num-mult)
;      )
;    )
;)

;; add pruned sub-entstr in the multiple entity ;;
(define (add-children-in-tree en ch-tree en-table)
   (let (
          (ch-lst (reverse (map (lambda(e) (car e)) (bi-nodes? ch-tree))))
          (en-table1 (table))
        )
      (for-each (lambda(e)
         (table-insert-pair en-table1 e
            (let ( (en1 (table-look-up en-table e)))
               (if en1 en1 (table-look-up en-table 'rest))))    
      ) ch-lst)
      (for-each (lambda(e)
         (add-sub-entstr en (mk-entstr-version (table-look-up en-table1 e)))
      ) ch-lst)
   )
   ;; coupling scheme ;;
   (let (
          (int-coup '())
          (ext-coup '())
        )
      (writeln "enter out-in-couple as list of "
               "influencee-output-input port triples")
      (set! int-coup (read))
      (writeln "enter external couplings as list of "
               "ext-inp-coup and ext-out-coup pairs")
      (set! ext-coup (append '(ext-coup) (read)))
      (set-coupling en (cur? en) (append int-coup (list ext-coup)))
    )
)

;;; make multiple children for all multiple entities ;;;
;;; items list are already sorted form root to leaf by clean-entstr ;;;

(define (make-mult-asp-to-asp en)
   (let rep (
              (items (reverse (items? en)))  
            ) 
        (when items
           (when (symbol-match (item-name (car items)) '*-mult-asp)
               (set-current-item en (item-name (car items)))
               (mult-asp->asp en (item-name (car items)) 
                   (get-attribute-value en (item-name(parent-ent en)) 
                      'num-groups))
           )
           (rep (cdr items))
        )
   )
)     

;;; change mult-asp to asp with specified children number ;;;
;;; change mult-asp to asp with specified children number ;;;
;;; mult-coup-type will be inherited from mult-asp to new asp ;;;

(define (mult-asp->asp en mult-asp-name #-chs)
   (set-current-item en mult-asp-name)
   (let* (
           (mult-coup-type (item-mult-coup-type (cur? en)))
           (parent-name (item-name (branch-left (car (in-branches en)))))
           (child-name  (item-name (branch-right (car (out-branches en)))))
           (asp-name (symbol-append parent-name '-asp))
           (extracted-en 0)
         )
       (message-mode-off)
       (set-current-item en child-name)
       (add-attribute en parent-name 'num-groups #-chs)
       (set! extracted-en (extract-sub-entstr en 'e:@sub))
       (delete-sub-entstr1 en mult-asp-name)
       (set-current-item en parent-name)
       (add-item en 'asp asp-name)
       (set-current-item en asp-name)
       (set! (item-sub-type (cur? en)) 'mult-asp)
       (set! (item-mult-coup-type (cur? en)) mult-coup-type)
       (add-sub-entstrs en extracted-en #-chs)
       (message-mode-on)
       (delete-en en-mgr 'e:@sub)
       en
  )
)


(define (add-sub-entstrs en sub-en how-many)
    (let rep (
               (num how-many)
             )
       (when (> num 0)   
          (add-sub-entstr en (mk-entstr-version sub-en))
          (rep (-1+ num))
       )
    )
)

;;; copy entstr whose item-name has version number ;;;
(define (mk-entstr-version e:en)
   (clean-entstr e:en)
   (let* (
          (e:en-ver (gen-name ent-nm-ctr 
                    (symbol-append (get-en-name en-mgr e:en) '@v)))
         )
      (eval `(copy-entstr-in-core ,e:en ,e:en-ver))
      (set! e:en-ver (eval e:en-ver))
      (set-current-item e:en-ver 'root-asp)
      (let ((it-nm (item-name (car (ents e:en-ver)))))
           (set! (item-name (car (ents e:en-ver))) 
              (symbol-append
                 (gen-name ent-nm-ctr (subsymbol-to it-nm '<))
                 (subsymbol it-nm
                    (symbol-length (subsymbol-to it-nm '<))
                    (symbol-length it-nm)
                 )
              )
           )
      )
      (set-current-item e:en-ver (item-name (car (ents e:en-ver))))
      (let rep (
                 (its (map (lambda(br) (branch-right br)) 
                          (out-branches e:en-ver)))
                 (prefix (current-item? e:en-ver))
               )
           (for-each (lambda(it)
              (set-current-item e:en-ver (item-name 
                  (branch-left (car (out-branches e:en-ver)))))
              (set! (item-name it)
                   (cond
                      ( (symbol-match (item-name it) '*-mult-asp)
                          (symbol-append prefix '-mult-asp))
                      ( (equal? 'spec (item-type it))
                          (gen-name ent-nm-ctr (item-name it)))
;                          (symbol-append prefix '-spec))
                      ( (equal? 'asp (item-type it))
                          (gen-name ent-nm-ctr (item-name it)))
;                          (symbol-append prefix '-asp))
                      ( (equal? 'ent (item-type it))
                          (symbol-append 
                            (subsymbol-to (item-name it) '<) 
                            '<
                            (item-name (parent-ent e:en-ver))))
                   )
               )) its)
           (for-each (lambda(it)
               (set-current-item e:en-ver (item-name it))
               (rep (map (lambda(br) (branch-right br))(out-branches e:en-ver))
                    (current-item? e:en-ver))
               ) its)
         )
    ; (dos-delete (string-append en-base (gen-en-fname e:en-ver)))
     (delete-en en-mgr (get-en-name en-mgr e:en-ver))
     (for-each (lambda(it)
        (set-current-item e:en-ver (item-name it))
        (when (and (equal? 'asp (item-type it)) 
                   (not (equal? 'mult-asp (item-sub-type it)))
                   (item-coupling it))
           (adjust-couple e:en-ver))
;        (when (item-sel-constraint it)
;           (adjust-sel-constaints e:en-ver))
        (when (and (equal? 'asp (item-type it))
                   (not (equal? 'mult-asp (item-sub-type it)))
                   (item-priority-list it))
           (adjust-priority e:en-ver))
     ) (items? e:en-ver))
     e:en-ver
    )
)

;; in enpeprun.s
;; adjust entity names with version number ;;
;; current item of e:en is of type aspect  ;;
;; 3-21-90 stop add-couple loop testing when new-ents is null
;; 3-22-90 use an entity's base name for coupling adjustment
;; 7-11-90 check subsymbol to "<" for coupl

(define (adjust-couple e:en)
   (let (
          (parent-ent (item-name (parent-ent e:en)))
          (children-ents (map (lambda(it) (item-name it))(ents e:en)))
          (coupling (item-coupling (cur? e:en)))
         )
       (set-coupling e:en (cur? e:en) '())
       (for-each (lambda(coupl)
          (add-couple e:en
             (let rep1 ((new-ents (append (list parent-ent) children-ents)))
                 (when (not (null? new-ents)) ;; stop recursive calls
                    (if (or
                        (equal? (base-name (subsymbol-to (car new-ents) '<))
                                (base-name (link-left coupl)))
                        (equal? (base-name (subsymbol-to  (car new-ents) '<))
                                (base-name (subsymbol-to (link-left coupl) '<)))
                        (equal? (base-name (subsymbol-to  (car new-ents) '_))
                                (base-name (subsymbol-to (link-left coupl) '_))))
                                ;; "_" may be added in spec selection

                      (car new-ents)
                      (rep1 (cdr new-ents)))))
             (let rep2 ((new-ents (append (list parent-ent) children-ents)))
                 (when (not (null? new-ents))
                    (if (or
                        (equal? (base-name (subsymbol-to (car new-ents) '<))
                                (base-name (link-right coupl)))
                        (equal? (base-name (subsymbol-to (car new-ents) '<))
                                (base-name (subsymbol-to (link-right coupl) '<)))
                        (equal? (base-name (subsymbol-to (car new-ents) '_))
                                (base-name (subsymbol-to (link-right coupl) '_))))

                      (car new-ents)
                      (rep2 (cdr new-ents)))))
             (car (link-port-pairs coupl)) (cdr (link-port-pairs coupl))
          )
       ) coupling)
    )
)


;; adjust selection constraints with correct entity names ;;
(define (adjust-sel-constaints en)
   (let (
          (children-ents (map (lambda(it) (item-name it))(ents en)))
          (all-ents (map (lambda(it) (item-name it)) (items? en)))
         )
       (let rep1 (
                   (sel-constr (item-sel-constraint (cur? en)))
                 )
          (when sel-constr
             (delete-sel-constraint en (item-name (cur? en)) (car sel-constr))
             (add-sel-constraint en (item-name (cur? en))
                (let rep2 (
                            (old-const (car sel-constr))
                            (new-const '())
                            (ref-nm 0)
                          )
                   (if (not old-const)
                      new-const
                      (begin
                        (set! new-const
                          (append new-const (list
                           (case ref-nm
                             (0 (find-match-name (car old-const) children-ents))
                             (1 (item-name (cur? en)))
                             (2 (car old-const))
                             (3 (find-match-name (car old-const) all-ents))
                             (4 (find-match-name (car old-const) all-ents))
                           )
                         )))
                         (rep2 (cdr old-const) new-const (+ 1 ref-nm))
                      )
                   )
                )
              )
              (rep1 (cdr sel-constr))
          )
       )
    )
)

;; adjust priority list attached to aspect under entity for coupled model ;;
(define (adjust-priority e:en)
   (let (
          (old-prio-lst (item-priority-list (cur? e:en)))
          (new-prio-lst '())
          (new-nm (map (lambda(it) (item-name it))(ents e:en)))
         )
      (for-each (lambda(e)
        (set! new-prio-lst
           (append new-prio-lst (list (find-match-name e new-nm))))
     ) old-prio-lst)
     (add-priority e:en new-prio-lst)
   )
)

;; find matched ent name from ents list ;;
(define (find-match-name nm nm-lst)
   (let rep (
             (lst nm-lst)
            ) 
     (if (symbol-match (car lst) (symbol-append nm '*))
        (car lst)
        (rep  (cdr lst))
      )
   )
)

;; evaluate selection constraints attached to all spec entities ;;
(define (eval-sel-constraints en)
   (for-each (lambda(it)
      (if (item-sel-constraint it)
          (for-each (lambda (constr)
             (eval `(add-constraints$ ,en ',constr) user-initial-environment)
          ) (item-sel-constraint it))
      )
   ) (items? en))
)
      
;;;;;;;;;;;;;;;;; end of Addition ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (is-in-model_base? ent-name)
   (let* (
           (ent-nm (symbol->string ent-name))
           (ent.m (string-append ent-nm ".M"))
           (ent.fm (string-append ent-nm ".FM"))
           (models (dos-dir (string-append mo-base "*.*")))
         )
      (or (member ent.m models) (member ent.fm models))
   )
)

(define (p:ens-with-root-nm root-nm)
   (map (lambda(e)
      (string-append "P:" (substring e 0 (- (string-length e) 2))))
   (is-in-entstr_base? root-nm))
)

(define (is-in-entstr_base? ent-name)
   (ent->pruned-en-files ent-name)
)

(define (ent->pruned-en-files ent-name)
   (let (
          (prun-ens (dos-dir (string-append en-base "*.P")))
        )
      (clean 
         (map (lambda(prun-en)
            (if (name-match? ent-name prun-en) prun-en)) prun-ens))
   )
)

(define (name-match? ent-name prun-en-file)
   (let* (                          
           (ent-nm (symbol->string (symbol-append ent-name $linksym)))
           (len (string-length ent-nm))
         )
      (if (> len (string-length prun-en-file))
          #!false
          (substring=? ent-nm 0 len prun-en-file 0 len)
      )
   )
)  


;;;;;; 8-25-89

(define (load-en ent-name)
(let (
        (fi (string-append en-base (symbol->string ent-name) ".e"))
        (en (entity-structure))
        (entstr-name (symbol-append 'e: ent-name))
        (pt 0)
      )
(when (file-exists? fi)
(set! pt (open-input-file fi))
(eval `(restore-entstr ,en (read ,pt)) user-initial-environment)
(close-input-port pt)
(eval `(define ,entstr-name ,en)user-initial-environment)
(add-tmp:lst en-mgr entstr-name)
en
)))

(define (is-entstr ent-name)
(file-exists?  (string-append en-base (symbol->string ent-name) ".e"))
)

;;; extended to handle indexed entities, 5-16-90 ;;;

(define (add-spec&ents-at-leaf en leaf-ent)
(define (true-name name-dot-p)       ;;extract true name when insert in entstr
(if (symbol-match name-dot-p '*.p)
 (let (
      (rev-lst (reverse (explode name-dot-p)))
      )
(implode (reverse (cddr rev-lst)))
 )
 name-dot-p
))
   (let* (
           (ent-spec (symbol-append leaf-ent '_pes-spec))
           (leaf-nm  (base-name (subsymbol-to leaf-ent '_)))
           (file-nms (ent->pruned-en-files leaf-nm))
           (ents (map (lambda(e) (true-name (string->symbol e))) file-nms))
         )                        ;;;here
      (set-current-item en leaf-ent)
      (if (specializations en)
         (begin
          (delete-sub-entstr1 en leaf-ent)   ;;; delete other specs, asps ???
          (add-item en ent leaf-ent)
          (set-current-item en leaf-ent)
         )
      )
      (add-item en spec ent-spec)
      (set-current-item en ent-spec)
      (for-each (lambda(e) (add-item en 'ent e)) ents)
   )
)


(define (get-versions-of ent-name)
(define (true-name name-dot-p)       ;;extract true name when insert in entstr
(if (symbol-match name-dot-p '*.p)
 (let (
      (rev-lst (reverse (explode name-dot-p)))
      )
(implode (reverse (cddr rev-lst)))
 )
 name-dot-p
))
   (let* (
           (file-nms (ent->pruned-en-files ent-name))
           (ents (map (lambda(e) (string->symbol (lowcase (true-name (string->symbol e)))))
                       file-nms))
           (vers     (map (lambda(e) (symbol-append 'p: e)) ents))
         )
vers
   )
)

(define (show-versions-of ent-name)
(display (get-versions-of ent-name))
)

;;;;;; end 8-25-89 

(define print-ent 
  (lambda(en . options)
    (if (equal? '() (branches? en))
       (writeln "Entity-structure is empty")
       (let (
              (return-to (current-item? en))
            )
          (set-current-item en 'root-asp)
          (print-item en (item-name (car (ents en))) "-" options)
          (set-current-item en return-to)
          (writeln "end of display")
       )
    )
  )
)

;; options: [ -a -c -o -s -p ] ;;
;; 
;; if -a is in options, attributes will not be printed
;; if -c is in options, coupling will not be printed
;; if -o is in options, out-in-coup will not be printed
;; if -s is in options, sel-constraint will not be printed
;; if -p is in options, priority-list will not be printed
(define (print-item en item-nm space options)
(set-current-item en item-nm)
(let (
     (item (cur? en))
     )
(display-window 'console space (item-type item) " : " item-nm )
(when (equal? (item-sub-type item) 'mult-asp)
    (display-window 'console "  ,mult-coup-type -> " 
                                     (item-mult-coup-type item))
)
(when (and (equal? (item-type item) 'asp) (not (member '-p options))
           (item-priority-list item))
    (display-window 'console  " ,priority-list -> "  (item-priority-list item))
)
(if (and (item-coupling item) (not (member '-c options))
    (or (equal? (item-type item) asp) (equal? (item-sub-type item) 'mult-asp)))
  (if (vector? (car (item-coupling item))) 
      (display-window 'console  "  ,coupling -> " 
          (print-coup (item-coupling item)))
      (if (not (equal? (item-mult-coup-type item) 'tree))
         (display-window 'console  "  ,out-in-coup -> " 
             (item-coupling item))
         (let (
                (int-coup (clean (map (lambda(e)
                   (if (not (equal? 'ext-coup (car e))) e)) 
                   (item-coupling item))))
                (ext-coup (car (clean (map (lambda(e)
                   (if (equal? 'ext-coup (car e)) e))
                   (item-coupling item)))))
              )  
            (display-window 'console  "  ,out-in-coup -> " int-coup)
            (display-window 'console  "  ,ext-inp-couple -> " (cadr ext-coup))
            (display-window 'console  "  ,ext-out-couple -> " (caddr ext-coup))
         )
      )
   )
)
(when (and (equal? (item-type item) 'spec) (not (member '-s options))
           (item-sel-constraint item))
    (display-window 'console "   ,sel constraints -> " (item-sel-constraint item))
)
(when (and (equal? (item-type item) 'ent) (not (member '-a options))
           (item-attr-lst item))
    (display-window 'console "  ,attributes -> " 
       (clean (map (lambda(e) (if (not (equal? 'mulch-tree (car e))) e))
           (item-attr-lst item))))
)
(newline)
(for-each (lambda(br)(print-item en (item-name (branch-right br))
                         (string-append "-" space) options)) (out-branches en))
))


(define (print-coup coup)
(map (lambda(lk)(list (link-left lk) (link-right lk)
                  (link-port-pairs lk))) coup)
)










