;;;;; enprimit.s

;;;;; 3-15-90 new axioms violation testing procedures
;;;;;      1. still use original (axiom-violated?)
;;;;;      2. use (test-axioms) for advanced testing
                      
(define (axiom-violated? cur-item items-lst new-type new-name)
   (cond ((not (mode-alternating? (item-type cur-item) new-type))
            (display "Violate alternating mode AXIOM"))
;         ((not (valid-brothers/strict-hierarchy? items-lst new-name))
;            (display "Violate either valid brothers or strict hierarchy AXIOM"))
         (else #!false)
   )
)
          

;(define (axiom-violated? en cur-item  items-list new-type new-name)
;    ;; note added en
;    ;; change (add-item) in enmodul.s to be compatible
;   (cond 
;      ( (not-mode-alternating? (item-type cur-item) new-type new-name))
;;;            (display "Violate alternating mode AXIOM"))
;      ( (not-valid-brothers? en new-name))
;;;            (display "Violate valid brothers AXIOM"))
;     ( (not-strict-hierarchy? en items-list new-name cur-item))
;;;            (display "Violate strict hierarchy AXIOM"))
;      (else #!false)
;   )
;)

(define (not-mode-alternating? cur-type new-type new-name)
  (when (not (mode-alternating? cur-type new-type))
     (writeln "ALTERNATING MODE VIOLATION " new-name)
     #t
  )
)

