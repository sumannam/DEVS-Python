
(build-module name-directory
   (
   (names '())
   (synonyms '())
   )

   (
(set-names$ (name-lst) (lambda(name-lst)(set! names name-lst)))
(set-synonyms$ (syn-lst)(lambda(syn-lst)(set! synonyms syn-lst)))
(show-dir$ ()(lambda()
  (get-assoc$ "Press <CR> to select " '(4 1) 11 14 95
       names synonyms)
 ))
   )
)

(define name-dir$ (name-directory))
(define (get-syn$)(show-dir$ name-dir$))

(define (get-syn)(eval (get-syn$) user-initial-environment))

;;example of use:
;; (transform p:big-ent)
;; (send r:big-ent make-dir)
;; (send (get-syn) print-graph, set-state, or any-model-method)
;; or use synonym obtained from (get-syn) within (res r:big-ent) 


;;;needs menu.f

(define (get-assoc$ name pos bord-color text-color focus-color string expl)

  (let (
        (part-lst '())
        (exceed 0)  ; input string exceeds the maximum display capacity
        (maxlen 13) ; maximum menu length at each display
        (win-end (- (length string) 1))
        (r-size (length string))
        (c-size (biggest$hu (map print-length string)))
        (xcmd (make-window name #!true))
        (wexp (make-window "synonym window" #!true))
        (dir 0)
        )
                 
    (if (>? (string-length name)  c-size)
        (set! c-size (string-length name)))
;    (window-clear 'console)
;    (shrink-console)
    (eval `(define bord$hu ,bord-color))
    (eval `(define text$hu ,text-color))
    (eval `(define fcs$hu ,focus-color))

    (if (>? r-size maxlen)
        (begin
          (set! exceed 1) ;; set the flag
          (set! r-size maxlen) ;; row size equal maximum length
          (set! win-end (- maxlen 1)) ;; row-number of the last row
          (set! part-lst (reverse (list-tail (reverse string)
                 (- (length string) maxlen)))) ;;portion for display first
          )
        (set! part-lst string)
        )
    (create-window wexp 1 1 1 78 bord$hu text$hu)
    (create-window xcmd (car pos) (cadr pos) r-size c-size bord$hu text$hu)
    (flush-window$hu part-lst xcmd) ;;display manual contents
    (field-attribute$hu 0 (car part-lst) 0
                        (car part-lst) xcmd) ;;focus first item 
    (display (list-ref expl 0) wexp)
    (let rep (
              (old-row 0)
              (cur-row 0)
              )
      (set! dir (char->integer (read-char))) ;; read user's input

      (cond ((equal? dir 56) ;SHIFT-UP key
             (if (equal? cur-row 0)
                 (begin
                   ;;;rearrange original string & current display string
                   (if (>? exceed 0)
                       (begin
                         (set! string (rotate-right$hu string 1))
                         (set! part-lst (cons (car string)
                            (reverse (list-tail (reverse part-lst) 1))))
                         (replace-text$hu xcmd part-lst c-size)
                         (field-attribute$hu 0 (car part-lst)
                                             1 (cadr part-lst) xcmd)
                         (rep cur-row cur-row))
                       (begin
                         (set! cur-row (- (length part-lst) 1))
                         (field-attribute$hu cur-row (car (reverse part-lst))
                                             0 (car part-lst) xcmd)
                   (newline wexp)
                   (display (list-ref expl cur-row) wexp)
                         (rep cur-row cur-row))
                       ))
                 (begin
                   (set! cur-row (- cur-row 1))
                   (field-attribute$hu  cur-row (list-ref part-lst cur-row)
                                        old-row (list-ref part-lst old-row)
                                        xcmd)
(newline wexp) (display (list-ref expl cur-row) wexp)
                   (rep  cur-row cur-row))
                 ))
            ((equal? dir 50) ;SHIFT-DOWN key
             (if (equal? cur-row win-end)
                 (begin
                   ;;;rearrange original string & current display string
                   (if (>? exceed 0)
                       (begin
                         (set! string (rotate-left$hu string 1))
                         (set! part-lst (append (cdr part-lst)
                           (list (list-ref string (- (length part-lst) 1)))))
                         (newline xcmd)
                         (display (car (reverse part-lst)) xcmd)
                   (newline wexp)(display (list-ref expl cur-row) wexp)
                         (field-attribute$hu cur-row (car (reverse part-lst))
                            (- cur-row 1) (cadr (reverse part-lst)) xcmd)
                         (rep cur-row cur-row))
                       (begin
                         (set! cur-row 0)
(newline wexp)(display (list-ref expl cur-row) wexp)
                         (field-attribute$hu cur-row (car part-lst)
                           (- (length part-lst) 1) (car (reverse part-lst))
                                             xcmd)
                         (rep cur-row cur-row))
                       ))
                 (begin
                   (set! cur-row (+ cur-row 1))  (newline wexp)
                   (display (list-ref expl cur-row) wexp)
                   (field-attribute$hu cur-row (list-ref part-lst cur-row)
                                    old-row (list-ref part-lst old-row)
                                    xcmd) ;;set new focus item
                   (rep cur-row cur-row))
                 ))
            ((equal? dir 13) 
                  (window-delete xcmd)
                  (window-delete wexp)
                   (list-ref expl cur-row))
            (else (bel$hu 2) (rep cur-row cur-row)) ;; unchange
            ))))





(define-method (atomic-models make-synonyms)()
(let (
     (syn (gen-name name-ctr 'syn))
     )
(eval `(define ,syn ,name) user-initial-environment)
(list (cons name syn))
))

(define-method (coupled-models make-synonyms)()
(let (
     (syn (gen-name name-ctr 'syn))
     )
(eval `(define ,syn ,name) user-initial-environment)
(cons
(cons name syn)
  (union (map (lambda(ch)(send ch make-synonyms))(get-children)))
)))

(define-method (root-co-ordinators make-dir)()
(let* (                 
     (root-model (send child get-devs-component))
     (pairs (send root-model make-synonyms))
     (names (map car pairs))
     (syns (map cdr pairs))
     )
(set-names$ name-dir$ names)
(set-synonyms$ name-dir$ syns)
))
