;;;;;;;;;;;;;;;;;;;;;;;;;;;;;list.s;;;;;;;;;;;;;;

(define (sort rank-fn lst mx mn)
 (case (length lst)
 ((0 1) lst)
 (2 (if (< (rank-fn (car lst))(rank-fn (cadr lst)))
                       (cons (cadr lst)(list (car lst)))
        lst))
 (else
      (let ( (sep (/ (+ mx mn) 2)) (above '()) (below '()) )
     (if (= sep mx) lst (begin (for-each (lambda(e)(if (> (rank-fn e) sep)
             (set! above
                      (append above (list e)))
                             (set! below (append below (list e)))) ) lst)
         (append (sort rank-fn above mx sep) (sort rank-fn below sep mn)) )))
)))

(define (bubble valfn lst)
(let rep (
         (front (list (car lst)))
         (rlst (cdr lst))
         )
 (cond
 ((null? rlst) front)
 ( (> (valfn (car rlst)) (valfn (car front)))
       (rep (append (list (car rlst)) (cdr front))
                (append (list (car front)) (cdr rlst))))
(else (rep (append front (list (car rlst))) (cdr rlst)))
)))

(define (sort-num valfn lst num)
(let rep (
         (count (min num (length lst)))
         (olst '())
         (lst (bubble valfn lst))
         )
(if (<= count 0) olst
    (rep (-1+ count) (append olst (list (car lst))) (bubble valfn (cdr lst)))
)))


(define (reduce lst size)
(let rep (
      (rlst lst)
      (front '())
      (ind 1)
      (place (1+ (random (length lst))))
     )
 (cond
  ( (<= size 0) '())
  ( (<= (length lst) size) lst)
  ( (= ind place)(reduce (append front (cdr rlst)) size) )
 ( else (rep (cdr rlst) (append front (list (car rlst))) (1+ ind) place))
)))

(define (gen-cross-product set1 set2)
(let
   rep (
      (lst1 set1)
      (lst2 set2)
      (lst3 '())
      )
(if (null? lst1) lst3
    (if (null? lst2) (rep (cdr lst1) set2 lst3)
        (rep lst1 (cdr lst2) (append lst3 (list (cons (car lst1) (car lst2)))))
    )
)))

(define (cross-product lst)
(gen-cross-product lst lst))

;(define (reduce lst size)
;(cond
 ; ((<= (length lst) size) lst)
 ; (else (reduce (cdr lst) size))
;))

(define (remove-mult lst)  ;subsequent instances of elements are removed
(let (
     (nlst '())
     )
(for-each (lambda(e)(when (not (member e nlst))
            (set! nlst (append nlst (list e))))) lst)
nlst
))


(define (clean lst)
(let rep (
         (front '())
         (rlst lst)
         )
(cond
 ( (null? rlst) front)
 ( (null? (car rlst)) (rep front (cdr rlst)))
 ( else (rep (append front (list (car rlst))) (cdr rlst)))
)))

(define (remove el lst)
(let rep (
         (lst lst)
         (front '())
        )
(cond
   ( (null? lst) (display "element not found") lst)
   ( (equal? el (car lst)) (append front (cdr lst)))
   ( else (rep (cdr lst) (append front (list (car lst)))))
)
))

(define (union2 lst1 lst2)                   ;order in lst2 is affected
(clean (remove-mult (append lst1 lst2)))
)

(define (union lst-of-lists)
(let (
     (lst '())
     )
(for-each (lambda(l)(set! lst (union2 lst l))) lst-of-lists)
lst
))

(define (align lst lst2)     ; rearange lst2 to be compatible with lst 
(clean (map (lambda(e)(if (member e lst2) e)) lst))
)

(define (best-key valfn key-extract lst key)
(let (
     (klst (clean (map (lambda(n)(if (equal? (key-extract n) key) n)) lst)))
     )
 (sort-num valfn klst 1)
))

(define (best-keys valfn key-extract lst)
(let(
    (keys (remove-mult(clean (map (lambda(n)(key-extract n)) lst))))
    )
(union (map (lambda(key)(best-key valfn key-extract lst key)) keys))
))


(define (intersect set1 set2)
(let (
     (ans '())
     )
(for-each (lambda(el)(if (member el set2)
               (set! ans (append ans (list el))))) set1)
ans
))

(define (subset set1 set2)
(= (length (intersect set1 set2)) (length set1)))

(define (difference set1 set2)
(let (
     (ans '())
     )
(for-each (lambda(el)(if (not (member el set2))
               (set! ans (append ans (list el))))) set1)
ans
))


(define (position elem lst)
 (- (length lst) (length (member elem lst)))
)
