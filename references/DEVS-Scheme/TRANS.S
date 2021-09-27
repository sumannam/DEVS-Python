;; trans.s



;; translation methods for level access






(define (content-port-method x)(cadr (content-port x)))
(define (content-port-receiver x)(car (content-port x)))






 ;;;;;;;;; define helper fuctions


(define (content-port-name-or-pair x)
  (if (pair? (content-port x))
      (content-port-method x)
      (content-port x)
  )
)








;;;;;;;;;; changes from dimod-me.s

;; port-name-or-pair is either 'out or '(m1 out)

(define-method (digraph-models translate)(n1 n2 port-name-or-pair)
  (if (pair? port-name-or-pair)
     (let  ( (receiver (car port-name-or-pair))
             (method (cadr port-name-or-pair))
           )

      (cond
         ( (and (equal? n2 this-model)
                (or (equal? (send n2 get-name) receiver)
                    (not (equal? (component-relation? n2 receiver)
                                 'sub-component
                         )
                    )
                )
           )



           (if (null?
                    (bi-associate composition-tree
                             (find-edge (bi-edges? composition-tree) n1 n2)
                                        method)
               )
               port-name-or-pair
               (list  receiver
                    (bi-associate composition-tree
                             (find-edge (bi-edges? composition-tree) n1 n2)
                                        method)
               )
           ) ;; if
         )          ;;;; external output

         ( (and (equal? n1 this-model)
                (or (equal? (send n2 get-name) receiver)
                    (equal? (component-relation? n2 receiver)
                            'sub-component
                    )
                )
           )

           (if (null?
                    (bi-associate composition-tree
                             (find-edge (bi-edges? composition-tree) n1 n2)
                                        method)
               )
               port-name-or-pair
               (list  receiver
                      (bi-associate composition-tree
                             (find-edge (bi-edges? composition-tree) n1 n2)
                                        method)
               )
           ) ;; if
         )          ;;;; external input to a atomic model




         ( (and (equal? n1 this-model)
                (equal? (send n1 get-name) receiver)
           )
           (list (send n2 get-name) method)
         )   ;; external input to all children



         ( (member n1 (send this-model get-children))
           (let (
                  (edge (find-edge (edges? influence-digraph)
                                                          n1 n2))
                )
             (if (null?
                    (when edge (associate influence-digraph   edge
                                                  method))
                 )
                (when
                  (and
                     (equal? (component-relation? n1 (send n2 get-name))
                                 'sibling-component
                     )  ;; to prevent external output effect

                     (or (equal? (component-relation? n2 receiver)
                                 'sub-component
                         )
                         (equal? (send n2 get-name) receiver)
                      )
                  )  ;; and
                 port-name-or-pair
               ) ;; when
               (list receiver
                  (when edge (associate influence-digraph   edge
                                             method))
               )
             ) ;; if
           ) ;; let
         )          ;;; internal
          ;; Internal translation of diagraph models only is
          ;; coupling dominent, i.e., coupling is checked first.  If no
          ;; coupling then receiver is checked. The reason for this
          ;; coupling dominency is that when the model to receive the
          ;; message does not have hierarchical name.
          ;; All other translations and other class's all translations
          ;; are receiver dominent.

          ;; Needed for A.out --> B.in    where  A want to send a message
          ;; to a child of B model by level access and B does not have
          ;; hierarchical name




      ) ;; cond

     ) ;; let
     (if (or
       (equal? n1 this-model) (equal? n2 this-model))
                  (bi-associate composition-tree
                                (find-edge (bi-edges? composition-tree) n1 n2)
                                           port-name-or-pair)
       (let (
            (edge (find-edge (edges? influence-digraph)
                                                         n1 n2))
            )
            (when edge (associate influence-digraph   edge
                                          port-name-or-pair))
      )
    )
  )
)




;;;;; changes made from broad-me.s

