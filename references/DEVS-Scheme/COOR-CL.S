;;;;;;;;;;;;;;;;;;;;;;;;;;;co-ord.s;;;;;;;;;;;;;;;;;;
(define-class co-ordinators
	(classvars)
	(instvars
    IMMINENT            ;interms of child models
		*-child             ;imminent component model
		DESTINATIONS        ;external receivers of model influencees of *-child
		(wait-list '())
		tN-children
	)

  (mixins processors)
  (options
		gettable-variables
		settable-variables
		inittable-variables
	)
)

(compile-class co-ordinators)