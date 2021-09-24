;; cellu-me.s

;(define-method (coupled-models init-wind)()       
;        (for-each (lambda (chd)
;                      (send chd init-wind)
;                  )      (get-children) )
;
;)                                                 

;(define-method (atomic-models init-wind)()                                                       
;   (window-clear wind)
;)      

(define-method (cellular-models get-influencees) (child)
   (when (equal? infl-origin #!unassigned)
      (back 'console)
      (error "pattern of influencees (list of coordinate) 
                                               is not defined yet" name))
   (when (equal? structure #!unassigned)
      (back 'console)
      (error "structure type (fixed or variable) is not defined yet" name))
   (let* (
           (child-cell-pos (send child get-cell-position))
           (infl-pattern infl-origin)
           (infl-cell-pos (map (lambda(e) 
                 (coor-translate child-cell-pos e)) infl-pattern))
         )
       (clean (map (lambda (cell-pos) 
             (let rep (
                        (children (reverse (get-children)))
                      )
                (cond 
                  ((equal? '() children) 
                      (if (not (equal? 'fixed (get-structure)))
                          (create-cell cell-pos)
                          '()))
                  ((equal? cell-pos (send (car children) get-cell-position))
                           (car children))
                  (else (rep (cdr children)))
                )
              )
          ) infl-cell-pos)
        )
    )             
)

(define-method (cellular-models get-receivers)()
   (when (equal? ext-coup #!unassigned)
      (back 'console)
      (error "ext-coup type (origin-only or broadcast) is not defined yet"name))
   (if (equal? ext-coup 'origin-only)
       (list origin-cell)
       (get-children)
   )
)

(define-method (cellular-models print-graph)()
(let* (
     (pair (cons this-model wind))
     (orig-size (window-get-size wind))
     (orig-pos (window-get-position wind))
     (children (get-children))
     (coor-lst (map (lambda(e) (send e get-cell-position)) children))
     (len  (+ 12 (round (/ (length children) 4))))
     )
(window-reduce-stack pair)
(wpd pair)
(wss wind len 50) 
(wc wind)
(display-window wind "cellular-model:" #\newline #\newline 
                     "structure type : " (get-structure) #\newline
                     "bounding hyper-box : " (compute-boundaries coor-lst)
                      #\newline)
(display-window wind "children: ")
(for-each (lambda(child)
    (display-window wind (send child get-name) " ")
    ) children)          
(display-window wind #\newline #\newline "external coupling: " (get-ext-coup))
(display-window wind #\newline #\newline 
             "influencees pattern of origin cell: " (get-infl-origin))
(display-window wind #\newline "out-int-coup table: " (get-table out-in-coup))
(wss wind (car orig-size)(cdr orig-size))
(wsp wind (car orig-pos)(cdr orig-pos))
))
 
;;; working but very slow because of delete-methods-inherited ;;;
;(define-method (cellular-models make-class)(class-name)
;   (send this-model delete-methods-inherited cellular-models models)
;   (send-if-handles this-model delete-kernel-methods)
;   (send-if-handles this-model delete-cellular-methods)
;   (eval `(make-cellular-class ,class-name (eval ,name)) 
;                              user-initial-environment)
;   (send this-model resume-methods-deleted cellular-models models)
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(define-method (cellular-models make-class)(class-name)
;   (send-if-handles (make-instance models) delete-methods)
;   (send-if-handles (make-instance coupled-models) delete-methods)
;   (send-if-handles (make-instance kernel-models) delete-methods)
;   (send-if-handles this-model delete-methods)
;   (gc)
;   (eval `(make-cellular-class ,class-name (eval ,name)) 
;                              user-initial-environment)
;   (send (make-instance models) resume-methods)
;   (send (make-instance coupled-models) resume-methods)
;   (send (make-instance kernel-models) resume-methods)
;   (send this-model resume-methods)
;)

(macro make-cellular-class (lambda(e)
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
               (ext-coup (send ,m get-ext-coup))
               (init-cell (send ,m get-init-cell))
               (infl-origin (send ,m get-infl-origin))
               (structure (send ,m get-structure))
            )
            (mixins cellular-models)
         )
       (eval '(compile-class ,class-name))
     )
   )
))


(define-method (cellular-models make-new)(new-inst-name)
   (let* ( 
          (models-class (eval (class-of-object (eval name))))
          (ce-inst-nm (gen-mem-name new-inst-name))
          (ce-inst-name (gen-name name-ctr (base-name ce-inst-nm)))
          (m (make-entity models-class ce-inst-name))
          (co-nm  (symbol-append '|C:| ce-inst-name))
          (co (make-entity co-ordinators co-nm))        
          (old-children (get-children))
          (old-init-cell (get-init-cell))
          (old-cell-pos (map (lambda(e)(send e get-cell-position))old-children))
          (new-cell-pos (reverse old-cell-pos))
          (#-children (length old-children))
          (mem-names (map (lambda(ch) (send ch get-name)) old-children))
          (mem-name (car mem-names))
       ;  (mem-name (send (car old-children) get-name))
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
             (send ,m set-infl-origin ',infl-origin)
             (send ,m set-structure ',structure)
             (send ,m make-init-cell)
             (send ,m make-true-members ',mem-names)
            ; (send ,m make-kernel-members ',base-nm ,#-children)
             (send ,m set-newcells-positions ',new-cell-pos) 
             (message-mode-off)
            (send (send ,m get-init-cell) copy-state ,old-init-cell)         
             (message-mode-on)
             (define ,ce-inst-name ,m) 
             (define ,co-nm ,co) 
          ) user-initial-environment
      )                                       
      (set-originator (send m get-class) originator)
      (writeln "cellular model and co-ordinator made: "
                ce-inst-name  " " co-nm)
      m
   ) ;let
)

(define-method (cellular-models create-cell)(cell-position)
   (let* (
           (class (eval class))
           (nm (send init-cell get-name))
           (created-cell-name (symbol-append (gen-name name-ctr nm) ':created))
           (new-cell '())                                           
         )                                    
      (message-mode-off)
      (eval `(make-pair ,class ',nm) user-initial-environment)
      (set! new-cell (send (eval nm) make-new created-cell-name))
      (send (eval nm) destroy)
      (send new-cell copy-state (get-init-cell))
      (message-mode-on)
      (send new-cell set-cell-position  cell-position)
      (initial-structure this-model)
      (re-compute-tL&tN new-cell)
      (place-model new-cell (+ 2 (* 2 (num-created-cells))) 50)
      new-cell
   )
)

(define-method (cellular-models make-init-active-cells)(nm list-of-boundaries)
   (if (member '() (map (lambda(e) (= 2 (length e))) list-of-boundaries))
       (display "check boundaries : list of (min max) for each coordinate")
       (let* (
               (num (make-number list-of-boundaries))
               (class (eval class))
               (coordinate-lst (make-coordinate list-of-boundaries))
             )
            (make-kernel-members nm num)   
            (set-newcells-positions coordinate-lst)
            (get-children)
           )
   )
)

(define-method (cellular-models set-newcells-positions)(coord-lst)
   (let rep (
              (children (reverse (get-children)))
              (coordinates coord-lst)
            )
      (if (<> (length children) (length coordinates))
          (display " num of children <> num of coordinates to be assigned")
          (when (not (null? children))
             (send (car children) set-cell-position (car coordinates))
             (display-window 'console "cell-position of a "
                (subsymbol (send (car children) spec-class-of-object) 0 (-1+
                (symbol-length (send (car children) spec-class-of-object))))
                   "  " (send (car children) get-name)" is " (car coordinates) 
                                                                     #\newline)
             (if (equal? (car coordinates) 
                         (decimal->binary 0 (length (car coordinates))))
                 (set! origin-cell (car children))
             )
             (rep (cdr children) (cdr coordinates))
         )
     )
   )         
)


(define-method (cellular-models num-created-cells) ()
   (let rep (
              (children (get-children))
              (counter 0)
            )
      (if (equal? children '())
          counter
          (rep (cdr children)
               (if (equal? 'd (last-symbol (send (car children) get-name)))
                   (1+ counter) counter))
      )
   )
)                                            

(define-method (cellular-models save-state)(boundary-lst to-file)
   (let* (
           (coors-in-bound (make-coordinate boundary-lst))
           (models-in-bound '())
           (all-s-pairs-lst '())
           (fnm (symbol->string to-file))
           (fo (open-output-file (string-append mo-base fnm)))
         )
      (for-each (lambda(e) 
         (if (member (send e get-cell-position) coors-in-bound)
             (set! models-in-bound (append models-in-bound (list e)))))
         (reverse (get-children))
      )              
      (set! all-s-pairs-lst                       
         (map (lambda(m)
            (map (lambda(e)(append all-s-pairs-lst (send e get-ind-vars-pairs)))
               (if (null? (send-if-handles m get-all-leaf-models))
                   (list m)
                   (send m get-all-leaf-models))))
            models-in-bound)
      )
      (write all-s-pairs-lst fo)
      (close-output-port fo)    
   )
)           

(define-method (cellular-models restore-state) (from-file boundary-lst)
   (let* (
           (m init-cell)
           (nm (send m get-name))
           (coors (make-coordinate boundary-lst))               
           (fnm (symbol->string from-file))
           (fi (open-input-file (string-append mo-base fnm)))
           (state-saved (read fi))
           (cnt (counter))
         )                    
       (if (< (length state-saved) (length coors))
           (writeln "can't copy state :"
                    " num of states saved < num of models to be created")
           (begin         
              (set-count cnt (length coors))
              (let loop ( 
                          (coor coors)
                          (state state-saved)
                          (base m) 
                        )
                 (send m make-new (gen-name name-ctr nm))
                 (send (car (get-children)) set-cell-position (car coor))
                 (associate-model-state  
                    (if (null? (send-if-handles (car (get-children)) 
                                                      get-all-leaf-models))
                        (list (car (get-children)))
                        (send (car (get-children)) get-all-leaf-models))
                    (car state))
                 (writeln (send (car (get-children)) get-name)
                          " copies state "
                          " and is pasted at  " (car coor))
                 (if (not (decrement&test cnt))
                     (loop (cdr coor) (cdr state) base))
              )
           )
        )
        (close-input-port fi)
    )
)

(define-method (cellular-models copy&paste) (from-boundary to-boundary)
   (let* (
           (nm (send (get-init-cell) get-name))
           (from-coors (make-coordinate from-boundary))               
           (to-coors (make-coordinate to-boundary))    
           (coors-active-cells (map (lambda(e) (send e get-cell-position))
                                    (get-children)))
         )                    
       (if (<> (length from-coors) (length to-coors))
           (writeln "can't copy state :"
                    " num of source models <> num of destination models")
           (let rep  ( 
                        (source-coors from-coors)
                        (dest-coors   to-coors)                                
                      )
              (when (not (null? source-coors))
                 (when (not (member (car dest-coors) coors-active-cells)) 
                    (send init-cell make-new (gen-name name-ctr nm))
                    (send (car (get-children)) set-cell-position 
                                                       (car dest-coors)))
                 (message-mode-off)
                 (send (cell-pos->model (car dest-coors)) copy-state 
                       (cell-pos->model (car source-coors)))
                 (message-mode-on)                 
                 (if (not (member (car dest-coors) coors-active-cells)) 
                     (writeln (send (cell-pos->model (car dest-coors)) get-name)
                              " copies its state from "
                            (send (cell-pos->model (car source-coors)) get-name)
                            " at " (car source-coors)" and is pasted at " 
                            (car dest-coors))
                     (writeln (send (cell-pos->model (car dest-coors)) get-name)
                            " at " (car dest-coors) " copies its state from "
                            (send (cell-pos->model (car source-coors)) get-name)
                            " at " (car source-coors))
                 )
                 (rep  (cdr source-coors) (cdr dest-coors))
               )
            )
        )
    )
)  


(define-method (cellular-models cell-pos->model) (cell-pos)
   (car (clean (map (lambda(e)
                       (if (equal? cell-pos (send e get-cell-position))
                           e)) (get-children)
               )
         )
   )
)

(define-method (cellular-models isomorphic-coupling?) (m)
   (and
      (isomorphic-tab? (get-out-in-coup) (send m get-out-in-coup))
      (equal? (get-ext-coup) (send m get-ext-coup))
      (equal? (get-infl-origin) (send m get-infl-origin))
      (equal? (get-structure) (send m get-structure))
   )
)

(define-method (cellular-models add-port-pair)  ;;;influencee of origin
                   (influencee port-name1 port-name2)
   (table-insert-pair out-in-coup (list influencee port-name1) port-name2)
)

(define-method (cellular-models translate)(n1 n2 port-name)
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
                                      (- (car cpos2) co-or)
                                      (set! cpos2 (cdr cpos2))
                                      )
                                     ) cpos1))
                   )              
           (table-look-up out-in-coup (list influencee port-name))
           )
       ) 
   )
)              

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




;;;;;;;; called from construct-kernel in entrans.s

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



(define-method (cellular-models resume-methods)()
   (reload "cellu-me.f")
)

;;; working but very slow because of eval of delete-method ;;;
;(define-method (cellular-models delete-methods)()
;   (let (
;          (methods-deleted '(cell-pos->model copy&paste restore-state
;                             save-state num-created-cells  create-cell
;                             set-newcells-positions make-init-active-cells
;                             make-new init-new print-graph translate
;                             get-receivers get-influencees 
;                             isomorphic-coupling?))
;        )
;      (for-each (lambda(method)
;         (if (member method (methods cellular-models))
;             (eval `(delete-method (cellular-models ,method))))
;      ) methods-deleted)
;   )
;)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-method (cellular-models delete-methods)()
   (delete-method (cellular-models cell-pos->model)) 
   (delete-method (cellular-models copy&paste))
   (delete-method (cellular-models restore-state))
   (delete-method (cellular-models save-state)) 
   (delete-method (cellular-models num-created-cells))
   (delete-method (cellular-models create-cell))
   (delete-method (cellular-models set-newcells-positions)) 
   (delete-method (cellular-models make-init-active-cells))
   (delete-method (cellular-models make-new)) 
   (delete-method (cellular-models init-new)) 
   (delete-method (cellular-models print-graph)) 
   (delete-method (cellular-models translate))
   (delete-method (cellular-models get-receivers)) 
   (delete-method (cellular-models get-influencees)) 
   (delete-method (cellular-models ent->model)) 
   (delete-method (cellular-models complete-translation)) 
   (delete-method (cellular-models isomorphic-coupling?))
   (delete-method (cellular-models delete-methods))
)

;;
;;
;;  (make-cellular a)  ;a is an existing subclass of entities
;;         ;makes |ce-a| a coupled model AS w/ cellular coupling

(macro make-cellular (lambda (e)
  (let* (
          (class (cadr e))     ;on which cellular is based
          (cellular (symbol-append '|ce-| class))
          (co-ord (symbol-append '|C:ce-| class))
      )
     `(begin
         (mk-ent cellular-models ,cellular)(newline)
         (send ,cellular set-class ,class)
         (send ,cellular set-this-model ,cellular)
         (mk-ent co-ordinators ,co-ord)
         (send ,cellular make-init-cell)
         (attach ,co-ord ,cellular)
      )
   )
))



