;;;;;;;;;;;;;;;;;;;;;;;;;;;enti-me2.s;;;;;;;;;;;;;;;;;;;;;;;;;;


(define (specialized-class obj classname)
   (let rep
      (
      (gen-classname (class-of-object obj))
      (classname classname)
      )
   (cond
     ( (equal? gen-classname classname) #!true)
     ( (null? (mixnames gen-classname))  #!false)
     ( else (rep (car (mixnames gen-classname)) classname))
   )
 )
)

(define (mixnames classname)
   (mixins (name->class classname))
)
   
(macro print-scoops-class
   (lambda(e) 
      (let (
             (root-class (cadr e))
             (options (cddr e))
           )
         `(begin
             (print-class-structure ,root-class "-" 
                (or (member 'c ',options)  (member 'cv ',options) 
                    (member 'classvars ',options))
                (or (member 'i ',options)  (member 'iv ',options) 
                    (member 'instvars ',options))
                (or (member 'm ',options)  (member 'meth ',options) 
                    (member ',methods ',options))
                (or (member 'in ',options) (member 'inst ',options) 
                    (member 'instants ',options)))
             (writeln "end of display")
          )
       )
   )
)

(define (print-class-structure root-class sp-bar cv iv meth inst)
   (display sp-bar)
   (display (%sc-name root-class))
   (print-options root-class cv iv meth inst)
   (newline)
   (if (not (null? (%sc-subclasses root-class)))
       (for-each (lambda(subcl) 
          (print-class-structure 
             (eval subcl) (string-append  "-" sp-bar) cv iv meth inst)) 
       (%sc-subclasses (eval root-class)))
   )
)
 
(define (print-options class cv iv meth inst) 
   (when cv 
      (newline)
      (display "          << class-vars >> ")
      (displayln  (classvars class) "               "))
   (when iv 
      (newline)
      (display "          << inst-vars >> ")
      (displayln (instvars class) "               "))
   (when meth 
      (newline)
      (display "          << methods >> ")
      (displayln (methods class) "               "))
   (when inst 
      (newline)
      (display "          << inst-of-class >> ")
      (if (class-compiled? class) 
          (displayln (show-class class) "               ")))
)
                   
(define (displayln lst leading-sp)
   (let rep (
              (eles lst)
            )
      (when (not (null? eles))
          (newline)
          (display leading-sp)
          (display (car eles))
          (rep (cdr eles))
      )
   )
)


;;to get parent of class:: (getcv class parent-class)
;;to get children classes:: (getcv class children-class-list)


(macro print-scoops-path  (lambda(e)   ;;macro needed to get class-name 
   (let (                        ;;w/o arg. assumes class entities 
        (from-class-nm (cadr e))
        (to-class-nm (caddr e))
        )
  (print-path from-class-nm (if (not (null? to-class-nm)) 
                                 to-class-nm 'entities) "-")
  (writeln "end of display")
)))


(define (print-path from-class-nm to-class-nm space)                
   (writeln space from-class-nm)
   (if (not (equal? from-class-nm to-class-nm))
       (let* (                             
              (class (eval from-class-nm))
              (parent (car (mixins class)))
             )       
          (if (equal? parent '())
              (writeln "!!! there is no path between two classes !!!")
              (if (equal? parent to-class-nm) ;;;;;;;;;;;;
                  (writeln (string-append "-" space) parent)
                 (print-path parent to-class-nm (string-append "-" space))
              )
          )
       )
   )
)


(define (parent-classes from-class to-class)
   (difference (all-parent-classes from-class)
               (cdr (all-parent-classes to-class)))
)


(define (all-parent-classes from-class)                
   (let* (                             
           (class (eval from-class))
           (parents (mixins class))
         )       
       (cons (%sc-name class) 
             (union (map (lambda(pr) (all-parent-classes pr)) parents)))
   )
)

(define (all-classes)        ;;;;;;;;;;;;;;;;;;;;;;;;;;
   (sub-classes 'entities)
)

(define (sub-classes class-nm)                ;;;;;;;;;;;;;;;;;
   (let* (                             
          (class (eval class-nm))
          (children (%sc-subclasses class))
         )
      (cons class-nm (union (map (lambda(ch)(sub-classes ch)) children)))
   )
)


(define (sub-class-of spec-nm  gen-nm)
(let* (                             
        (class (eval gen-nm))
        (children (%sc-subclasses class))
      )
   (cond
      ((equal? spec-nm gen-nm)  #!true)
      ((member spec-nm children) #!true)
      ( else (eval
             `(or ,@(map (lambda(ch)(sub-class-of spec-nm ch)) children))) )
)))

