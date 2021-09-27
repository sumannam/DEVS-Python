;;;;;;;;;;;;;;; enmanag.s                             

;;3-15-90: added (delete-sub-branches)
;;3-22-90: updated (cut-entstr) and (cut-entstr1)
;;         added (items-in-branches) and (remove-item)

(build-module name-counter
   (                          ;;;;enters new name and adds 1 to it each time
   (tab (table))
   )
(
(gen-name (nm) (lambda(nm)
                  (let (
                       (count (table-look-up tab nm))
                       )
                  (cond
                    ( (null? count) (table-insert-pair tab nm 1)
                                    (set! count 1) )
                    ( else (set! count (1+ count))
                           (table-delete-pair tab nm)
                           (table-insert-pair tab nm count) )
                  )
                  (string->symbol (string-append (symbol->string nm)
                                    (integer->string (-1+ count) 10)))
                  ))
)
))

;; 3-12-90  No duplicates in E:en-st, P:en-lst, and tmp:en-lst

(build-module entstr-manager
   (
      (nm-ctr (name-counter))
      (E:en-lst '())
      (P:en-lst '())
      (tmp:en-lst '())
      (accessfn-tab (table))
      (accessfn-lst '())
   )
   (
   (gen-en-name (nm) (lambda(nm) (gen-name nm-ctr nm)))
   (get-e:lst () (lambda() E:en-lst))
   (get-p:lst () (lambda() P:en-lst))
   (get-tmp:lst () (lambda() tmp:en-lst))
   (get-en-name (en) (lambda(en)
                        (car (clean (map (lambda(e)
                                         (if (equal? en (eval e))
                                             e)) tmp:en-lst)))
                      )
   )
   (get-accessfn-lst() (lambda() accessfn-lst))
   (get-accessfn-tab() (lambda() accessfn-tab))
   (add-accessfn-in-tab (fn-nm e:en it-nm attri)
      (lambda(fn-nm e:en it-nm attri)
         (let (
                (e:en-nm (car (clean (map (lambda(e)
                                           (if (equal? e:en (eval e))
                                             e)) tmp:en-lst))))
              )
         (set! accessfn-lst (append accessfn-lst (list
                               (list fn-nm (list e:en-nm it-nm attri)))))
         (table-insert-pair accessfn-tab (list fn-nm e:en) (list it-nm attri))
         )
      )
   )
   (delete-accessfn-in-tab (fn-nm e:en)
      (lambda(fn-nm e:en) 
         (table-delete-pair accessfn-tab (list fn-nm e:en))
         (set! accessfn-lst (remove (assoc fn-nm accessfn-lst) accessfn-lst))
      )
   )
   (add-e:lst (E:en) (lambda(E:en)                                    
                         (when (not (member E:en E:en-lst))
                           (set! E:en-lst (append E:en-lst (list E:en)))
                         )
                      )                                        
   )
   (add-p:lst (P:en) (lambda(P:en)
                         (when (not (member P:en P:en-lst))
                           (set! P:en-lst (append P:en-lst (list P:en)))
                         )  
                      )
   )
   (add-tmp:lst (tmp:en) (lambda(tmp:en)
                         (when (not (member tmp:en  tmp:en-lst))
                           (set! tmp:en-lst (append tmp:en-lst (list tmp:en)))
                         )
                      )                                        
   )
   (delete-en (en) (lambda(en) 
                        (if (member1 en E:en-lst) 
                                  (set! E:en-lst (delete! 
                                     (car (member1 en E:en-lst)) E:en-lst)))
                        (if (member1 en P:en-lst) 
                                  (set! P:en-lst (delete! 
                                     (car (member1 en P:en-lst)) P:en-lst)))
                        (if (member1 en tmp:en-lst) 
                                  (set! tmp:en-lst (delete! 
                                     (car (member1 en tmp:en-lst)) tmp:en-lst)))
                    )
   )
   (init-enmgr() (lambda()
      (let (
             (e:ens (car (ens-in-enbase)))
             (p:ens (cdr (ens-in-enbase)))
           ) 
         (set! E:en-lst e:ens)
         (set! P:en-lst p:ens)
;         (for-each (lambda(e) (init-version-num (subsymbol e 2 
;                      (symbol-length e)))) e:ens)
      )
   ))
   (change-directory() (lambda()
      (when (equal? 'y 
               (begin (display "do you want to change entstr base dir (y/n)? ")
                          (read)))
          (display "enter new entstr base dir in string form: ")
          (set! entstr-base_directory (string-append (read) "\\")))
      (when (equal? 'y
               (begin (display "do you want to change model base dir (y/n)? ")
                          (read)))
          (display "enter new model base dir in string form: ")
          (set! model-base_directory (string-append (read) "\\")))
      init-enmgr
      )
   )
   )
)                       

;;; change dir of enbase and mbase ;;;

(define (change-dir)
   ((change-directory en-mgr) en-mgr)
   (newline)
)

;;; generate file name for entstr and prunded entstr ;;;

(define (gen-en-fname en) 
   (let* (
           (en-name (get-en-name en-mgr en))
           (basic-fname (subsymbol en-name 2 (symbol-length en-name)))
           (ext-fname  (subsymbol en-name 0 1))
           (basic-fname (symbol->string basic-fname))
           (ext-fname (string-append "." (symbol->string ext-fname)))  
         )                                                          
      (string-append basic-fname ext-fname)
   )
)

;;;; pair of (e:ens p:ens) in entstr base dir ;;;

(define (ens-in-enbase) 
   (let  (
           (e:files (dos-dir (string-append en-base "*.e")))
           (p:files (dos-dir (string-append en-base "*.p")))
           (e:ens '())
           (p:ens '())
         )
      (set! e:ens (map (lambda(e) (symbol-append 'e: (string->symbol
                               (substring e 0 (- (string-length e) 2)))))
            e:files))
      (set! p:ens (map (lambda(e) (symbol-append 'p: (string->symbol
                               (substring e 0 (- (string-length e) 2)))))
            p:files))                              
      (cons e:ens p:ens)
   )
)                                                  


;;; init version number of pruned entstr ;;;

(define (init-version-num en-name)
   (let rep (               
              (highest (length (is-in-entstr_base? en-name)))
            )
      (if (> highest 0)
          (begin
             (gen-en-name en-mgr (symbol-append 'p: en-name))
             (rep (-1+ highest))))
   )
)

;;; show entstr list in entstr manager ;;;

(define (show-e:ens)
   (display (map (lambda(e) (symbol-append 'e: (string->symbol 
                                 (lowcase (subsymbol e 2 (symbol-length e))))))
                 (get-e:lst en-mgr)) 
   )
)

;;; show pruned entstr list in entstr manager ;;;

(define (show-p:ens) 
   (display (map (lambda(e) (symbol-append 'p: (string->symbol 
                                 (lowcase (subsymbol e 2 (symbol-length e))))))
                 (get-p:lst en-mgr))
   )
)

;;; show entstr list in core ;;;

(define (show-tmp:ens) 
   (display (map (lambda(e) (symbol-append (subsymbol e 0 2)
               (string->symbol (lowcase (subsymbol e 2 (symbol-length e))))))
                 (get-tmp:lst en-mgr)) 
   )
)

;;; show all entstr list in entstr manager ;;;

(define (show-all:ens) 
   (display "entstr list : ") (show-e:ens) (newline)
   (display "pruned entstr list : ") (show-p:ens) (newline)
   (display "entstrs in core : ") (show-tmp:ens) (newline)
   (display "end of display")
)


;;; show all access functions ;;;

(define (show-accessfns e:en)
   (clean (map (lambda(e) 
      (if (equal? (get-en-name en-mgr e:en) (caadr e)) 
          (car e))) (get-accessfn-lst en-mgr)
   ))
)

;;; add access function into accessfn-tab ;;;

(define (add-accessfn fn-nm e:en it-nm attri)
   (add-accessfn-in-tab en-mgr fn-nm e:en it-nm attri)
)

;;; delete access function in accessfn-tab ;;;

(define (delete-accessfn fn-nm e:en)
   (delete-accessfn-in-tab en-mgr fn-nm e:en)
)

;;; access function to access ents of attr in pruned entstr ;;;

(define (accessfn fn-nm p:en)
   (let* (
           (p:en-nm (base-name (get-en-name en-mgr p:en)))
           (e:en-nm-suffix (subsymbol p:en-nm 2 (symbol-length p:en-nm)))
           (e:en (eval (symbol-append 'e: e:en-nm-suffix)))
           (ents-p:en (map (lambda(it) (item-name it)) (ents? p:en)))
           (accfn-tab (get-accessfn-tab en-mgr))
           (ent-attr-pair (table-look-up accfn-tab (list fn-nm e:en)))
           (enti (car ent-attr-pair))
           (attr (cadr ent-attr-pair))
         )
       (set-current-item e:en enti)
       (cond 
          ( (equal? (item-type (cur? e:en)) 'spec)
               (map (lambda(e) (item-name e)) (ents e:en)))
          ( (equal? (item-type (cur? e:en)) 'asp)
               (map (lambda(e) (item-name e)) (ents e:en)))
          ( (specializations e:en) 
               (gen->spec e:en p:en enti))
          ( (not (member enti ents-p:en))
               (clean (map (lambda(it) 
                  (if (equal? enti (base-name it)) it)) ents-p:en))) 
          ( ent-attr-pair  
               (get-attribute-value p:en enti attr))
          ( else 
               (writeln #\newline "invalid accessfn name :" fn-nm))
       )
   )
)

(define (gen->spec e:en p:en enti)
   (set-current-item e:en enti)
   (set-current-item e:en (item-name (car (parent-aspects e:en))))
   (set-current-item p:en (current-item? e:en))
   (let rep (
              (ents-p:en (ents p:en))
              (ents-e:en (ents e:en))
            )
      (cond 
         ( (null? ents-e:en) 
              (writeln enti " is not in " (get-en-name en-mgr  e:en)))
         ( (equal? enti (item-name (car ents-e:en)))
              (item-name (car ents-p:en)))
         ( else 
              (rep (cdr ents-p:en) (cdr ents-e:en)))
      )
    )
)

;;; make entstr with name e:root-name ,where root-name is name of root ent ;;;

(define (make-entstr ent-name)
   (let (
          (en-name  (symbol-append 'e: ent-name))         
          (file-name (string-append (symbol->string ent-name) ".E"))
          (tmp:lst (get-tmp:lst en-mgr))
        )
      (if (and (not (member en-name tmp:lst)) 
               (not (member file-name (dos-dir (string-append en-base "*.e")))))
          (eval `(mk-entstr ,ent-name))
          (begin
             (display-window 'console (string-append "E:" (lowcase ent-name))
                                      " already exists." #\newline
                                      "Do you want to overwrite it? (y/n) ")
             (when (equal? 'y (read))
                (delete-en en-mgr en-name)
                (eval `(mk-entstr ,ent-name))
             )
          )
      )
   )
)

;;; entstr with name e:root-name is created ;;;

(macro mk-entstr (lambda(e)
   (let* (
          (en-name (cadr e))
          (root-ent en-name)
          (entstr-name (symbol-append 'e: root-ent))
          (en-fname (string-append (symbol->string en-name) ".E"))
          (en-saved? (member en-fname (dos-dir (string-append en-base "*.e"))))
         )
      `(begin
          (define ,entstr-name (entity-structure))
          (message-mode-off)
          (add-item ,entstr-name 'ent ',root-ent)
          (set-current-item ,entstr-name ',root-ent)
          (message-mode-on)
          (add-e:lst en-mgr ',entstr-name)
          (add-tmp:lst en-mgr ',entstr-name)
          (display-window 'console "Entity-structrue E:" (lowcase ',en-name)
                                   " with root-ent "  ',root-ent   " made.")
          (newline)
       )
   )
))
       

;;; rename entstr ;;;

(macro rename-entstr (lambda(e)
   (let (
          (from-en (cadr e))
          (to-en   (caddr e))
        )
      `(begin                           
          (copy-entstr ,from-en ,to-en)
          (dos-delete (string-append en-base (gen-en-fname (eval ,from-en))))
          (delete-en en-mgr ',from-en)
          (display-window 'console "Entstr renamed to " 
             (subsymbol ',to-en 0 1) 
             (lowcase (subsymbol ',to-en 1 (symbol-length ',to-en))))
       )                    
   )
))

;;; copy entstr in core, 5-15-90 ;;;

(macro copy-entstr-in-core 
   (lambda(e)
      (let (
             (from-en (cadr e))
             (to-en (caddr e))
           )
         `(copy-entstr1 ,from-en ',to-en)
       )
   )
)

;;; copy entstr and save new copy in enbase, 5-15-90 ;;;

(macro copy-entstr
   (lambda(e)
      (let* (
             (from-en (cadr e))
             (to-en (caddr e))
             (to-root (subsymbol to-en 2 (symbol-length to-en)))
           )
         (eval
           `(begin
               (copy-entstr1 ,from-en ',to-en)
               (change-root ,to-en (root-name ,from-en) ',to-root)
               (save-en ,to-en)  ;;;;
            )
         )
      )
   )
)


;;; copy entstr to another entstr in core, 5-15-90 ;;;

(define (copy-entstr1 from-en to-en)
   (let* (
           (en from-en)
           (items (map (lambda(it) (copy-item it)) (items? en)))
           (branches (map (lambda(br)
                       (make-branch 'left (car (member (branch-left br) items))
                                    'right (car (member (branch-right br)items))
                     )) (branches? en)))
           (root (root-name en))
           (new-root (subsymbol to-en 2 (symbol-length to-en)))
        )
      (eval
         `(begin
             (define ,to-en (entity-structure))
             (set-items ,to-en ',items)
             (set-branches ,to-en ',branches)
             (if (equal? 'e (subsymbol ',to-en 0 1))
                 (add-e:lst en-mgr ',to-en)
                 (add-p:lst en-mgr ',to-en))
             (add-tmp:lst en-mgr ',to-en)
           ;  (change-root ,to-en ',root ',new-root) ;; adjust root-name w/ coupling
           ; (save-en ,to-en)
          )
      )
   )
)


;;; copy entstr to another entstr whose name has a version number ;;;

(define (copy1-entstr en)
   (let* (
           (en-name (get-en-name en-mgr en))
           (cp-name (gen-en-name en-mgr en-name))
           (items (map (lambda(it) (copy-item it)) (items? en)))
           (branches (map (lambda(br) 
                       (make-branch 'left (car (member (branch-left br) items))
                                    'right (car (member (branch-right br)items))
                     )) (branches? en)))
           (cur-it (current-item? en))
        )
      (eval 
         `(begin 
             (define ,cp-name (entity-structure))
             (set-items ,cp-name ',items)
             (set-branches ,cp-name ',branches)
             (set-current-item ,cp-name ',cur-it)
             (display-window 'console "Copied entstr " 
                 (if (member, en (map (lambda(e) (eval e))(get-e:lst en-mgr)))
                     "E:" "P:")
                 (lowcase (subsymbol ',cp-name 2 (symbol-length ',cp-name))) 
                 " made.")
          )
      )
   )
)

;;; delete entstr from entstr manager ;;;

(macro delete-entstr (lambda(e)
   (let* (
           (en-name (cadr e))
           (basic-name (symbol->string (subsymbol en-name 2
                                              (symbol-length en-name))))
           (ext-name (symbol->string (subsymbol en-name 0 1)))
           (f-name (string-append basic-name "." ext-name))
           (en-in-lst (string->symbol (string-append ext-name ":"
                                      (lowcase basic-name))))
         )
      `(begin
          (when (not (file-exists? (string-append en-base ,f-name)))
             (error "check entstr name" ',en-name))
          (dos-delete (string-append en-base ,f-name))
          (delete-en en-mgr ',en-in-lst)
          (display-window 'console "Entstr " (subsymbol ',en-name 0 1) ":" 
                         (lowcase ,basic-name) " deleted.")
       )
    )
))

;;;;;;; 1/18/89 ;;;;;;;;;;;;;;
;;; save entstr in a file in the dir of entstr-base after confirmming ;;;

(define (save-entstr en)
   (let (
          (en-fname (gen-en-fname en))
        )
      (if (member en-fname (dos-dir (string-append en-base en-fname)))
          (begin
            (display-window (current-output-port) (get-en-name en-mgr en) 
                           " already exits in entstr base as a file." #\newline
                           "Do you want to overwrite it? (y/n) ")
            (if (equal? 'y (read))
                (save-en en))
         )
         (begin
           (save-en en)
           (writeln "entstr " (get-en-name en-mgr en)
                    " is saved in entstr base as a file.")
         )
      )
   )
)
;;;;;;;;;;;;;;;;;;


;;; save entstr in a file in the directory of entstr-base ;;;

(define (save-en en)
   (let  (                       
           (fo (open-output-file (string-append en-base (gen-en-fname en))))
         )
      (write (cons (items? en) (branches? en)) fo)
      (close-output-port fo)
   )
)

;;; restore entstr from a file form to an entstr ;;;

(define (restore-entstr entstr it-brs-lst)
   (let  (
           (its-lst (car it-brs-lst))
           (brs-lst (cdr it-brs-lst))
         )
      (set-items entstr its-lst)
      (set-branches entstr (map (lambda(br) 
         (make-branch 'left  (car (member (branch-left br) its-lst))
                      'right (car (member (branch-right br) its-lst))
         )) brs-lst)
      )
   )
)


;;; load entstr in entstr base as a file form ;;;

(macro load-entstr1 (lambda(e)
   (let* (
           (en-name (cadr e))
           (flag (caddr e))
           (basic-name (symbol->string (subsymbol en-name 2
                                              (symbol-length en-name))))
           (ext-name (symbol->string (subsymbol en-name 0 1)))
           (f-name (string-append en-base basic-name "." ext-name))
           (fi (if (file-exists? f-name) (open-input-file f-name)))
         )
      `(begin
          (when (not (file-exists? ,f-name))
             (error "entstr does not exists in entstr base" ',en-name))
          (define ,en-name (entity-structure))
          (restore-entstr ,en-name (read ,fi))
          (close-input-port ,fi)
          (add-tmp:lst en-mgr ',en-name)
          (if (null? ',flag)
              (print-ent ,en-name))
       )
   )
))

;;; load entstr en or load all matched entstr if en has a wildcard ;;;

(macro load-entstr
   (lambda(e)
      (let* (
              (en-nm (cadr e))
              (flag-pe (caddr e))
              (en-name 
                 (if (member #\* (string->list (symbol->string en-nm)))
                     (let ((all-ens (all:ens en-nm)))
                        (writeln "all entstr's in "
                                 all-ens 
                                 " will be loaded")
                        all-ens
                     )
                     en-nm
                 ))
            )
         `(if (not (pair? ',en-name))
              (if ',flag-pe 
                  (load-entstr1 ,en-nm ',flag-pe)
                  (load-entstr1 ,en-nm))
              (for-each (lambda(en)
                (eval `(load-entstr1 ,en noprint))) ',en-name))
      )
   )
)

;;; all entstr with name en-nam-* , ie. p:e* or e:ta*c or *:ta*ab ;;;

(define (all:ens en-name-*)
   (let* (
           (en-root-* (symbol-reverse 
                         (subsymbol-to (symbol-reverse en-name-*) ':)))
           (e:en? (equal? 'e (subsymbol en-name-* 0 1)))
           (p:en? (equal? 'p (subsymbol en-name-* 0 1)))
           (e:en+p:en? (and (not e:en?) (not p:en?)))
           (all-ens (clean (map (lambda(e)
                              (cond
                                 ((and e:en?  (string-match "*.E" e)) 
                                     (string->symbol e))
                                 ((and p:en? (string-match "*.P" e))
                                     (string->symbol e))
                                 ((and e:en+p:en? 
                                       (or (string-match "*.E" e)
                                           (string-match "*.P" e)))
                                     (string->symbol e))
                              ))  
                           (dir-enbase))))
          )
       (clean 
          (map 
             (lambda(e)
                (if (member #\- (string->list (symbol->string e)))
                    (if (symbol-match en-root-* (subsymbol-to e $linksym))
                        (symbol-append (last-symbol e)
                                       ':
                                       (subsymbol e 0 (- (symbol-length e) 2)))
                    )
                    (if (symbol-match en-root-* 
                                      (subsymbol-to e (string->symbol ".")))
                        (symbol-append (last-symbol e)
                                       ':
                                       (subsymbol e 0 (- (symbol-length e) 2)))
                    )))
          all-ens))
   )
)
 

;;;;--------------------------------;;;
;    Extended operations on entstr    ;
;;;---------------------------------;;;

;;; delete unused items and branches in pruned entstr ;;;

(define (clean-entstr p:en)
   (let* (
          (old-branches (branches? p:en))
          (new-items (sub-entstr-its p:en 'root-asp))
          (new-branches (align old-branches (sub-entstr-brs p:en 'root-asp)))
         )
       (set-items p:en new-items)
       (set-branches p:en new-branches)
   )
)

;;; add sub-entstr to entstr <- generalized add-item ;;;

(define (add-sub-entstr e:en sub-entstr)
   (if (equal? 'ent (item-type (cur? e:en)))
       (writeln (item-name (cur? e:en)) " is type ent : can't be added ")
       (let* (
               (root-ent-sub-entstr (find-item (items? sub-entstr) 'root-asp))
               (root-br-sub-entstr 
                   (car (find-out-branches sub-entstr 'root-asp)))
               (root-item-sub-entstr (branch-right root-br-sub-entstr))
               (its (remove root-ent-sub-entstr (items? sub-entstr)))
               (brs (remove root-br-sub-entstr (branches? sub-entstr)))
               (its-cp (map (lambda(it) (copy-item it)) its))
               (brs-cp (map (lambda(br)
                     (make-branch 'left (car (member (branch-left br) its-cp))
                                  'right (car (member (branch-right br) its-cp))
                   )) brs))
             )
            (set-items e:en (append (items? e:en) its-cp))
            (set-branches e:en (append (branches? e:en) brs-cp))
            (add-item e:en ent (item-name root-item-sub-entstr))
       )
   )
)


;;; delete sub-entstr from entstr <-generalized delete-item ;;;

(define (delete-sub-entstr e:en it-name)
   (if (not (equal? 'ent (item-type (find-item (items? e:en) it-name))))
       (writeln it-name " is not type ent : can't be deleted ")
       (delete-sub-entstr1 e:en it-name)
    )
)

;;; delete all under current-item from entstsr ;;;

(define (delete-sub-entstr1 e:en it-name)
   (set-current-item e:en it-name)
   (let* (
              (sub-its (sub-entstr-its e:en it-name))
              (sub-brs  (sub-entstr-brs e:en it-name))
              (in-brs   (in-branches e:en))
              (sub-brs (append sub-brs in-brs))
          )
          (set-items e:en (difference (items? e:en) sub-its))
          (set-branches e:en (difference (branches? e:en) sub-brs))
          (set-current-item e:en (item-name (branch-left (car in-brs))))
    )
)

;;; delete all sub branches under current-item from entstsr ;;;
;;; 01-04-90  3-15-90 no in-branches
(define (delete-sub-branches e:en it-name)
   (set-current-item e:en it-name)
   (let* (
              (branches (branches? e:en))
              (sub-brs  (sub-entstr-brs e:en it-name))
             ; (in-brs   (in-branches e:en))
             ; (sub-brs (append sub-brs in-brs))
          )
        (for-each (lambda(br) (set! branches (remove br branches))) sub-brs)
        (set-branches e:en branches)
      ; (set-current-item e:en (item-name (branch-left (car in-brs))))
    )
)
   
   
;;; extract sub-entstr from entstr at current-item with type ent ;;;

(define (extract-sub-entstr e:en sub-en)
   (let ( 
          (it-name (current-item? e:en))
        )
      (if (not (equal? 'ent (item-type (cur? e:en))))
          (writeln it-name " is not type ent : can't be extracted")
          (let (
                (sub-it-lst (sub-entstr-its e:en it-name))
                (sub-br-lst (sub-entstr-brs e:en it-name))
               )
            (set! sub-it-lst (map (lambda(it) (copy-item it)) sub-it-lst))
            (set! sub-br-lst (map (lambda(br)
               (make-branch 'left (car (member (branch-left br) sub-it-lst))
                      'right (car (member (branch-right br) sub-it-lst))
               )) sub-br-lst))
            (eval
              `(begin
                (define ,sub-en (entity-structure))
                (set-items ,sub-en (append ',sub-it-lst (items? ,sub-en)))
                (set-branches ,sub-en (append ',sub-br-lst (branches? ,sub-en)))
                (set-branches ,sub-en (align (branches? ,e:en) 
                                             (branches? ,sub-en)))
                (set-items ,sub-en (align (items? ,e:en) (items?  ,sub-en)))
                (set-current-item ,sub-en 'root-asp)
                (add-item ,sub-en 'ent ',it-name)
                (add-tmp:lst en-mgr ',sub-en)
;               (save-en ,sub-en)
                ,sub-en
               )
            )
        )
      )
   )
)


;;; items of sub-entstr with root at root-sub-entstr ;;;

(define (sub-entstr-its e:en root-sub-entstr)
   (let (
          (brs (sub-entstr-brs e:en root-sub-entstr))
          (its '())
        )
      (for-each (lambda(br)
          (set! its (append its (list (branch-left br) (branch-right br))))
          ) brs)
      (if (null? its)
          (list (find-item (items? e:en) root-sub-entstr))
          (remove-mult its)
      )
   )
)

;;; branches of sub-entstr with root at root-sub-entstr ;;;

(define (sub-entstr-brs e:en root-sub-entstr)                
   (let* (                             
            (br (find-out-branches  e:en root-sub-entstr))
            (children (map (lambda(b) (item-name (branch-right b))) br))
         )
      (append br (union (map (lambda(ch)(sub-entstr-brs e:en ch)) children)))
   )
)


;;; fine out-branches at it-name ;;;

(define (find-out-branches e:en it-name)
    (let (
            (save-cur-it (current-item? e:en))
            (out-brs '())
         )
       (set-current-item e:en it-name)
       (set! out-brs (out-branches e:en))
       (set-current-item e:en save-cur-it)
       out-brs
    )
)

;;; find  in-branches at it-name ;;;

(define (find-in-branches e:en it-name)
    (let (
            (save-cur-it (current-item? e:en))
            (in-brs '())
         )
       (set-current-item e:en it-name)
       (set! in-brs (in-branches e:en))
       (set-current-item e:en save-cur-it)
       in-brs
    )
)

;;; flatten sub-entstr ;;;

(macro make-flat 
   (lambda(e)
      (let* (
              (en (cadr e))
              (it-lst (cddr e))    ;; root of sub-entstr
              (items-lst (map (lambda(it) (eval it)) it-lst))
            )
           `(if (not (equal? 'asp (item-type (cur? ,en))))
                (writeln "current-item is not type asp "
                         " : set current-item to aspect")
                (flatten ,en ',items-lst)
            )
       )
   )
)

;;; each item in items-lst has one aspect only ;;;

(define (flatten en items-lst) 
   (let* (
          (its (items? en))
          (brs (branches? en))
          (save-cur-it (current-item? en))
          (items (map (lambda(it) (item-name it)) (ents en)))
         )
       (for-each (lambda(it) 
           (if (member it (leaf-ents en))
               (error "leaf can't be flattened" it))
           (if (not (member it items))
               (error "wrong item is included : check current-item " it))
       ) items-lst)
       (for-each (lambda(it)
          (for-each (lambda(br)
             (if (member (item-name (branch-right br)) (children-ents en it))
                 (set! (branch-left br) (find-item its save-cur-it))
                 (set! (branch-left br) (branch-left br))
             )
          ) brs)
          (set! its (remove (find-item its it) its))
          (set! brs (remove (car (find-in-branches en it)) brs))
          (set! brs (remove (car (find-out-branches en it)) brs))
       ) items-lst)
       (set-items en its)
       (set-branches en brs)
       (clean-entstr en)
   )
)

;;;  children of ents  of ent with one aspect ;;;

(define (children-ents en item)
   (set-current-item en item)
   (let* (
           (asp-name (map (lambda(aspt) (item-name aspt)) (aspects en)))
           (return-ents '())
         )
      (for-each (lambda(aspt)
         (set-current-item en aspt)
         (set! return-ents 
            (append return-ents
                    (map (lambda(it) (item-name it)) (ents en)))))
      asp-name)
      return-ents
   )
)

;;; return root name of en ;;;
(define (root-name en)
   (set-current-item en 'root-asp)
   (item-name (car (ents en)))
)

;;; 1. make all "ent-cut" to be a leaf one by one
;;; 2. make entstr with root be "ent-cut" for ea
;;; 3. (options) prune entstr made in step 2 as many times as we want.
;;; note 1.  if e:en/p:en is non-pruned entstr
;;;             a copy of e:en/p:en is used 
;;;          else e:en/p:en is used
;;; note 2.  call/cc is used to escape  
;;; 3-22-90 updated

(define (cut-entstr1 e:en/p:en p:en-nm ent-cut)
   (call/cc (lambda(exit)
     (set-current-item e:en/p:en ent-cut)
   ;  (when (specializations e:en/p:en)
   ;      (exit (writeln "ent " ent-cut " has specialization: "
   ;                     "no cutting")))
     (when (leaf-ent e:en/p:en)
         (exit (writeln "ent " ent-cut
                        " is a leaf")))
     (let* (
             (p:en (eval p:en-nm))
             (p-brs (branches? p:en))
             (en:cut-nm (symbol-append 'e: ent-cut))
             (item-lst-deleted '())
             (items-cut '())
             (items-in-brs '())
           )
        (set-current-item e:en/p:en ent-cut)
        (extract-sub-entstr e:en/p:en en:cut-nm) ;;bpz,90
        (for-each (lambda(br) (when (member br p-brs)
                                  (remove-branch p:en br)))
                  (branches? (eval en:cut-nm))) ;; break cutted branches
        (set! items-cut (items? (eval en:cut-nm)))
        (set! items-in-brs  (items-in-branches (branches? (eval p:en))))
        (set! item-lst-deleted (clean (map (lambda(it)
             (when (not (member it items-in-brs)) it)) items-cut)))
        ;;check for possible multiply occurring entities in the remaining SES
        (for-each (lambda(el) (remove-item p:en el)) item-lst-deleted)
                  ;;; branches associated with these items to be removed have
                  ;;; been broken already, cannot use delete-item here.
        (save-en (eval en:cut-nm))
        (save-en p:en)
        (writeln "ent " ent-cut " was made a leaf in " p:en-nm)
        (writeln "entstr " p:en-nm " made and saved in enbase.")
        (writeln
            "entstr E:" (lowcase ent-cut) " made and saved in enbase."
            #\newline #\newline
            "do you want prune with" " E:" (lowcase ent-cut) "? (y/n)")
        (when (equal? 'y (read))
           ;;; "it will be pruned as many times as we want."
          (let rep ((more? #!true))
            (when more?
               (prune1 (eval en:cut-nm))
               (rep (begin
                      (writeln #\newline #\newline
                               "do you want another prune with"
                               " E:" (lowcase ent-cut)"? (y/n)")
                      (if (equal? 'y (read))
                          #!true
                          #!false))))
          )
        )
    )
)))


;;; apply cut-entstr1 with many ent independently ;;;
;;; working for all non-leaf ents

(define cut-entstr
   (lambda(x . y)
      (let* (
             (e:en/p:en x)
             (ent-lst y)
             (en-nm (get-en-name en-mgr e:en/p:en))
             (e:en? (member1 en-nm (get-e:lst en-mgr)))
             (p:en-nm '())
            )

         (call/cc (lambda(exit)
            (set-current-item e:en/p:en (car ent-lst))
           ; (when (and (null? (cdr ent-lst))
           ;            (specializations e:en/p:en))
           ;    (exit (writeln "ent " (car ent-lst) " has specialization: "
           ;                   "try again with another ent")))
            (when (and (null? (cdr ent-lst))
                      ; (member (car ent-lst) (leaf-ents e:en/p:en)))
                       (leaf-ent e:en/p:en))
               (exit (writeln "ent " (car ent-lst)
                              " is a leaf : try again with a non-leaf ent")))
         (set! p:en-nm
                (if e:en?
                  (symbol-append
                    'e:        ;;bpz,90 makes SES rather than PES
                    (subsymbol en-nm 2 (symbol-length en-nm))
                    (begin
                       (display "give extension name for cutting : ")
                       (symbol-append $linksym (read))))
                  en-nm))
        (if (and e:en? (member1 p:en-nm (get-p:lst en-mgr)))
            (set! p:en-nm
               (symbol-append
                  (subsymbol-to p:en-nm $linksym)
                  $linksym
                  (begin
                     (writeln  #\newline  "!!!! " p:en-nm
                               " is already existing !!!!")
                     (writeln "existing pruned entstr's : "
                              (p:ens-with-root-nm (root-name e:en/p:en)))
                     (display "give extension name again : ")
                     (read)))))
       (if e:en?
           (eval `(copy-entstr ,e:en/p:en ,p:en-nm)))
       (for-each (lambda(enti)
           (writeln #\newline
                    "ent " enti " is a candidate to be cut"
                    #\newline)
           (cut-entstr1 e:en/p:en p:en-nm enti))
       ent-lst)
      )))
   )
)


(define (items-in-branches branches)
 (let (
      (brs-left '())
      (brs-right '())
      (items '())
      )
  (set! brs-left (map (lambda(br) (branch-left br)) branches))
  (set! brs-right (map (lambda(br) (branch-right br)) branches))
  (set! items (union2 brs-left brs-right))
 items
))

(define (remove-item en it)
 (let (
      (items (items? en))
      )
  (when (member it items)
     (set-items en (remove it items))
  )
))





