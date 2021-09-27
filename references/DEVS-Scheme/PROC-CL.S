;;;;;;;;;;;;;;;;;;;;;;;;;processor.s  with timing;;;;;;;;;;;;;;;;;;;;;

(define-class processors
  (classvars)
  (instvars
               mark-time 
               *-mark-time
               event-type
               (x-time 0)
               (y-time 0)
               (*-time 0)
               inport
               outport
               time-of-last-event
               time-of-next-event
               devs-component            ;being simulated
               parent                    ;coupled model containing devs-comp
               children                  ;of devs-component---not used


)
   (mixins entities)
   (options
         gettable-variables
         settable-variables
         inittable-variables)
)

             























