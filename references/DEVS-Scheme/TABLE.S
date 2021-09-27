;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;table.s;;;;;;;;;;;;;;

;table of pairs

(build-module table
   (
   (table '())
   )
(
(set-table (val) (lambda(val)(set! table val)))
(get-table () (lambda()table))
)
)

(define (table-insert-pair table port-name1 port-name2)
   (let rep (
            (tab (get-table table))
            )
   (cond
     ( (null? tab)  (set-table table (cons (cons port-name1 port-name2)
                       (get-table table))))
     ( (equal? (caar tab) port-name1)  (display port-name1)
               (display " already associated"))
     ( else  (rep (cdr tab))   )
   )
))

(define (table-delete-pair table port-name)
   (let rep (
            (tab (get-table table))
            (front '())
            )
  (cond
  ( (null? tab) (display "error: no such port-name"))
  ( (equal? (caar tab) port-name)  (set-table table (append front (cdr tab))))
  ( else  (rep (cdr tab) (cons (car tab) front)))
  )
))

(define (table-look-up table port-name)
  (let rep (
           (tab (get-table table))
           )
  (cond
  ( (null? tab) '())
  ( (equal? (caar tab) port-name) (cdar tab)  )
  ( else  (rep (cdr tab))   )
 )
))


(define (copy-table tab)
   (let rep (
              (tab-lst (reverse (get-table tab)))
              (cp-tab (table))
            )
      (if (not tab-lst)
         cp-tab
         (begin
            (table-insert-pair cp-tab (car (car tab-lst)) (cdr (car tab-lst)))
            (rep (cdr tab-lst) cp-tab))
      )
   )
)

(define (isomorphic-tab? table1 table2)
   (if (not (equal? (length (get-table table1)) (length (get-table table2))))
       #!false
       (let rep (
                  (tab1-lst (get-table table1))
                  (tab2-lst (get-table table2))
                  (isomorphic #!true)
                )
          (cond
             ( (not isomorphic) #!false)
             ( (null? tab1-lst) #!true)
             ( else
                 (when (not (member (car tab1-lst) tab2-lst))
                    (set! isomorphic '()))
                 (rep (cdr tab1-lst) tab2-lst isomorphic))
          )
      )
   )
)

(alias #nl #\newline)


