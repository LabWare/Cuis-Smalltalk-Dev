'From Cuis7.7 [latest update: #7903] on 4 May 2026 at 11:48:24 am'!

!ChangeListElement methodsFor: 'accessing' stamp: 'jmv 4/May/2026 11:34:47'!
compilerClass
	^self changeClass
		ifNotNil: [ :cls | cls compilerClass ]
		ifNil: [ Compiler ]! !

!methodRemoval: MethodDefinitionChange #compilerClass stamp: 'jmv 4/May/2026 11:47:41'!
MethodDefinitionChange removeSelector: #compilerClass!
!methodRemoval: ClassDefinitionChange #compilerClass stamp: 'jmv 4/May/2026 11:47:41'!
ClassDefinitionChange removeSelector: #compilerClass!
!methodRemoval: ClassCommentChange #compilerClass stamp: 'jmv 4/May/2026 11:47:41'!
ClassCommentChange removeSelector: #compilerClass!
