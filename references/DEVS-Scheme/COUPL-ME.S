;; coupl-me.s

(alias en-base entstr-base_directory)
(alias mo-base model-base_directory)
(define-structure message source time content)
(define-structure content port value)



(define-method (coupled-models show-children)()
  (map (lambda(e) (send e get-name)) (get-children))
)

(define-method (coupled-models get-children)()
(print "returns subcomponents")
)

(define-method (coupled-models get-influencees) (child)
(print "returns influencees")
)
(define-method (coupled-models get-receivers)()
(print "returns receivers")
)

(define-method (coupled-models translate)(n1 n2 port-name)
(print "returns input port if it exists")
)


(define-method (coupled-models inject) (port value . elapsed-time)
(let (
      (e (when (number? (car elapsed-time)) (car elapsed-time)))
      (destinations (get-receivers))
     )
     (for-each (lambda(child)
             (let (
                  (tr-port (translate this-model child port))
                  )
              (when tr-port
               (if e
               (send child inject tr-port value e)
               (send child inject tr-port value)
               )
              )
             ))
               destinations)

)
)

;;;; added 3-19-90

(define-method (coupled-models tell-atomic-children-their-names)()
(for-each (lambda(ch)(send ch get-your-name)) (get-children))
)

(define-method (coupled-models get-your-name)()
(for-each (lambda(ch) (send ch get-your-name)) (get-children))
)


;;; -------------------;;;

(define (initial-structure model)
    (attach (send model get-processor) model)
    (if (specialized-class model 'coupled-models)
        (for-each (lambda (chd)
                      (send chd set-parent model)
                      (initial-structure chd)
                  )      (send model get-children) ) ;must re-initialize
   )                                                 ;with change in children
)






;;----------------------------------------------------------
;;             Additional coupled-models methods for
;;             new-window display
;;----------------------------------------------------------

(define nw-uly-coupled 17) ;; nw upper left y point window of coupled-models
(define nw-ulx-coupled 20) ;; nw upper left x point      "
(define nw-yl-coupled 3)   ;; nw y length of coupled-models
(define nw-xl-coupled 10)  ;; nw x          "

(define-method (coupled-models initial-wind) ()
 (let* ( (banner (symbol->string name))
         (wind (make-window banner #!true))
      )
      (window-set-position! wind nw-uly-coupled (+ nw-ulx-coupled 1))
      (window-set-size! wind nw-yl-coupled
                        (max nw-xl-coupled (string-length (symbol->string name)))
      )
      (set-nw 'wind wind)
 )
)



;;-------------------------------------------------------------------
;; display-nw :
;;
;; mes-cont : I/O message
;; mes-source : the model which sent current message to this coupled-model
;;-------------------------------------------------------------------

(define-method (coupled-models display-nw) (mes-cont mes-source)
  (let* ( (port (if (pair? (content-port mes-cont))
                    (cadr (content-port mes-cont))
                    (content-port mes-cont)
                 )
          )  ;; check for level access port format
          (value (content-value mes-cont))
          (port-wind (make-window (symbol->string port) #!true))
        )
        (window-set-attribute! port-wind 'window-flags 2) ; truncate data
        (when (not (environment? mes-source))
              (set! mes-source (eval mes-source))
        )
        (if (member mes-source (get-children))
            (window-set-position! port-wind
              (+ nw-uly-coupled 1) (+ nw-ulx-coupled 2
                                      (max nw-xl-coupled
                                           (string-length
                                             (symbol->string name)
                                           )
                                      )
                                   )
            ) ;; output port
            (window-set-position! port-wind
              (+ nw-uly-coupled 1) (- nw-ulx-coupled 18)
            ) ;; input port
        )
        (window-set-size! port-wind 1 18) ;; 1 y-port-length  18 x-length

        (window-popup port-wind)
        (display value port-wind)

        (window-clear (get-nw 'wind)) ; window-clear for clean edege
        (display " " (get-nw 'wind))


  ) ;; let
)


(define-method (coupled-models hide-nw-children)()
  (for-each (lambda (chd)
                    (begin
                      (send chd set-nw 'display #f)
                      (when (not (atomic-eq? chd))
                            (send chd hide-nw-children)
                      )
                    ) ;; begin
            )
            (get-children)
  )
)



