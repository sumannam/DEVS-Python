;; runprun.s


;;;;;;; modified 9/22/88
(define initialize-window (make-window "INITIALIZATION" #!true))
(wss initialize-window 5 40)
(wsp initialize-window 20 1)

;;;;;;;; modified 10/15/88 ;;;;;;;;;         
(define spec-window (make-window "SPECIALIZATION" #!true))
(wss spec-window 15 35)  ;;
(wsp spec-window 5 35) ;;


;;;;;;;;;; mult.s  enpeprune.s;;;;;;;;;;;

;(define (cut-mult p:en ent-cut)
;     (set-current-item p:en ent-cut)
;     (extract-sub-entstr p:en);

;     (delete-sub-entstr p:en ent-cut)
;     (add-item p:en ent ent-cut)
;     (save-entstr (eval (symbol-append 'e: ent-cut)))
;     (writeln "ent " ent-cut " was made a leaf")
;)

;;;;;;;;;;modified 9/29/88 ;;;;;;;;;;;;

;;; write into scratch file called "scratch*" ;;;

(define scratch-lst '())

(define (write-in-scratch-file)
   (let* (
           (opt (current-output-port))
           (fn (symbol->string (gen-name name-ctr 'scratch)))
           (fo (open-output-file fn))
         )
      (set-fluid! output-port fo)
      (set! scratch-lst (append (list (list fn fo  opt)) scratch-lst))
   )
)

;;; back from scratch file to previous input/output port ;;;

(define (back-to-previous-output)
   (close-output-port (current-output-port))
   (dos-delete (car (car scratch-lst)))
   (set-fluid! output-port (caddr (car scratch-lst)))
   (set! scratch-lst (cdr scratch-lst))
)

;;; message visible / invisible on output port (console, window) ;;;

(define (message-mode-off) (write-in-scratch-file))
(define (message-mode-on)  (back-to-previous-output))


;;;;;;; modified 18/may/89 ;;;;;;;;


(define (special-prune en)
   (let* (
           (items (map (lambda(it) (copy-item it)) (items? en)))
           (branches (map (lambda(br)
                       (make-branch 'left (car (member (branch-left br) items))
                                    'right (car (member (branch-right br)items))
                     )) (branches? en)))
           (tmp-en-name 'p@tmp)
           (prun-en-nm ())
        )
      (eval
         `(begin
            (define ,tmp-en-name (entity-structure))
            (set-items ,tmp-en-name ',items)
            (set-branches ,tmp-en-name ',branches)
            (add-spec-and-prune ,tmp-en-name)
            (clean-entstr ,tmp-en-name)
          )
      )
      (eval tmp-en-name)
)
)

;;;;;;; 9/29/88 ;;;;;;;
(macro load&prune&transform (lambda(e)
  (let (
        (en (cadr e))
        (ipt (current-input-port))
        (opt (current-output-port))
       )
 (window-popup spec-window)
 (set-fluid! input-port spec-window)
 (set-fluid! output-port spec-window)
`(let rep (
          (lst   (begin
                 (load-entstr ,en)
                 (special-prune ,en)
                 (list (transform1 p@tmp))
                )
          )
         )
     (newline spec-window)
     (display-window spec-window "Continue to select ? (y/n)" #\newline)
     (cond
      ((equal? (read) 'y) 
             (set-fluid! output-port spec-window)
             (special-prune ,en)
          (rep (cons (transform1 p@tmp) lst)))
      (else 
           (window-popup-delete spec-window)
           (set-fluid! input-port ipt)
           (set-fluid! output-port opt)
           lst
       )
     )
))))


(define (transform1 en)
(let* (
      (ent-name  (root-name  en))
      (nm-lst (find-all ent-name))
      (first (true-name (car (last-pair nm-lst))))
      (ma (retrieve atomic-models (root-name en) (root-name en)))
      (md (when (not ma)(retrieve digraph-models (root-name en)
                                                 (root-name en))))
      
     )
(cond
 (ma (send ma make-new (gen-name name-ctr (root-name en))))
 (md (send md make-new (gen-name name-ctr (root-name en))))
 (else
      (set-current-item en ent-name)
      (for-each (lambda(aspect)
             (replace-coupling en aspect first ent-name)) (aspects en)) 
      (let (
            (m (transform2 en))
           )
        (send m make-new (gen-name name-ctr (root-name en)))
      )
  )
)
))

;;;;;;;;;; 10/17/88 ; 6-13-89 ;;;;;;;;;;
(define (transform2 en ) 
(set-current-item en 'root-asp) 
(let* ( 
     (ent-name  (item-name (car (ents en))))
   ; (nm-lst (find-all ent-name))
   ; (first (true-name (car (last-pair nm-lst))))
     (m (transform-ent en ent-name '(root-asp) )) ;;;;;
     (proc (send m get-processor))
   ; (first-proc  (symbol-append '|C:| first))
     (ent-proc  (symbol-append '|C:| ent-name))
     )

;  (eval `(define ,first ,m) user-initial-environment)
;  (eval `(define ,first-proc ,proc) user-initial-environment)
  (eval `(define ,ent-name ,m) user-initial-environment)
  (eval `(define ,ent-proc ,proc) user-initial-environment)
 m 
))





;;;;;; modified 9/29/88
(define (prune&transform en)
(let (
      (ipt (current-input-port))
      (opt (current-output-port))
     )
(window-popup spec-window)
(set-fluid! input-port spec-window)
(set-fluid! output-port spec-window)
(let rep (
          (lst
                 (list (transform1 (special-prune en)))

          )
         )
     (newline spec-window)
     (display-window spec-window "Continue to select ? (y/n)" #\newline)
     (cond
      ((equal? (read) 'y)
          (set-fluid! output-port spec-window)
          (rep (cons (transform1 (special-prune en)) lst)))
      (else 
           (window-popup-delete spec-window)
           (set-fluid! input-port ipt)
           (set-fluid! output-port opt)
           lst)
     )
)))


(define-method (kernel-models make-pruned) ()
(let (
     (model-or-entstr (get-originator (eval class)))
     )
(when (closure? model-or-entstr)
   (set-pseudo-class-lst (eval class)
            (prune&transform model-or-entstr))
  )
))



;;;;; 6-26-89 print item on current-output-port ;;;;;;;;;
;;;;; needed when multiple-level runtime pruning ;;;;;;;;;

;; options: [ -a -c -o -s -p ] ;;
;; 
;; if -a is in options, attributes will not be printed
;; if -c is in options, coupling will not be printed
;; if -o is in options, out-in-coup will not be printed
;; if -s is in options, sel-constraint will not be printed
;; if -p is in options, priority-list will not be printed

(define (print-item en item-nm space options)
(set-current-item en item-nm)
(let (
     (item (cur? en))
     )
(display-window (current-output-port) space (item-type item) " : " item-nm )
(when (equal? (item-sub-type item) 'mult-asp)
    (display-window (current-output-port)  "  ,mult-coup-type -> " 
                                          (item-mult-coup-type item))
)
(when (and (equal? (item-type item) 'asp) (not (member '-p options))
           (item-priority-list item))
    (display-window (current-output-port)  " ,priority-list -> "  
                                           (item-priority-list item))
)
(if (and (item-coupling item) (not (member '-c options))
    (or (equal? (item-type item) asp) (equal? (item-sub-type item) 'mult-asp)))
  (if (vector? (car (item-coupling item))) 
      (display-window (current-output-port)  "  ,coupling -> " 
                                   (print-coup (item-coupling item)))
      (if (not (equal? (item-mult-coup-type item) 'tree))
         (display-window (current-output-port)  "  ,out-in-coup -> " 
                                                (item-coupling item))
         (let (
                (int-coup (clean (map (lambda(e)
                   (if (not (equal? 'ext-coup (car e))) e)) 
                   (item-coupling item))))
                (ext-coup (car (clean (map (lambda(e)
                   (if (equal? 'ext-coup (car e)) e))
                   (item-coupling item)))))
              )  
         (display-window (current-output-port)  "  ,out-in-coup -> "  int-coup)
         (display-window (current-output-port)  "  ,ext-inp-couple -> " 
                                                               (cadr ext-coup))
         (display-window (current-output-port)  "  ,ext-out-couple -> " 
                                                              (caddr ext-coup))
         )
      )
   )
)
(when (and (equal? (item-type item) 'spec) (not (member '-s options))
           (item-sel-constraint item))
    (display-window (current-output-port)  "   ,sel constraints -> " 
                                           (item-sel-constraint item))
)
(when (and (equal? (item-type item) 'ent) (not (member '-a options))
           (item-attr-lst item))
    (display-window (current-output-port)  "  ,attributes -> " 
       (clean (map (lambda(e) (if (not (equal? 'mulch-tree (car e))) e))
           (item-attr-lst item))))
)
(newline)
(for-each (lambda(br)(print-item en (item-name (branch-right br))
                         (string-append "-" space) options)) (out-branches en))
))

