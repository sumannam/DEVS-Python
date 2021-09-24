;;;;;;;;;;;;;;;;;;;;;;;window.s;;;;;;;;;;;;;;;;;;;;

(alias wsp window-set-position!)   ;(wsp wind l c)
(alias wgp window-get-position!)   ;(wsp wind) (l c)
(alias wss window-set-size!)       ;(wss wind h w)
(alias wgs window-get-size!)       ;(wgs wind) (h w)
(alias wsc window-set-cursor!)     ;(wsc wind l c)
(alias wgc window-get-cursor!)     ;(wgc wind)  (l c)
(alias wc window-clear)            ;(wc wind)
(alias wp window-popup)            ;(wp wind)
(alias wpd window-popup-delete)    ;(wpd wind)
(alias mw make-window)             ;(mw label #!true)

(define (back cnsl)
(begin
 (wsp cnsl 0 0)
 (wss cnsl 24 80)
 (wc cnsl)
))



(define (set-up cnsl)
(begin
 (wc cnsl)
 (wsp cnsl 21 0)
 (wss cnsl 3 80)
))

(define window-line 1)

(define (set-up-window)
  (letrec  (
         (label "")
         (linpos window-line)
         (colpos 1)
        (linhite 5)
         (colwidth 50)
         (lincur  0)
         (colcur  0)
          )
(display "enter window banner in quotation marks ")
(set! label (read))
(newline)
(display " wish to use default window parameters (y/n)? ")
 (let ((inp 'y))
   (set! inp (read))
   (if (equal? inp 'n)
(begin
(display "enter line where window starts ")
(set! linpos (read))
(newline)
(display "enter column where window starts ")
(set! colpos (read))
(newline)
(display "enter height of window -number of lines- ")
(set! linhite (read))
(newline)
(display "enter width of window -number of columns- ")
(set! colwidth (read))
(newline)
(display " wish to set cursor position (y/n)? ")
 (let ((inp 'n))
   (set! inp (read))
   (if (equal? inp 'y)
     (begin
      (display "enter relative line position of cursor  ")
      (set! lincur (read))
      (newline)
      (display "enter relative column position of cursor ")
      (set! colcur (read))
      (newline)
     )
    )
  )
)))
(begin
    (display "window created ")
    (newline)
     (let (
           (wind (make-window label #!true))
          )
      (wsp wind linpos colpos)
      (wss wind linhite colwidth)
      (wc wind)
      (wsc wind lincur colcur)
      (set! window-line (+ window-line linhite 1))
      wind
     )
)))

;-------------example of application
;(back 'console)
;(set-up 'console)
;(define w1 (set-up-window))
;(define w2 (set-up-window))


(build-module stack-mgr
  (
  (stack '())
  )
  (
(push (w) (lambda(w)(set! stack (cons w stack))))
(top? ()   (lambda()(car stack)))
(pop ()  (lambda()(set! stack (cdr stack))))
(stack-empty? () (lambda()(null? stack)))
(get-stack () (lambda()stack))
(set-stack (lst) (lambda(lst)(set! stack lst)))
 )
)

(define wst (stack-mgr))

(define (top-of pair)
(let rep (
         (lst  (get-stack wst))
         (front '())
         )
(cond
( (null? lst) lst)
( (equal? (caar lst) (car pair)) front)
( else (rep (cdr lst) (append front (list (car lst)))))
)))

(define (window-push  pair)
(wp (cdr pair))
(push wst pair)
)

(define (window-pop)
(let (
     (pair (top? wst))
     )
(wpd (cdr pair))
(pop wst)
))

(define (window-reduce-stack pair)
(let (
     (lst (top-of pair))
     )
(for-each (lambda(pair)(window-pop)) lst)
))

(alias wpush window-push)
(alias wpop window-pop)
(alias wrs window-reduce-stack)


(macro display-window (lambda (e)
   (let (
        (wind (cadr e))
        (to-be-displayed (cddr e))
        )
      (when (eq? (current-output-port) 'console)
         (if (null? to-be-displayed) `(display "" ,wind)
            `(begin
                (display ,(caddr e) ,wind); (car ,to-be-displayed))
                (display-window ,@(cons wind (cdddr e)))); 
)))))
