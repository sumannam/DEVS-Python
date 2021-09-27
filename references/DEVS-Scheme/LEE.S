   ;;; LEE.S


   (define (rand  stream-num)
     (let (
   (remainder (modulo (* 630360016 (vector-ref iz-vector stream-num)) 2147483647))
          )

       (vector-set! iz-vector stream-num remainder)    
       (float (/ remainder 2147483647))
     )
   )


   (define iz-lst '(0  1973272912  281629770   20006270  1280689831 2096730329
       1933576050  913566091  246780520  1363774876  604901985
       1511192140 1259851944  824064364   150493284  242708531
         75253171 1964472944 1202299975   233217322 1911216000
        726370533  403498145  993232223  1103205531  762430696
       1922803170 1385516923   76271663   413682397  726466604
        336157058 1432650381 1120463904   595778810  877722890
       1046574445  68911991  2088367019   748545416  622401386
       2122378830 640690903  1774806513  2132545692 2079249579
         78130110 852776735  1187867272  1351423507 1645973084
       1997049139 922510944  2045512870   898585771  243649545
       1004818771  73686062   403188473   372279877 1901633463
        498067494 2087759558  493157915   597104727 1530940798
       1814496276  536444882 1663153658   855503735   67784357
       1432404475  619691088  119025595   880802310  176192644
       1116780070  277854671 1366580350  1142483975 2026948561
       1053920743  786262391 1792203830  1494667770 1923011392
       1433700034 1244184613 1147297105   539712780 1545929719
        190641742 1645390429  264907697   620389253 1502074852
        927711160  364849192 2049576050   638580085  547070247)             
   )


   (define iz-vector (list->vector iz-lst))

   ;reset all seeds to initial value
   
    (define (reset-seeds)
        (set! iz-vector (list->vector iz-lst))
    )
    ; cycle seeds: to start from successive seeds
    ; ...run...
    ; (reset-seeds)(cycle-seeds) ....run 
    ; (reset-seeds)(cycle-seeds)(cycle-seeds) ...run
    ; (reset-seeds)(cycle-seeds)(cycle-seeds)(cylce-seeds) ...run

    (define (cycle-seeds)
        (let* (
              (lst (vector->list iz-vector))
              (clst (append (cdr lst) (list (car lst))))
             )
        (set! iz-vector (list->vector lst))
    ))
        

   ;definition of function to set seed, izin for random generator, stream-num

   (define (randst izin stream-num)
       (vector-set! iz-vector stream-num izin)
       (vector-ref iz-vector stream-num)
   )

   ; definition of function to retrieve current integer in the sequence
   ; being generated and used by the random generator.

   (define (randgt stream-num)
       (vector-ref iz-vector stream-num)
   )

   ;;; distributions

   (define (unifrm low high stream-num)
     (float (+ low (* (rand stream-num) (- high low))))
   )

   (define (expon mean stream-num)
     (* (- mean) (log (rand stream-num)))
   )


   (define (normal mean sigma stream-num)
       (+ mean
         (* sigma
           (* (sqrt (* -2
               (log (rand stream-num) )))
             (cos (* (* 2 3.14159)
               (rand stream-num)) )
            )
          )
       )
   )

   (define (lognormal mean1 sigma1 stream-num)
     (let* (
    (mean1sq (* mean1 mean1))
    (v&m (+ (* sigma1 sigma1) mean1sq))
    (mean (log (/ mean1sq (sqrt v&m))))
    (sigma (abs (sqrt (log (/ v&m mean1sq)))))
    (y '())
   )
       (set! y (normal mean sigma stream-num))
       (exp y)
     )
   )
   
       

   ;;; tools for non-stationary poisson process using "Thinning algorithm".
   ;;; data independecy is not adopted yet.

   (define (linear t1 t2 v1 v2 time)
     (let* (
    (interval (- t2 t1))
    (slope (/ (- v2 v1) interval))
    (intercept (/ (- (* t2 v1) (* t1 v2))
  interval))
   )
       (float (+ (* slope time) intercept))
     )
   )

   (define (densityfn time)
     (define v1 (/ 274 60))
     (define v2 (/ 491 60))
     (define v3 (/ 656 60))
     (define v4 (/ 522 60))
     (define v5 (/ 437 60))
     (define v6 (/ 450 60))
     (cond
       ( (< time 30)
 (linear 0 30 0 v1 time) )

       ( (and (>= time 30)
      (<  time 90))
 (linear 30 90 v1 v2 time) )

       ( (and (>= time 90)
      (<  time 150))
 (linear 90 150 v2 v3 time) )

       ( (and (>= time 150)
      (<  time 210))
 (linear 150 210 v3 v4 time) )

       ( (and (>= time 210)
      (<  time 270))
 (linear 210 270 v4 v5 time) )

       ( (>= time 270)
 (linear 270 330 v5 v6 time) )
     )
   )

   (define (thinning time max-lambda stream1 stream2)
     (let rep (
       (u1 (rand stream1))
       (u2 (rand stream2))
       (next-t time)
      )
       (set! next-t (- next-t (* (/ 1 max-lambda) (log u1))))
       (if (<= u2 (/ (densityfn next-t) max-lambda))
   next-t
   (rep (rand stream1)
(rand stream2) 
next-t
           )
       )
     )
   )


   ;;; tools for data output format
   ;;; like as  F*.*  in FORTRAN,
   ;;; example : ($trunc 10.5892 2) => 10.58

;   (define ($trunc value digit)
;     (let* (
;    (divider (expt 10 digit))
;    (dividend (truncate (* value divider)))
;   )
;       (float (/ dividend divider))
;     )
;   )
              
(define ($trunc value digit)
     ($clip value digit)
)

(define ($clip num #-digs)    ;;used in atom-me.s
(define (fractional-part num)
(- num (floor num))
)

(cond
  ((number? num)
   (let* (
     (int-part (floor num))
     (frac (fractional-part num))
     (10-pow-#-digs (expt 10 #-digs))
     (mul-frac (* frac 10-pow-#-digs))
     (int-mul-frac (floor mul-frac))
     (norm-frac (/ int-mul-frac 10-pow-#-digs))
     )
   (+ int-part norm-frac)
   )
 )
 ((vector? num)($clip-vec num #-digs))
 (else num)
))

(define ($clip-vec vec #-digs)
(let (
     (lst (vector->list vec))
     )
(list->vector (map (lambda(el)($clip el #-digs)) lst))
))