(define (mode-alternating? cur-type new-type) 
   (cond ((equal?  'ent cur-type)
             (or (equal? 'asp new-type) (equal? 'spec new-type)))
         ((equal? 'asp cur-type) 
             (equal? 'ent new-type))
         ((equal? 'spec cur-type)
             (equal? 'ent new-type))
   )
)

(define (not-valid-brothers? en new-name)
 (when (member new-name
       (map (lambda(br)(item-name (branch-right br))) (out-branches en))
      )
 (writeln "VALID BROTHERS VIOLATION " new-name)
 #t)
)


(define (not-strict-hierarchy? en items-list item-nm cur)
(when (find-item items-list item-nm)
(begin0
(test-strict en (item-name cur) item-nm '())
(set-current-item en (item-name cur))
)))

(define (test-strict en  cur-nm item-nm so-far-list)
(when (not (equal? cur-nm 'root-asp))
(set-current-item en cur-nm)
(let  (
      (pars  ;; parents
           (map (lambda(br) (item-name (branch-left br))) (in-branches en))
           )
      )
(cond
  ((not (difference pars so-far-list)) '())
  ((member item-nm pars) (writeln "STRICT HIERARCHY VIOLATION " item-nm) #t)
  (else (let (
             (results (map (lambda(par)(test-strict en  par item-nm
                      (union2 so-far-list pars))) pars)
               )
             )
         (eval `(or ,@results))
         )
  )
))))

(define (not-strict-hier en)
(let loop (
          (its (items? en))
          )
(cond
   ((null? its) '())
   ((begin (set-current-item en (item-name (car its)))
        (< (length (in-branches en)) 2))
         (loop (cdr its)))
   ((test-strict en  (item-name (car its))(item-name (car its))
               '()))
   (else (loop (cdr its)))
)))

(define (not-valid-broth en)
(let loop (
          (its (items? en))
          )
(cond
   ((null? its) '())
   ((begin (set-current-item en (item-name (car its)))
     (let* (
            (chs
              (map (lambda(br) (item-name (branch-right br)))
                  (out-branches en))
             )
            )
           (< (length (remove-mult chs))(length chs))
      )) 
       (writeln "VALID BROTHERS VIOLATION "  (current-item? en))
       #t)
   (else (loop (cdr its)))
)))

(define (not-alternate en)
(let loop (
          (its (items? en))
          )
(cond
   ((null? its) '())
   ((begin (set-current-item en (item-name (car its)))
     (let*  (
           (chs
             (map (lambda(br) (branch-right br))
                  (out-branches en))
             )
           (results (map (lambda(ch)
                     (not (mode-alternating?
                            (item-type (cur? en)) (item-type
                                       ch)))) chs)
              )
             )
             (eval `(or  ,@results))
          )
       ))
       (else (loop (cdr its)))
)))


(define (test-axioms en)
(cond
     ((not-alternate en)(display "!!! ALTERNATING MODE VIOLATION !!!"))
     ((not-valid-broth en)(display "!!! VALID BROTHERS VIOLATION !!!"))
     ((not-strict-hier en)(display "!!! STRICT HIERARCHY VIOLATION !!!"))
     (else (display "axioms satisfied"))
))



;;;;;;; end 3-13-90

(define (remove-branch en br)
(set-branches en (remove br (branches? en)))
)        

(define   (in-branches en)
              (let scan (
                        (elist (branches? en))
                        (olist '())
                         )
                            (if (null? elist)
                                olist

                              (if (equal? (branch-right (car elist))
                                          ( cur? en) )
                                  (scan (cdr elist) (cons (car elist)
                                                                  olist) )
                                  (scan (cdr elist) olist)
                              )
                            )

                          )
)


(define   (out-branches en)
              (let scan (
                        (elist (branches? en))
                        (olist '())
                         )
                            (if (null? elist)
                                olist

                              (if (equal? (branch-left (car elist))
                                          ( cur? en) )
                                  (scan (cdr elist) (cons (car elist)
                                                                  olist) )
                                  (scan (cdr elist) olist)
                              )
                            )

                          )
)

(define (ents? en)
(clean (map (lambda(it)(if (equal? (item-type it) ent) it)) (items? en)))
)

(define (copy-item struct-item)
   (make-item 'type (item-type struct-item)
              'name (item-name struct-item)
              'attr-lst (item-attr-lst struct-item) 
              'mult-coup-type (item-mult-coup-type struct-item)
              'coupling 
                  (let ((coups (item-coupling struct-item)))
                    (if (pair? coups)
                       coups
                       (map (lambda(coup)
                          (make-link 'left (link-left coup)
                                     'right (link-right coup)
                                     'port-pairs (link-port-pairs coup)))
                     coups)))
              'sub-type (item-sub-type struct-item)
              'sel-constraint (item-sel-constraint struct-item) 
              'priority-list (item-priority-list struct-item)
   )
)


(define (aspects en)
(let (
     (obr (out-branches en))
     )
(clean (map (lambda(br)
        (if (equal? (item-type (link-right br)) asp) (link-right br)))  obr))
))

(define (specializations en)
(let (
     (obr (out-branches en))
     )
(clean (map (lambda(br)
        (if (equal? (item-type (link-right br)) spec) (link-right br)))  obr))
))

(define (ents en)
(let (
     (obr (out-branches en))
     )
(clean (map (lambda(br)
        (if (equal? (item-type (link-right br)) ent) (link-right br)))  obr))
))

(define (parent-ent en)
(let (
     (ibr (in-branches en))
     )
    (car (clean (map (lambda(br)
         (if (equal? (item-type (link-left br)) ent)(link-left br))) ibr)))
))


(define (parent-aspects en)
(let (
     (ibr (in-branches en))
     )
(clean (map (lambda(br)
         (if (equal? (item-type (link-left br)) asp)(link-left br))) ibr))
))


(define (parent-specs en)
(let (
     (ibr (in-branches en))
     )
(clean (map (lambda(br)
         (if (equal? (item-type (link-left br)) spec)(link-left br))) ibr))
))


(define (inherit-attributes en from-gen to-spec) ; spec-ent has one gen-ent
   (set! (item-attr-lst (find-item (items? en) to-spec))
         (append (item-attr-lst (find-item (items? en) from-gen))
                 (item-attr-lst (find-item (items? en) to-spec))))
)

(define add-ents-lst 
  (lambda(en . ents-lst)
     (for-each (lambda(it) (add-item en 'ent it))
     ents-lst)
  )
)

(define add-mult-mult 
  (lambda(en . mult-lst)
     (let (
            (save-cur (current-item? en))
            (exiting-leaves (leaf-ents en))
            (leaf-added (car (reverse mult-lst)))
          )
        (set-current-item en save-cur)
        (if (member leaf-added exiting-leaves)
            (writeln "entity " leaf-added " already exits")
            (make-mult-mult en mult-lst)
        )
     )
  )
)


(define (add-mult en nm)
   (if (= 1 (length (branches? en)))
       (if (not (equal? (current-item? en) (symbol-append nm '|S|)))
           (error "name of mult-ent is not same : check name" 
                   (symbol-append nm '|S|))
           (delete-item en (current-item? en))
       )
   )
   (let (
          (nms  (symbol-append nm '|S|))
        )
      (add-item en ent nms)
      (set-current-item en nms)
      (set! (item-sub-type (cur? en)) mult-ent)
      (add-item en asp (symbol-append nms '|-MULT-ASP|))
      (set-current-item en  (symbol-append nms '|-MULT-ASP|))
      (set! (item-sub-type (cur? en)) mult-asp)
      (add-item en ent nm)
      (set-current-item en nm)
      (set! (item-sub-type (cur? en)) mult-child)
   )
)


(define (make-mult-mult en mult-lst)
   (if (= 1 (length (branches? en)))
       (if (not (equal? (current-item? en) (symbol-append (car mult-lst) '|S|)))
           (error "name of mult-ent is not same : check name" 
                   (symbol-append (car mult-lst) '|S|))
           (delete-item en (current-item? en))
       )
   )
   (let make-mult (            
                    (cur-mult-lst mult-lst)
                    (cur-name (symbol-append (car mult-lst) '|S|))
                    (ch-name  (if (cadr mult-lst) 
                                  (symbol-append (cadr mult-lst) '|S|)))
                  )
       (if (null? ch-name)
           (add-mult en 
              (subsymbol cur-name 0 (-1+ (symbol-length cur-name)))) 
           (begin
              (add-item en ent cur-name)
              (set-current-item en cur-name)
              (set! (item-sub-type (cur? en)) mult-ent)
              (add-item en asp (symbol-append cur-name '|-MULT-ASP|))
              (set-current-item en  (symbol-append cur-name '|-MULT-ASP|))
              (set! (item-sub-type (cur? en)) mult-asp)
              (set! cur-mult-lst  (cdr cur-mult-lst))
              (make-mult cur-mult-lst
                  (symbol-append (car cur-mult-lst) '|S|)
                  (if (cdr cur-mult-lst) 
                      (symbol-append (cadr cur-mult-lst) '|S|)))
            ) 
        )         
   )   
)

(define (set-mult-coup-type en aspect coup-type) 
   (set-current-item en aspect)
   (if (equal? 'mult-asp (item-sub-type (cur? en)))
       (if (member coup-type (range-mult-coup? en))
           (set! (item-mult-coup-type (cur? en)) coup-type)
           (begin
              (writeln "range of coup-type : " (range-mult-coup? en))
              (set! (item-mult-coup-type (cur? en)) 
                    (check-and-accept (read) (range-mult-coup? en) 'console))
           )
       )
       (writeln aspect " is not MULT-ASP but " (item-type (cur? en)))
   )
)

(define (add-mult-couple en ml-asp port-name1 port-name2)
   (set-current-item en ml-asp)
   (if (equal? 'mult-asp (item-sub-type (cur? en)))
       (set! (item-coupling (cur? en))
        (cons (make-link  'port-pairs (cons port-name1 port-name2))
                                    (item-coupling (cur? en))))
       (writeln ml-asp " is not a MULT-ASP ")
   )
)


(define (select-asp en nm)
(cond
( (equal? (item-type (cur? en)) ent)
    (let rep (
         ( olist (out-branches en))
         ( blist (out-branches en))
         )
     (cond
       ( (null? blist) (writeln "no such  asp"  )
            (set-branches en (union2 (branches? en) olist))
       )
       (  (and (equal? nm (item-name (branch-right (car blist))))
               (equal? asp (item-type (branch-right (car blist)))))
             (for-each (lambda(br)(remove-branch en br)) (cdr blist))
             (set-current-item en nm)
             (writeln "aspect " nm " selected")
       )
       ( else (remove-branch en (car blist))   (rep olist (cdr blist)))
    )
  ))
(else (writeln "current-item " (current-item? en) " is not of type ent"))
))

(define (replace-branches  branches gen sp)
(for-each (lambda(br) (let(
                          (from (branch-left br))
                          (to (branch-right br))
                         )
                (set! (branch-left br) ($trans gen sp from))
                (set! (branch-right br)($trans gen sp to))
                )) branches)
)

(define (replace-coupling en aspect gen-nm sp-nm)
(let* (
        (coup (item-coupling aspect))
        (save-cur (item-name (cur? en)))
      )
(set-current-item en (item-name aspect))
(set-coupling en (cur? en) '())
(for-each (lambda(lk)
    (let (
            (from (link-left lk))
            (to (link-right lk))
         )
       (add-couple en 
              ($trans-nm gen-nm sp-nm from)
              ($trans-nm gen-nm sp-nm to)
              (car (link-port-pairs lk))
              (cdr (link-port-pairs lk)))
     )
) coup)
(set-current-item en save-cur)
))

(define ($trans-nm gen-nm sp-nm entity-nm)
(if (or (equal? entity-nm gen-nm)
        (equal? entity-nm (subsymbol-to sp-nm '_)))
     sp-nm
     entity-nm)
)

(define ($trans gen sp item)
(if (equal? item gen)
     sp
     item)
)

;;;inherit is now in enpeprun

(define (replace-priority aspect gen-nm spec-nm)
(let (
     (priority-list (item-priority-list aspect))
     )
(set! (item-priority-list aspect)
        (map (lambda(e)($trans-nm gen-nm spec-nm e)) priority-list)
)
))




(define (select-ent en ent-name spec-name)   ;current is general entity
(cond
( (equal? (item-type (cur? en)) ent)
    (let rep (
         ( blist (out-branches en))
         )
     (cond
       ( (null? blist) (writeln "no such  specialization"  )'())
       (  (and (equal? spec-name (item-name (branch-right (car blist))))
               (equal? spec  (item-type (branch-right (car blist)))))
           (let* (
                (gen-name (item-name (cur? en)))
                (spec-br (car blist))
                (sp (branch-right spec-br))
                )
             (remove-branch en spec-br)
             (inherit en  ent-name)
             (set-current-item en ent-name)
             (writeln "entity " ent-name
                  " from specialization " spec-name " selected")
           )
       )
       ( else   (rep  (cdr blist)))
    )
  ))
(else (writeln "current-item " (current-item? en) " is not of type ent"))
))

(define (select-root en ent-name)
(let (
     (entity (find-item (ents? en) ent-name))
     )
(if (vector? entity)
(begin
 (set-current-item en ent-name)
 (for-each (lambda(br)(remove-branch en br))(in-branches en))
 (set-current-item en 'root-asp)
 (for-each (lambda(br)(remove-branch en br)) (out-branches en))
 (add-item en ent (item-name entity))
 (set-current-item en ent-name)
)
(writeln "no such entity")
)))


(define (atomic en)
(null? (aspects en))
)

(define (leaf-ent en)
   (and (null? (aspects en)) (null? (specializations en)))
)

(define (children en)      ;to apply only when at entity
(let (
      (cur-name (current-item? en))
      (aspect  (car (aspects en)))
     )
(set-current-item en (item-name aspect))
(begin0 (map (lambda(e)(item-name e)) (ents en))
        (set-current-item en cur-name))
))

(define (all-children en)
(let (
     (obr (out-branches en))
     )
(map (lambda(br) (item-name (link-right br)))  obr)
))                                                        

(define (load-if-exists filenm)
(if
   (file-exists? filenm)
      (load filenm)
)
)


;;; list of leaf ents in entstr ;;;

(define (leaf-ents en)
   (let rep (
              (ents (ents? en))
              (atom-en-nm-lst '())
            )
      (if (equal? ents '())
          atom-en-nm-lst
          (begin
             (set-current-item en (item-name (car ents)))
             (rep (cdr ents) 
                  (if (atomic en) 
                      (append atom-en-nm-lst (list (item-name (car ents))))
                      atom-en-nm-lst))
          )
      )
   )
)

(define (add-priority en lst)
(if (equal? (item-type (cur? en)) 'asp)
   (set! (item-priority-list (cur? en)) lst)
   (writeln "current item is not an aspect: can't add priority list")
))


