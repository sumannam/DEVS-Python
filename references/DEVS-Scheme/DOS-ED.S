(define (ed filename)
   (let (
          (fn (symbol->string filename))
          (edt "c:\\pcw\\ed")
        )
      (dos-call "" (string-append edt " " fn))
   )
)
