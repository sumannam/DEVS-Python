
(define mk-fsl
  (lambda (src . x)
    (let* (
           (src-nx (symbol->string src))
           (base-src (substring src-nx 0 (- (string-length src-nx) 2)))
           (obj "tmp.o") 
           (fasl (if (car x) (symbol->string (car x)) 
                      (string-append base-src ".f"))))
        (let loop (
                    (engine (make-engine
                               (lambda ()
                                  (engine-return (compile-file src-nx obj))))))
           (engine 100
                   (lambda x nil)
                   (lambda (new-engine)
                      (display ".")
                      (loop new-engine))))
           (dos-call (string-append pcs-sysdir "\\make_fsl.exe")
                     (string-append obj " " fasl)
                     4095
                     1)
           (dos-delete obj))))