(define-method (broadcast-models translate) (n1 n2 port-name-or-pair)
  (if (pair? port-name-or-pair)
      (let ( (receiver (car port-name-or-pair))
             (method (cadr port-name-or-pair))
           )

        (cond
         ( (and (equal? n2 this-model)
                (or (equal? (send n2 get-name) receiver)
                    (not (equal? (component-relation? n2 receiver)
                                 'sub-component
                         )
                    )
                )
           )

            port-name-or-pair
          )
              ;; external output


          ( (and (equal? n1 this-model)
                 (or (equal? (component-relation? n2 receiver)
                             'sub-component
                     )
                     (equal? (send n2 get-name) receiver)
                 )
            )


            port-name-or-pair
          )   ;; external input to a atomic model



         ( (and (equal? n1 this-model)
                (equal? (send n1 get-name) receiver)
           )
           (list (send n2 get-name) method)
         )   ;; external input to all children




          ( (and (equal? (component-relation?  n1 (send n2 get-name))
                    'sibling-component
                 )
                 (or (equal? (component-relation? n2 receiver)
                             'sub-component
                     )
                     (equal? (send n2 get-name) receiver)
                 )
            )





            (list receiver
                  (let ( (method1 (table-look-up out-in-coup method)) )
                       (if  method1
                            method1
                            method
                       )
                  )
            )
          )   ;; internal
        )
      ) ;; let

      (if (or (equal? n1 this-model) (equal? n2 this-model))
          port-name-or-pair
          (table-look-up out-in-coup port-name-or-pair)
      )
      ;(cond
      ;  ((equal? n2 this-model) port-name-or-pair)
      ;  ((and (equal? n1 this-model)
      ;        (equal? n2 (car (send this-model get-children)) )
      ;    )
      ;    port-name-or-pair
      ;  )
      ;  (else (table-look-up out-in-coup port-name-or-pair))
      ;)
      ;   ;; for the first child to the input like in pipeline
      ;   ;; only external input is affected
  )
)







;;;;; changes made from contr-me.s


(define-method (controlled-models get-receivers)()
    (append (list controller) (get-pseudo-class-lst (eval class)))
)
 ;;from outside send only to controller



;; - e.g. port-name-or-pair is either 'out or (list tc0 'in-pac)
;; - in translating controlees to controller also first refers to
;;   out-in-coup table

(define-method (controlled-models translate)(n1 n2 port-name-or-pair)
(if (pair? port-name-or-pair)
  (let* ( (receiver (car port-name-or-pair))
          (method (cadr port-name-or-pair))
       )

    (cond
      ( (and (equal? n1 this-model)
             (or (equal? (component-relation? n2 receiver)
                         'sub-component
                 )
                 (equal? (send n2 get-name) receiver)
             )
        )

        port-name-or-pair
      )     ;; external input to a atomic-model




         ( (and (equal? n1 this-model)
                (equal? (send n1 get-name) receiver)
           )

           (list (send n2 get-name) method)
         )   ;; external input to all children





         ( (and (equal? n2 this-model)
                (or (equal? (send n2 get-name) receiver)
                    (not (equal? (component-relation? n2 receiver)
                                 'sub-component
                         )
                    )
                )
           )

           port-name-or-pair
      ) ;; external output


      ( (and (member n1 (get-pseudo-class-lst (eval class)))
             (equal? n2 controller)
             (or (equal? (send n2 get-name) receiver)
                 (equal? (component-relation? n2 receiver)
                          'sub-component
                 )  ;; if controller is coupled-model
             )
        )


        (let (
               (method1 (table-look-up out-in-coup method) )
             )
             (if method1
                 (list receiver method1)
                 port-name-or-pair
             )
        )
      )
               ;;;controllees to controller



      ( (and (equal? n1 controller)
             (member n2 (get-pseudo-class-lst (eval class)))
             (or (equal? (component-relation? n2 receiver)
                         'sub-component
                 )
                 (equal? (send n2 get-name) receiver)
             )
          )


        (let (
               (method1 (table-look-up out-in-coup method) )
             )
             (if method1
                 (list receiver method1)
                 port-name-or-pair
             )
        )
      )
               ;;;controller to controllees

    ) ;; cond
  )
  (cond
    ( (and (equal? n1 this-model) (equal? n2 controller)) port-name-or-pair)
             ;;;external input
    ( (and (equal? n2 this-model)
           (equal? n1 controller)

         ;;  (null? (table-look-up out-in-coup port-name-or-pair))
                     ;; to prevent unecessary effect
      )

       port-name-or-pair
    )
           ;;;external output

    ( (and (member n1 (get-pseudo-class-lst (eval class)))
           (equal? n2 controller))
         (let (
              (out-port (table-look-up out-in-coup port-name-or-pair) )
              )
           (if out-port out-port port-name-or-pair)
          )
    )
             ;;;controllees to controller


    ( (and (member n2  (get-influencees controller))
           (equal? n1 controller)
      )
         (let (
              (out-port (table-look-up out-in-coup port-name-or-pair) )
              )
           (if out-port out-port port-name-or-pair)
          )
    )
            ;;;controller to controllees: if in out-in-coup use, else identity
  ) ;; cond
) ;; if
)





;; --------------------------------------------------------------
;; make-into-list: makes symbol into list seperated by sym
;; usage:   (make-into-list '< '(tc0<TCS<tcu0)) => '(tc0 TCS tcu0)
;; --------------------------------------------------------------


(define (make-into-list sym sym-name)
  (let loop ( (lst '()) (sub-lst '()) (name (explode sym-name)) )
    (cond
        ( (null? name) (append lst (list (implode sub-lst))))
        ( (equal? sym (car name))
          (loop (append lst (list (implode sub-lst)))
                '()
                (cdr name)
          )
        )
        (else
          (loop lst
                (append sub-lst (list (car name)))
                (cdr name)
          )
        )
    ) ; cond
  ) ; let
)