(define (class? nm)
(sub-class-of nm 'entities)
)

(define (all-objects)
   (union 
      (map (lambda(cl) (if (class-compiled? (eval cl))
                           (send (%sc-class-env (eval cl)) get-lst)))
         (all-classes)))
) 

 
(define (show-all-objects)
   (map (lambda(ob)(send (eval ob) get-name)) (all-objects))
)

(macro mk-ent-no-display (lambda(e)
     (let (
          (class (cadr e))
          (name (caddr e))
          )
`(begin
(define ,name (make-entity ,class ',name))
))))



(macro object? (lambda(e)
(let* (
     (obj  (cadr e))   
     (ob (if (pair? obj)(cadr obj) obj))
     (assigned  (when (symbol? ob)
                  (eval `(access ,ob user-initial-environment))))
     ) 
`(begin 
(and 
   (not (equal? ,assigned #!unassigned))
   (not (not
 (member ,assigned (all-objects))  ))
 )
)
)))      

(macro object-name-of? (lambda(e)
   (let* (
        (x  (cadr e))
        ( ob-nm (if (pair? x)(cadr x) x))       
        ( cl-nm   (caddr e))
        )
`(not (not (member ',ob-nm (show-class (eval ,cl-nm)) )))
)))

(macro object-name? (lambda(e)
      (let* (
            (x (cadr e))
            (ob-nm (if (pair? x)(cadr x) x))  
            )
 `(or ,@(map (lambda(cl)
           (if (class-compiled? (eval cl))
               (eval `(object-name-of? ,ob-nm (eval ,cl)))))
  (all-classes)
  ))
)))



