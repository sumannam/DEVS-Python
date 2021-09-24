;;;;;; vector.s ;;;;;;;;
(define (vector-add v1 v2)
(let (
     (l1 (vector->list v1))
     (l2 (vector->list v2))
     )
(cond
 ((= (length l1)(length l2))
    (list->vector (map (lambda (el)(begin0 (+ el (car l2))
                               (set! l2 (cdr l2))
                               )
                   )l1)
    )
 )
 (else (display "vectors of unequal length") '())
)
))


(define (scalar-mult scal vec)
(if (number? scal)
 (let (
     (lst (vector->list vec))
     )
 (list->vector (map (lambda(el)(* scal el)) lst))
 )
vec
)
)


(define (vector-sub v1 v2)
(let (
     (l1 (vector->list v1))
     (l2 (vector->list v2))
     )
(cond
 ((= (length l1)(length l2))
    (list->vector (map (lambda (el)(begin0 (- el (car l2))
                               (set! l2 (cdr l2))
                               )
                   )l1)
    )
 )
 (else (display "vectors of unequal length") '())
)
))


(define (vector-normalize vec)
(let (
     (lst (vector->list vec))
     (mag (vector-magnitude vec))
     )
(cond
 ( (> mag 0)
    (set! lst (map (lambda(el)(/ el  mag)) lst))
    (list->vector lst)
 )
 (else (error "improper magnitude" mag))
)
))

(define (vector-magnitude vec)
(let (
     (lst (vector->list vec))
     (sum 0)
     )
(for-each (lambda(el)(set! sum (+ sum (* el el)))) lst)
(sqrt sum)
))


(define (geometric-distance loc1 loc2)
(let (
     (loc1 (vector->list loc1))
     (loc2 (vector->list loc2))
     )
  (when (not (equal? (length loc1)(length loc2)))
   (error "Dimension is not compatible"))
  (let  rep (
             (x1 loc1)
             (x2 loc2)
             (dist 0 )
            )

      (if (null? x1)
        (sqrt dist)
        (rep (cdr x1) (cdr x2)
             (+ dist (* (- (car x1) (car x2))(- (car x1)(car x2)))))
     )
  )
))



(define (city-block-distance loc1 loc2)
(let (
     (loc1 (vector->list loc1))
     (loc2 (vector->list loc2))
     )
  (when (not (equal? (length loc1)(length loc2)))
   (error "Dimension is not compatible"))
  (let  rep (
             (x1 loc1)
             (x2 loc2)
             (dist 0 )
            )
     (if (null? x1)
        dist
        (rep (cdr x1)(cdr x2) (+ dist (abs (- (car x1)(car x2)))))
     )
   )
))                  

;;;;;;;;;;;;;;;;;;;;

(define (direction-fn destination position)
(vector-normalize (vector-sub destination position))
)

(define (travel-time-fn destination position speed time-step)
(let* (
     (distance (geometric-distance destination position))
     (displacement (* time-step speed))
     (num-steps (when (> displacement 0)
                    (floor (/ distance displacement))))
     )
(if (> displacement 0)
        (* time-step num-steps)
        'inf
)
))


(define (neighbor-fn distance-metric loc1 loc2 range)
      (when
               (<= (distance-metric loc1 loc2) range)

       loc2
))

(define (closest-fn loc loc-lst)
 (let (
      (l (length loc-lst))
      )
  (case l
    (0 '())
    (1  (list-ref loc-lst 0))
    (else
      (let  (
            (min-dis (geometric-distance loc (list-ref loc-lst 0)))
            (index 0)
            )
         ( do ((i 1 (1+ i)))
           ((>= i l) (list-ref loc-lst index))
          (let (
                (dis (geometric-distance loc (list-ref loc-lst i)))
               )     
          (if (< dis min-dis)
              (begin (set! min-dis dis)
                     (set! index i)))
          
       )))
     )
)))