;; --------------------------------------------------------------
;; (component-relation? n receiver): Tests whether receiver is
;;     sub-component, external-component or sibling-component of
;;     n2. If n and receiver are same component, 'identical returned.
;;
;;
;; usage:
;;    (component-relation?    cc<wcell0<wcells<wcu0
;;                         'pu<cc<wcell0<wcells<wcu0)
;;    => sub-component
;;
;;
;;
;;    (component-relation?       wcell0<wcells<wcu0
;;                               wcell1<wcells<wcu0)
;;    => sibling-component
;;
;;
;;
;;    (component-relation?    cc<wcell0<wcells<wcu0
;;                              'wcell0<wcells<wcu0)
;;    => external-component
;;
;;
;;    (component-relation?    cc<wcell0<wcells<wcu0
;;                           'cc<wcell1<wcells<wcu0)
;;    => external-component
;;
;;
;;    (component-relation?       wcell0<wcells<wcu0
;;                              'wcell3<wcells<wcu1)
;;    => external-component
;;
;;
;;    (component-relation?       wcell0<wcells<wcu0
;;                              'hc)
;;    => external-component
;;            ;; non-hierarchical receiver is treated as external-componet
;;
;;
;;    (component-ralation?       |co-WCELLS|<wcu0
;;                               'wcell0<wcells<wcu0)
;;    => sub-component
;;            ;;    |...| is ignored in comparison
;; --------------------------------------------------------------





(define (component-relation? n receiver)
(let ( (n-sym (if (symbol? n) n (send n get-name)))
       (first t)
     )

  (if (equal? n-sym receiver)
      'identical
      (let loop ( (lst1 (reverse (make-into-list '< n-sym)) )
                  (lst2 (reverse (make-into-list '< receiver)) )
               )

         (when  (not first)
           (when (member (car (explode (car lst1)))
                        '(|b| |c| |h| |c| |r| |t|)
                 )
                (set! lst1 (cdr lst1))
           ) ;; ignore |co-WECLLS| type name if not first ele,
             ;; to make wcell0<wcells<wcu0 sub-component of
             ;; |co-WCELLS|<wcu0
         )
             ;; flag first is tested for |br-WCUS|



         (if (and first
                  (equal? (length lst1) 1)
                  (kernnel-class? (car lst1))
             )

             (let ((rel 'sibling-component))
                 (set! first '())
                 (for-each (lambda (child)
                   (let  ( ( relation
                             (loop
                               (reverse
                                 (make-into-list '< (send child get-name))
                               )
                               lst2
                             )
                           )
                         )
                         (when (not (equal? rel 'sub-component) )
                               ;; main purpose is to find out sub-component
                               ;; relation, so try until sub-component
                               ;; relation is found

                           (if   (or (equal? relation 'sub-component)
                                     (equal? relation 'identical)
                                 )
                                 (set! rel 'sub-component)
                                    ;; e.g.
                                    ;; n = |br-WCUS|
                                    ;; receiver = wcell0<wcells<wcu0

                                 (when (>? (length lst2) 1)
                                       (set! rel 'external-component)
                                 )  ;; n = |br-WCUS|
                                    ;; receiver = wcell0<wcells<wcu5

                           )
                         ) ;; when

                   ) ;; let
                           ) (send n get-children)
                 ) ;; for-each
                 rel
             ) ;; let


             (if (equal? (car lst1) (car lst2))
               (if (and (null? lst1) (null? lst2))
                   'identical     ;; n = |br-MS|<n1
                                  ;; receiver = 'n1
                   (begin
                       (set! first '())
                       (loop (cdr lst1) (cdr lst2))
                   )
               )
               (cond
                 ( (and (null? lst1) (not (null? lst2))) 'sub-component)
                 ( (and (not (null? lst1)) (null? lst2)) 'external-component)
                 ( (and (null? (cdr lst1))(null? (cdr lst2)))
                   'sibling-component
                 )
                 ( (and  (member (car (explode (car (cdr lst1))))
                             '(|b| |c| |h| |r| |t|)
                         )
                         (member (car (explode (car (cdr lst2))))
                             '(|b| |c| |h| |r| |t|)
                         )
                   )
                   'sibling-component
                 )   ;; case for        n = |co-WCELLS|<wcu0
                     ;;          receiver = |co-WCELLS|<wcu1

                 ( else 'external-component)
               )
             )
         ) ;; if (and first ...

      ) ;; let
  ) ;; if
))




(define (kernnel-class? n)
  (member (class-of-object (eval n user-initial-environment))
         '(broadcast-models controlled-models ...)
  )
)


