

(define-method (coupled-models tell-your-robot-name)()
(for-each (lambda(ch)(send ch tell-robot-name name)) (get-children))
)

(define-method (coupled-models tell-robot-name)(robot-name)
(for-each (lambda(ch) (send ch tell-robot-name robot-name)) (get-children))
)

(define-method (atomic-models tell-robot-name)(robot-nm)
(when
      (or (member 'robot-name (get-ind-vars))
           (member '(robot-name) (get-ind-vars))
       )
 (eval `(set! (state-robot-name ,s) ',robot-nm))
))


(define-method (coupled-models tell-your-mpu-name)()
(for-each (lambda(ch)(send ch tell-mpu-name name)) (get-children))
)

(define-method (coupled-models tell-mpu-name)(mpu-name)
(for-each (lambda(ch) (send ch tell-mpu-name mpu-name)) (get-children))
)

(define-method (atomic-models tell-mpu-name)(mpu-nm)
(when
      (or (member 'mpu-name (get-ind-vars))
           (member '(mpu-name) (get-ind-vars))
       )
 (eval `(set! (state-mpu-name ,s) ',mpu-nm))
))



(define-method (coupled-models tell-your-object-name)()
(for-each (lambda(ch)(send ch tell-object-name name)) (get-children))
)

(define-method (coupled-models tell-object-name)(object-name)
(for-each (lambda(ch) (send ch tell-object-name object-name)) (get-children))
)

(define-method (atomic-models tell-object-name)(object-nm)
(when
      (or (member 'object-name (get-ind-vars))
           (member '(object-name) (get-ind-vars))
       )
 (eval `(set! (state-object-name ,s) ',object-nm))
))



(define-method (atomic-models inject)(port  value source channel . elapsed-time)
(set-x (make-content 'port port 'value value 'source source 'channel channel))
(when (number? (car elapsed-time)) (set-e (car elapsed-time)))
(ext-transition)
)


(define-method (coupled-models inject) (port value source channel . elapsed-time)
(let (
      (e (when (number? (car elapsed-time)) (car elapsed-time)))
      (destinations (get-receivers))
     )
     (for-each (lambda(child)
             (send child inject (translate this-model child port)
                                 value source channel e)
                       ) destinations)
)
)


(define (flash-message model mes)
 (define (root-of-model model)
 (if (equal? 'dum (send model get-name))
     (send (send (send model get-processor) get-child) get-devs-component)
 (root-of-model (send model get-parent))
 ))
(let* (
     (wind (send model get-wind))
     (pair (cons model wind))
     )
(IF pause 
  (begin
   (window-reduce-stack pair)
   (when (equal? (top? wst) pair) (window-pop))
   (window-push pair)
   (if (not (message? mes) )
       (display-window wind mes)
     (begin
      (display-window wind
         (cond
         ( (ext-message? mes) "Ext-message ")
         ( (*-message? mes) "*-message ")
         ( (done-message? mes) "Done-message ")) #nl
          "received from: " (if
                             (environment? (message-source mes))
                                (send (message-source mes) get-name)
                             (message-source mes)) #nl
          "with time: " (message-time mes) #nl) ;-- display-window
      (when (content? (message-content mes))
        (display-window wind
          "with port: " (content-port (message-content mes)) #nl
          "saying: "   (list
(content-value (message-content mes))
(content-source (message-content mes))
(content-channel (message-content mes))
                       )
 ))

   ));---- IF

   (flush-input 'console)
   (writeln "type any key to continue")
   (key-menu&zhang  (root-of-model model))
;  (when (equal? (read-char) " ")(bkpt "STOPPED" ""))
            
   ) ;-- BEGIN
   (key-menu&zhang (root-of-model model))
) ;----- IF
))

(define ($reconstruct input-message coupled-model destination)
        (let*
             (

             (cont (message-content input-message))
             (outport (content-port cont))
             (value   (content-value cont))
             (src   (content-source cont))
             (channel   (content-channel cont))
             (ech   (content-echo-status cont))
             (source (message-source input-message))
             (time   (message-time input-message))
             (inport (send-if-handles coupled-model
                      translate source destination outport))
             (message (make-ext-message))
            ) 
            (set! cont (make-content 'port inport 'value value
                         'source src 'channel channel 'echo-status ech))
            (set! (message-content message) cont)
            (set! (message-source message) coupled-model)
            (set! (message-time message) time)
            message
      )
)


(define-method (atomic-models output?) ()
               (let* (                      
                     (out (outputfn s))
                     (out-lst (if (not (pair? out))
                                  (list out)
                                  out))
                    )                                              
                    (for-each (lambda(cont)
                          (window-set-cursor! wind (+ (car cp) 3) (cdr cp))
                          (display "output y = " wind)
                          ($erase (content-port y) wind)
                          (display " " wind)
                          ($erase (list ($clip (content-value y) 1)
                                          (content-source y)
                                          (content-channel y)) wind)
                           (set! y cont)
                           (window-set-cursor! wind (+ (car cp) 3) (cdr cp))
                           (display "output y = " wind)
                           (display (content-port y) wind)
                           (display " " wind)
                           (display (list ($clip (content-value y) 1)
                                          (content-source y)
                                          (content-channel y))
                             wind)

                               ) out-lst)                                    
                    out
))


(define-method (table-models input?)(goal)
(let* (
     (gtab (eval `(state-gtab s)))
     (tuple (car (*get-related gtab (list (list 'goal goal)
                                     (list 'state (state-phase s))))))
     (input (project-on-attr gtab tuple 'input))
     )
(inject input '() '() '() 0)
input
))


