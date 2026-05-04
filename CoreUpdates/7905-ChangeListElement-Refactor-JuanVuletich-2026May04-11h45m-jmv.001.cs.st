'From Cuis7.7 [latest update: #7903] on 4 May 2026 at 11:47:30 am'!

!ChangeListElement methodsFor: 'accessing' stamp: 'jmv 4/May/2026 11:28:58'!
changeClass
	^nil! !


!ClassRenamedChange methodsFor: 'accessing' stamp: 'jmv 4/May/2026 11:32:01'!
changeClass
	^Smalltalk at: previousName ifAbsent: nil! !


!ClassCommentChange methodsFor: 'accessing' stamp: 'jmv 4/May/2026 11:24:34'!
changeClass
	| className |
	className := class substrings
		ifEmpty: [ ^ nil ]
		ifNotEmpty: [ :parts |
			parts first ].
	^(Smalltalk hasClassNamed: className) ifTrue: [
		Smalltalk classNamed: className ]! !


!ClassDefinitionChange methodsFor: 'accessing' stamp: 'jmv 4/May/2026 11:25:19'!
changeClass
	| className cls |
	className := class substrings
		ifEmpty: [ ^ nil ]
		ifNotEmpty: [ :parts |
			parts first ].
	(Smalltalk hasClassNamed: className) ifFalse: [ ^ nil ].
	cls := Smalltalk classNamed: className.
	^ meta
		ifTrue: [ cls class ]
		ifFalse: [ cls ]! !


!MethodDefinitionChange methodsFor: 'accessing' stamp: 'jmv 4/May/2026 11:26:12'!
changeClass
	| className cls |
	className := class substrings
		ifEmpty: [ ^ nil ]
		ifNotEmpty: [ :parts |
			parts first ].
	(Smalltalk hasClassNamed: className) ifFalse: [ ^ nil ].
	cls := Smalltalk classNamed: className.
	^ meta
		ifTrue: [ cls class ]
		ifFalse: [ cls ]! !

!methodRemoval: UnspecificRecord #changeClass stamp: 'jmv 4/May/2026 11:46:24'!
UnspecificRecord removeSelector: #changeClass!
!methodRemoval: PreambleRecord #changeClass stamp: 'jmv 4/May/2026 11:46:25'!
PreambleRecord removeSelector: #changeClass!
!methodRemoval: FeatureRequiresRecord #changeClass stamp: 'jmv 4/May/2026 11:46:28'!
FeatureRequiresRecord removeSelector: #changeClass!
!methodRemoval: FeatureProvidesRecord #changeClass stamp: 'jmv 4/May/2026 11:46:30'!
FeatureProvidesRecord removeSelector: #changeClass!