(macro ex-define-class (lambda (e) ;;replaces define-class
 (let* (                           ;;also does compile-class
       (class (list-ref e 1))      ;;needed to use range-list, parent,child slots
       (classvar-spec  (list-ref e 2))   
       (classvars  (cons 'range-list (cdr classvar-spec)))
       (instvar-spec (list-ref e 3))
       (instvars-  (cdr instvar-spec))
       (instvars (map (lambda(tr)(if (symbol? tr) tr (list (car tr)(cadr tr))))
instvars-))
       (ranges (map (lambda(tr)(if (symbol? tr) (list tr) (list (car tr)(caddr tr))) )
instvars-))
       (option-spec (list-ref e 4))
       (options  (cdr option-spec))
       (mixin-spec (list-ref e 5))
       (mixins  (cdr  mixin-spec))
       (parent-class (car mixins))
      )
`(begin
   (define-class ,class
      (classvars ,@classvars)
      (instvars ,@instvars)
      (options ,@options)
      (mixins ,@mixins)
   )
(eval '(ex-compile-class ,class))    
  (send (%sc-class-env (eval ,class)) set-range-list      
      (special-remove-mult (append
      (send (%sc-class-env (eval ,parent-class)) get-range-list)
      ',ranges
      ))
 )
 )
)))

(define (special-remove-mult lst)  ;subsequent instances of elements are removed
(let (
     (nlst '())
     )
(for-each (lambda(e)(when (not (special-member e nlst))
            (set! nlst (append nlst (list e))))) lst)
nlst
))

(define (special-member el lst)
(clean (map (lambda(elm)(when (equal? (car elm)(car el)) #!true)) lst))
)

(macro ex-compile-class (lambda(e)  ;;replaces  compile-class
 (let* (                            ;;makes parent, child connections 
     (class (cadr e))
     (parent-class (car (mixnames class)))
      )
`(begin
  (eval '(compile-class ,class))                                     
  (send (%sc-class-env (eval ,class)) set-parent-class ',parent-class)
 (send (%sc-class-env (eval ,parent-class)) set-children-class-list      
      (union2 (list ',class)
      (send (%sc-class-env (eval ,parent-class)) get-children-class-list)
     )
  )
)                                                                 
)))

(macro quoted-name? (lambda(e)
(let* (
     (x (cadr e))       
     (assigned  (when (symbol? x)
                  (eval `(access ,x user-initial-environment))))

      )
`(cond             
( (and (member ,assigned (list #!unassigned '()))
   (object-name? ,x))
     (writeln ,x " already exists, go ahead anyway (y/n) ?")
                  (if (equal? (read) 'y) #!true))
( else (and (pair? ',x)(equal? (car ',x) 'quote)))
))))
    

(macro set-object (lambda(e)
(let* (
     (ob (cadr e))
     (class (eval (class-of-object (eval ob))))
     (instvars (remove 'name (all-instvars class)))
     (range-list (send (%sc-class-env class) get-range-list))
     )
`(for-each (lambda(v)(let loop (
                          (range (cadr (assoc v ',range-list)))
                          (inp '())
                          )
                     (writeln "current value of " v " is:"
                            (eval (list 'get-var ,ob v)))
                     (writeln "Enter new value, the choices are: "
                      (if (null? range) "no range specified" range))
                     (set! inp (read))
                     (cond
                     ((null? range) (eval (list 'set-var ,ob v inp)))
                     ( (eval `(member ,inp ',range))
                                   (eval (list 'set-var ,ob v inp)))
                     (else (writeln "illegal: reenter ")(loop range inp))
                     )
                    ))
            ',instvars)
)))

(macro set-var (lambda(e)
(let (
     (ob (list-ref e 1))
     (var (list-ref e 2))
     (val (list-ref e 3))
     )
`(set! (access ,var  ,ob) ,val)
)))


(macro get-var (lambda(e)
(let (
     (ob (list-ref e 1))
     (var (list-ref e 2))
     )
`(eval ',var  ,ob) 
)))



(define (save-object ob-nm)
(let* (     
     (file-nm (string-append (symbol->string ob-nm) ".sav"))
     (p (open-output-file file-nm)) 
     (ob (eval ob-nm))
     (class-nm  (class-of-object (eval ob)))
     (class (eval class-nm))
     (instvars (all-instvars class))
     (inst-assoc (map (lambda(v)(list v (eval v ob))) instvars))
     )            
(write class-nm p)
(write inst-assoc p)
(close-output-port p)
))

;(ex-define-class as
;(classvars)
;(instvars
;    a
;    (b 5)   ;; if these is a range spec. then there must be a value
;    (c 'large (large medium small))
;)
;(options
; gettable-variables
; settable-variables
;)
;(mixins entities)
;)   
    

;(ex-define-class bs
;(classvars)
;(instvars 
;    (c 'small)
;    d
;    (e 5)   ;; if these is a range spec. then there must be a value
;    (f 'large (large medium small))
;)
;(options
; gettable-variables
; settable-variables
;)
;(mixins as)
;)   


(define (restore-object file-nm)
(let* (
     (p (open-input-file file-nm))
     (ob-nm (string->symbol (substring file-nm 0 (- (string-length file-nm) 4) )))
     (class-nm (read p))
     (inst-assoc (read p))
     (obj (make-entity (eval class-nm) ob-nm))
     )               
(close-input-port p) 
(for-each (lambda(el)(let (
                         (v (car el))
                         (val (cadr el))
                          )
                     (eval `(set-var ,obj ,v ',val))
          )) inst-assoc)
(eval `(define ,ob-nm ,obj) user-initial-environment)
)) 

(define (restore-all-objects)
(let (
     (files (dos-dir "*.sav"))
      )
(for-each (lambda(fl)(restore-object fl)) files)
))







