;;;; relation.s ;;;;;;



(define (assign-index lst)
(let (
     (index 0)
     )
(map (lambda(el)(begin0 (list el index ) (set! index (1+ index)))) lst)
))

(define (match value-list spec-list dont-care)
(when (= (length value-list) (length spec-list))
(cond
( (null? value-list) #!true)
( (equal? (car spec-list) dont-care)
                (match (cdr value-list)(cdr spec-list)dont-care))
( (equal? (car spec-list) (car value-list))
                (match (cdr value-list)(cdr spec-list) dont-care))
))
)

(build-module relation
    (
    (arity 0)
    (attributes '())
    (assoc-list '())
    (tuples '())
    )
    ( 
(set-attributes (attribs)(lambda(attribs)
          (set! arity (length attribs))
          (set! attributes attribs)
          (set! assoc-list (assign-index attribs)))
)
(get-attributes ()(lambda()attributes))
(get-assoc-list ()(lambda()assoc-list))
(assert-rel (value-list)(lambda(value-list)
     (when (= (length value-list) arity)
        (set! tuples (append tuples (list value-list)))
     )))                       
(retract (value-list)(lambda(value-list)
        (set! tuples (remove value-list tuples))))
(get-tuples ()(lambda()tuples)) 
(set-tuples (tuplist)(lambda(tuplist)(set! tuples tuplist)))
     )
)


(define (select-rel rel spec-list)
(clean
(map (lambda(val-lst)(when (match val-lst spec-list '-)
                        val-lst)) (get-tuples rel)))
)


(define (set-value-list rel)
(assert-rel rel
  (map (lambda(atr)
    (writeln "The attribute is: " atr " Enter value: ")
    (read)) (get-attributes rel))
))

(define (get-related rel attribute-value-list)
(let* (
      (domain (clean (map (lambda(attr)(if (assoc attr attribute-value-list)
                  attr)) (get-attributes rel))))
      (range (difference (get-attributes rel) domain))
      (spec-list (map (lambda(attr)(if (member attr domain)
             (cadr (assoc attr attribute-value-list)) '-)) (get-attributes rel)))
      (selected-tuples (select-rel rel spec-list))
      )
(map (lambda(tup)(get-values-of range tup (get-assoc-list rel)))
     selected-tuples)
))

(define (get-values-of attributes value-list assoc-list)
(map (lambda(attribute)
      (list attribute
       (list-ref value-list (cadr (assoc attribute assoc-list)))))
    attributes)
)


(define (get-range-rel rel attr)
(let* (
      (assoc-list (get-assoc-list rel))
      (index '())
      (tuples (get-tuples rel))
      )
(set! index (cadar (clean (map (lambda(pair)(when (equal? (car pair) attr)
pair)) assoc-list))))
(remove-mult (map (lambda(tuple)(list-ref  tuple index)) tuples))
))


(define (project-on-rel rel attr-list) ;;projects tuples on attribute list
(let* (                                ;;returns list of shorter tuples
      (assoc-list (get-assoc-list rel))
      (index-list '())
      (tuples (get-tuples rel))
      )
(set! index-list
        (clean (map (lambda(pair)(when (member (car pair) attr-list)
               (cadr pair))) assoc-list)))
(remove-mult (map (lambda(tuple)
          (clean (map (lambda(index)(list-ref tuple index))index-list))
                  )tuples))
))

;;;;;;;;;;;;;;;;;;;add to relation.s

(define (*get-related rel attribute-value-list) ;;returns tuples
(let* (
      (domain (clean (map (lambda(attr)(if (assoc attr attribute-value-list)
                  attr)) (get-attributes rel))))
      (range (difference (get-attributes rel) domain))
      (spec-list (map (lambda(attr)(if (member attr domain)
             (cadr (assoc attr attribute-value-list)) '-)) (get-attributes rel)))
      (selected-tuples (select-rel rel spec-list))
      )
selected-tuples
))


(define (project-on-attr rel tuple attribute) ;;projects tuple on attribute 
(let* (
      (assoc-list (get-assoc-list rel))
      (index '())
      )
(set! index (car
     (clean (map(lambda(pair)(when (equal? (car pair) attribute)
               (cadr pair))) assoc-list))))
(when index (list-ref tuple index))
))

;;;;;;;;;;;;;;;;;;;;;end relation.s

;;;;;;;;;;; example ;;;;;;;;;;;;

;(define rel (relation))
;(set-attributes rel '(class location orientation))
;(assert-rel rel '(sphere #(1 1) #(0 1)))
;(assert-rel rel '(box #(2 0) #(1 0)))
;(assert-rel rel '(sphere #(4 5 ) #(0 1)))


;(get-related rel '((location #(2 2))))
 
; domain is : (location)
; range  is : (class orientation)
; spec-list is : (- #(2 2) -)
; selected-tuples are : ((box #(2 2) #(1 0)))
; (((class box) (orientation #(1 0))))


;(define rel (relation))
;(set-attributes rel '(channel computer measured-variable location))
;(assert-rel rel '(ch1 comp1 temperature plot1))
;(assert-rel rel '(ch2 comp1 humidity plot1))
;(assert-rel rel '(ch3 comp1 temperature plot1))
;(assert-rel rel '(ch1 comp2 temperature plot2))
;(assert-rel rel '(ch2 comp2 humidity plot2))
;(assert-rel rel '(ch3 comp2 humidity plot1))
;
;(get-related rel '((computer comp1) (measured-variable temperature)))
;(get-related rel '((location plot1)(measured-variable humidity)))


;(define data (relation))
;(set-attributes data '(channel computer date value))
;(assert-rel data '(ch1 comp1 today v1))
;(assert-rel data '(ch1 comp1 tomorrow v2))
;(assert-rel data '(ch1 comp1 yesterday v3))
;(assert-rel data '(ch2 comp1 today v4))
;(assert-rel data '(ch2 comp1 tomorrow v5))
;(assert-rel data '(ch3 comp1 yesterday v6))
;
;(define (get-data-rel rel location measured-variable)
;(let (
;     (attribute-value-list (list `(location ,location)
;                                 `(measured-variable ,measured-variable)))
;    )
;(map (lambda(al)(get-related data al))
;           (get-related rel attribute-value-list))
;
;))
;
;(define (get-data-date date location measured-variable)
;(let (
;     (rel (cadr (get-related time-stamped (list `(date ,date)))))
;    )
;(get-data-rel rel location measured-variable)
;))
;
;
;(define time-stamped (relation))
;(set-attributes time-stamped '(date relation))
;(assert-rel time-stamped '(today rel1))
;(assert-rel time-stamped '(yesterday rel1))
;
;(define (make-rel)
;(let (
;     (rel (gen-name name-ctr 'rel))
;     )
; (eval `(define ',rel (relation)) user-initial-environment)
; (set-attributes (eval rel) '(channel computer measured-variable location))
; (assert-rel time-stamped '(((runtime) rel)))
; (writeln "channel-relation made named " rel " and time-stamped")
; (writeln "use <set-value-list " rel "> to assert tuples")
;))
;
;;(make-rel)
;;(get-data-rel rel0 'plot1 'temperature)




