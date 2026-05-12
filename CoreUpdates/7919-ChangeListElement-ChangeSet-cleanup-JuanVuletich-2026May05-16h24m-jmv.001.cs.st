'From Cuis7.7 [latest update: #7910] on 5 May 2026 at 5:07:22 pm'!

!ChangeList methodsFor: 'scanning' stamp: 'jmv 5/May/2026 16:49:28'!
scanClassRemoval: tokens

	| movedToOtherPackage removeType classDefinition className description record stamp |

	removeType := tokens first.
	className := tokens second.
	movedToOtherPackage := removeType == #classMoveToSomePackage:.
	stamp := CompiledMethod stampFrom: tokens.
	classDefinition := file nextChunk.

	record := ClassDeletionChange
			className: className
			definition: classDefinition
			doItOnlyIfInBaseSystem: movedToOtherPackage
			stamp: stamp.

	description := movedToOtherPackage
			ifTrue: ['clase move to some package: ']
			ifFalse: ['class removal: '].

	self
		addItem: record
		text: description, className, '; ', stamp.! !

!ChangeList methodsFor: 'scanning' stamp: 'jmv 5/May/2026 16:50:35'!
scanMethodRemoval: tokens

	| doItOnlyIfInBaseSystem removeType isMeta sourceCode methodReference className description record selector stamp |

	removeType := tokens first.
	className := tokens second.
	doItOnlyIfInBaseSystem := removeType == #methodMoveToSomePackage:.

	sourceCode := file nextChunk.
	isMeta := tokens third == #class.	
	selector := isMeta ifTrue: [ tokens fourth ] ifFalse: [ tokens third ].
	stamp := CompiledMethod stampFrom: tokens.

	methodReference := MethodReference new
		setClassSymbol: className
		classIsMeta: isMeta
		methodSymbol: selector
		stringVersion: className, (isMeta ifTrue: [' class '] ifFalse: [' ']), selector,'; ', stamp.

	record := MethodDeletionChange
		methodReference: methodReference
		doItOnlyIfInBaseSystem: doItOnlyIfInBaseSystem
		source: sourceCode
		stamp: stamp.

	description := doItOnlyIfInBaseSystem
		ifTrue: ['method move to some package: ']
		ifFalse: ['method removal: '].

	self
		addItem: record
		text: description, methodReference stringVersion.! !


!ClassDeletionChange class methodsFor: 'instance creation' stamp: 'jmv 5/May/2026 16:34:25'!
className: aClassName definition: aClassDefinition doItOnlyIfInBaseSystem: doItOnlyIfInBaseSystem stamp: aStamp

	^self new
		initializeClassName: aClassName
		definition: aClassDefinition
		doItOnlyIfInBaseSystem: doItOnlyIfInBaseSystem
		stamp: aStamp! !


!MethodDeletionChange class methodsFor: 'instance creation' stamp: 'jmv 5/May/2026 16:34:16'!
methodReference: aMethodReference doItOnlyIfInBaseSystem: doItOnlyIfInBaseSystem source: aSourceCode stamp: aStamp

	^self new
		initializeMethodReference: aMethodReference
		doItOnlyIfInBaseSystem: doItOnlyIfInBaseSystem
		source: aSourceCode
		stamp: aStamp! !


!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 16:44:29'!
fileOutClassDeletionFrom: aClassChangeRecord doItOnlyIfInBaseSystem: doItOnlyIfInBaseSystem on: stream

	| record |
	
	record := ClassDeletionChange
		className: aClassChangeRecord thisName
		definition: aClassChangeRecord priorDefinition
		doItOnlyIfInBaseSystem: doItOnlyIfInBaseSystem
		stamp: aClassChangeRecord stamp.

	record fileOutOn: stream.! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 16:47:46'!
fileOutMethodRemovalOf: selector for: class movedToOtherPackage: movedToOtherPackage on: stream stamp: stamp 

	| methodReference changeRecord |

	methodReference := MethodReference class: class selector: selector.

	changeRecord := MethodDeletionChange
		methodReference: methodReference
		doItOnlyIfInBaseSystem: movedToOtherPackage
		source: (methodReference sourceCodeIfAbsent: [ 'Missing' ])
		stamp: stamp.

	changeRecord fileOutOn: stream.! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 16:47:17'!
fileOutMethodRemovalsOf: changeTypes movedToOtherPackage: movedToOtherPackage for: class on: stream
	"Write out removals and initialization for this class."

	| classRecord methodChanges changeType |

	classRecord := changeRecords at: class name ifAbsent: [^ self].
	methodChanges := classRecord methodChanges.

	methodChanges keysAndValuesDo: [:selector :aMethodChange |
		changeType := aMethodChange changeType.
		(changeTypes includes: changeType) ifTrue: [
			self
				fileOutMethodRemovalOf: selector
				for: class
				movedToOtherPackage: movedToOtherPackage
				on: stream
				stamp: aMethodChange stamp ]].! !

