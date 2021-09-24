;;; RING-MODELS METHODS


(macro make-ring
  (lambda (e)
    (let* (
	   (class (cadr e))     ; on which ring is based
	   (class-name (symbol->string class))
	   (ring (string->symbol (string-append  "ri-" class-name)))
	   (co-ord (string->symbol (string-append "C@ri-" class-name)))
          )
      `(begin
	 (mk-ent ring-models ,ring) (newline)
	 (send ,ring set-class ,class)
	 (send ,ring set-this-model ,ring)
	 (mk-ent co-ordinators ,co-ord)
	 (send ,ring make-init-cell)
	 (attach ,co-ord ,ring)
       ) 
    )
  )
)


(define-method (ring-models make-members) (nm n)
   (make-kernel-members nm n)
   (set! top-child (car (get-children))); At the beginning child0 is top
   (set-allcell-positions)
;   (set-influencees-table)
   (get-children)
)

(define-method (ring-models set-allcell-positions) ()
   (let rep (
              (pos 0)
              (members (get-children))
            )
      (when members
         (send (car members) set-cell-position pos); 0 1 2 ...
         (rep (1+ pos) (cdr members))
      )
   )
)




(define-method (ring-models get-inf-numbers) (cell-pos)
  (let rep (
	    (sub backsteps)
	    (num-children (length (get-children)))
	    (return-lst '())
	   )
    (if ( < sub num-children)
	(begin
	  (set! return-lst
		(append return-lst
			(list (modulo (- (+ cell-pos num-children)
					 sub)
				      num-children))))
	  (rep (+ 2 sub) num-children return-lst)
        )
	return-lst
    )
  )
)

;(define-method (ring-models set-influencees-table) ()

(define-method (ring-models set-influencees-table) ()
  (let (
	(children-lst (get-children))
       )
;    (for-each
    (mapc
      (lambda (ch)
	(table-insert-pair influencees-table ch
			   (mapcar
			     (lambda (num)
			       (list-ref children-lst num))
			     (get-inf-numbers (get-cell-position ch)))))
      children-lst)
  )
)

; get-receivers returns the list of top child,
; then rotates the ring

(define-method (ring-models get-receivers)()
   (begin0
      (list top-child)
      (set! top-child (next-of top-child))
   )
)

(define-method (ring-models next-of) (this-child)
   (list-ref                          
      (get-children)
      (modulo (1+ (send this-child get-cell-position))
              (length (get-children))
      )
   )
)

; Every child sends the message only to next child on the ring

(define-method (ring-models get-influencees) (child)
   (table-look-up influencees-table child)
)


; The external input port of ring model is connected to top child.
; If ext-out-coup is top-child
;   then only top child's output port is connected to external output port
;   else {ext-out-coup id broadcast}
;     every child's output port is connected to external output port.
;

(define-method (ring-models translate)(n1 n2 port-name)
   (cond
     ((equal? n1 this-model)                  ;; external input
         (if (equal? n2 top-child)
              port-name))
     ((equal? n2 this-model)                  ;; external output
        (if (equal? ext-out-coup 'broadcast)
            port-name
            (if (equal? n1 top-child)
                port-name
            )
        ))
     (else                                    ;; internal coupling
       (if (equal? n2 (next-of n1))
          (table-look-up out-in-coup port-name)))
   )
)


(define-method (ring-models make-new)(new-inst-name)
   (let* ( 
          (models-class (eval (class-of-object (eval name))))
          (ri-inst-nm (gen-mem-name new-inst-name)); kernl-me.s
          (ri-inst-name (gen-name name-ctr (base-name ri-inst-nm))); enmanag.s
          (m (make-entity models-class ri-inst-name)); enti-me.s
          (co-nm  (symbol-append '|C@| ri-inst-name))
          (co (make-entity co-ordinators co-nm))        
          (old-children (get-children)); kernl-me.s 
          (old-init-cell (get-init-cell)); kernl-me.s |ri-PS-INIT-CELL|
          (num-children (length old-children))
          (mem-names (map (lambda(ch) (send ch get-name)) old-children))
          (mem-name (car mem-names))
         ; (mem-name (send (car old-children) get-name))
          (base-nm (base-name mem-name)); kim.s
          (class-name (gen-name name-ctr (symbol-append base-nm 's)))
;L          (originator (get-originator (eval class)))
          (originator (get-originator class)); model-me.s
         ) 
      (attach co m)
      (eval 
        `(begin
            (send ,old-init-cell make-class ',class-name); atom-me.s
            (send ,m set-this-model ,m)
            (send ,m set-out-in-coup (copy-table ,out-in-coup))
            (send ,m set-class ,class-name)
            (send ,m make-init-cell); kernl-me.s
            (send ,m make-true-members ',mem-names); kernl-me.s
         ;  (send ,m make-members ',base-nm ,num-children)
	    (send ,m set-top-child (car (send ,m get-children)))
	    (send ,m set-allcell-positions)

            (message-mode-off)
            (send (send ,m get-init-cell) copy-state ,old-init-cell); atom-me.s
            (message-mode-on)
            (define ,ri-inst-name ,m) 
            (define ,co-nm ,co) 
         ) user-initial-environment
      )
      (set-originator (send m get-class) originator)
      (writeln "ring model and co-ordinator made: "
                ri-inst-name  " " co-nm)
      m
   ) ;let
)

(define-method (ring-models init-new)()
  (window-popup initialize-window)
  (display-window initialize-window "init-new for " (get-name) )

  (let  (
	 (nm-or-list '())
	 (list-of-model-names '())
	 (nm '())
	 (num '())
	 (new-init-cell '())
        )
    (if (closure? (get-originator (eval class)))
	(make-pruned)
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
	     (for-each
	       (lambda(el)
		 (let (
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
	       )
	       list-of-model-names)
	    )
	    (nm (set-pseudo-class-lst (eval class) '())
		(make-members nm num))
         ); cond
        ); begin
     ); if
     (display-window initialize-window  #\newline
		     "enter out-in-coup table" #\newline
		     "as list of output-input port pairs ")
     (set-table out-in-coup '())
     (for-each
       (lambda(pair)
	 (add-port-pair (car pair)(cadr pair)))
       (read initialize-window))

     (set! new-init-cell (send-if-handles init-cell init-new))
     (when (not (null? new-init-cell))
       (send new-init-cell set-name (send init-cell get-name))
       (set-init-cell new-init-cell)
       (send-if-handles new-init-cell set-this-model new-init-cell)
     )
     (tell-atomic-children-their-names)
     this-model
  ); let*
)


(macro make-ring-class
  (lambda(e)
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
	   (mixins ring-models)
         )
	 (eval '(compile-class ,class-name))
       )
)))



(define-method (ring-models print-graph)()
  (let* (
	 (pair (cons this-model wind))
	 (orig-size (window-get-size wind))
	 (orig-pos (window-get-position wind))
	 (children (get-children))
	 (len  (+ (length children) 5))
	)
    (window-reduce-stack pair)
;L    (wpd pair)
    (wss wind len 50) 
    (wc wind)
    (display-window wind "  ring-model:"  #\newline #\newline "children: ")
    (for-each
      (lambda(child)
	(display-window wind (send child get-name) " ")
      ) children)          
    (display-window wind #\newline #\newline "out-int-coup table: " 
		    (get-table out-in-coup))
    (wss wind (car orig-size)(cdr orig-size))
    (wsp wind (car orig-pos)(cdr orig-pos))
))


; called from construct-kernel in entrans.s

(define-method (ring-models ent->model)(mult-nm . lst)
  (let (
	(children-ms (cadr lst))
       )
    (eval `(make-ring ,mult-nm) user-initial-environment)
    (set-pseudo-class-lst (eval mult-nm) children-ms)
))

(define-method (ring-models complete-translation)(out-in-couple . lst)
  (for-each
    (lambda(coup)
      (add-port-pair
            (car coup) (cadr coup)))
    out-in-couple)
)
;;;;;;;;;;;;;;;;;;


(define-method (ring-models isomorphic-coupling?) (m)
  (isomorphic-tab? (get-out-in-coup) (send m get-out-in-coup))
)

(define-method (ring-models delete-methods)()
   (delete-method (ring-models make-members))
   (delete-method (ring-models make-new)) 
;   (delete-method (ring-models init-new ))
   (delete-method (ring-models print-graph))
   (delete-method (ring-models translate)) 
   (delete-method (ring-models get-receivers ))
   (delete-method (ring-models get-influencees))
   (delete-method (ring-models ent->model))
   (delete-method (ring-models complete-translation))
   (delete-method (ring-models isomorphic-coupling?))
   (delete-method (ring-models delete-methods))
)






