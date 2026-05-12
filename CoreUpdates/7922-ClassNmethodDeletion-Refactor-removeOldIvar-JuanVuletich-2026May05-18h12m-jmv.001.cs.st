'From Cuis7.7 [latest update: #7910] on 5 May 2026 at 6:14:44 pm'!
!classDefinition: #ClassDeletionChange category: #'Tools-Changes'!
ChangeListElement subclass: #ClassDeletionChange
	instanceVariableNames: 'className doItOnlyIfInBaseSystem classDefinition stamp appliesTo '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Changes'!
!classDefinition: #MethodDeletionChange category: #'Tools-Changes'!
ChangeListElement subclass: #MethodDeletionChange
	instanceVariableNames: 'methodReference doItOnlyIfInBaseSystem sourceCode stamp appliesTo '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Changes'!

!ClassDeletionChange methodsFor: 'initialization' stamp: 'jmv 5/May/2026 18:12:49'!
initialize
	appliesTo := nil.! !

!ClassDeletionChange methodsFor: 'initialization' stamp: 'jmv 5/May/2026 18:12:54'!
initializeClassName: aClassName definition: aClassDefinition appliesOnlyTo: packageOrBaseImageNameOrNil stamp: aStamp 

	className := aClassName.
	classDefinition := aClassDefinition.
	appliesTo := packageOrBaseImageNameOrNil.
	stamp := aStamp.! !


!MethodDeletionChange methodsFor: 'initialization' stamp: 'jmv 5/May/2026 18:13:06'!
initialize
	appliesTo := nil.! !

!MethodDeletionChange methodsFor: 'initialization' stamp: 'jmv 5/May/2026 18:13:11'!
initializeMethodReference: aMethodReference appliesOnlyTo: packageOrBaseImageNameOrNil source: aSourceCode stamp: aStamp  

	methodReference := aMethodReference.
	appliesTo := packageOrBaseImageNameOrNil.
	sourceCode := aSourceCode.
	stamp := aStamp.! !

!classDefinition: #ClassDeletionChange category: #'Tools-Changes'!
ChangeListElement subclass: #ClassDeletionChange
	instanceVariableNames: 'className classDefinition stamp appliesTo'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Changes'!
!classDefinition: #MethodDeletionChange category: #'Tools-Changes'!
ChangeListElement subclass: #MethodDeletionChange
	instanceVariableNames: 'methodReference sourceCode stamp appliesTo'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Changes'!
