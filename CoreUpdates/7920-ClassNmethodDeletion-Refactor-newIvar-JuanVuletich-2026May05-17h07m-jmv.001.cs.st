'From Cuis7.7 [latest update: #7910] on 5 May 2026 at 6:11:31 pm'!
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

!ClassDeletionChange methodsFor: 'initialization' stamp: 'jmv 5/May/2026 17:47:48'!
initialize
	doItOnlyIfInBaseSystem := false.
	appliesTo := nil.! !

!ClassDeletionChange methodsFor: 'initialization' stamp: 'jmv 5/May/2026 17:39:39'!
initializeClassName: aClassName definition: aClassDefinition appliesOnlyTo: packageOrBaseImageNameOrNil stamp: aStamp 

	className := aClassName.
	classDefinition := aClassDefinition.
	doItOnlyIfInBaseSystem := packageOrBaseImageNameOrNil == #BaseImage.
	appliesTo := packageOrBaseImageNameOrNil.
	stamp := aStamp.! !


!ClassDeletionChange class methodsFor: 'instance creation' stamp: 'jmv 5/May/2026 17:50:28'!
className: aClassName definition: aClassDefinition appliesOnlyTo: packageOrBaseImageNameOrNil stamp: aStamp

	^self new
		initializeClassName: aClassName
		definition: aClassDefinition
		appliesOnlyTo: packageOrBaseImageNameOrNil
		stamp: aStamp! !


!MethodDeletionChange methodsFor: 'initialization' stamp: 'jmv 5/May/2026 17:47:50'!
initialize
	doItOnlyIfInBaseSystem := false.
	appliesTo := nil.! !

!MethodDeletionChange methodsFor: 'initialization' stamp: 'jmv 5/May/2026 17:39:37'!
initializeMethodReference: aMethodReference appliesOnlyTo: packageOrBaseImageNameOrNil source: aSourceCode stamp: aStamp  

	methodReference := aMethodReference.
	doItOnlyIfInBaseSystem := packageOrBaseImageNameOrNil == #BaseImage.
	appliesTo := packageOrBaseImageNameOrNil.
	sourceCode := aSourceCode.
	stamp := aStamp.! !


!MethodDeletionChange class methodsFor: 'instance creation' stamp: 'jmv 5/May/2026 17:50:19'!
methodReference: aMethodReference appliesOnlyTo: packageOrBaseImageNameOrNil source: aSourceCode stamp: aStamp

	^self new
		initializeMethodReference: aMethodReference
		appliesOnlyTo: packageOrBaseImageNameOrNil
		source: aSourceCode
		stamp: aStamp! !


!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 18:01:05'!
fileOutClassDeletionFrom: aClassChangeRecord appliesOnlyTo: packageOrBaseImageNameOrNil on: stream

	| record |
	
	record := ClassDeletionChange
		className: aClassChangeRecord thisName
		definition: aClassChangeRecord priorDefinition
		appliesOnlyTo: packageOrBaseImageNameOrNil
		stamp: aClassChangeRecord stamp.

	record fileOutOn: stream.! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 18:01:46'!
fileOutMethodRemovalOf: selector for: class appliesOnlyTo: packageOrBaseImageNameOrNil on: stream stamp: stamp

	| methodReference changeRecord |

	methodReference := MethodReference class: class selector: selector.

	changeRecord := MethodDeletionChange
		methodReference: methodReference
		appliesOnlyTo: packageOrBaseImageNameOrNil
		source: (methodReference sourceCodeIfAbsent: [ 'Missing' ])
		stamp: stamp.

	changeRecord fileOutOn: stream.! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 18:08:33'!
fileOutMethodRemovalsOf: changeTypes appliesOnlyTo: packageOrBaseImageNameOrNil for: class on: stream
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
				appliesOnlyTo: packageOrBaseImageNameOrNil
				on: stream
				stamp: aMethodChange stamp ]].! !


!ChangeList methodsFor: 'scanning' stamp: 'jmv 5/May/2026 17:57:29'!
scanClassRemoval: tokens

	| packageOrBaseImageNameOrNil removeType classDefinition className description record stamp |

	removeType := tokens first.
	className := tokens second.
	packageOrBaseImageNameOrNil := removeType == #classMoveToSomePackage: ifTrue: [ #BaseImage ].
	stamp := CompiledMethod stampFrom: tokens.
	classDefinition := file nextChunk.

	record := ClassDeletionChange
			className: className
			definition: classDefinition
			appliesOnlyTo: packageOrBaseImageNameOrNil
			stamp: stamp.

	description := packageOrBaseImageNameOrNil notNil
			ifTrue: ['clase move to/from some package: ']
			ifFalse: ['class removal: '].

	self
		addItem: record
		text: description, className, '; ', stamp.! !

!ChangeList methodsFor: 'scanning' stamp: 'jmv 5/May/2026 17:57:28'!
scanMethodRemoval: tokens

	| packageOrBaseImageNameOrNil removeType isMeta sourceCode methodReference className description record selector stamp |

	removeType := tokens first.
	className := tokens second.
	packageOrBaseImageNameOrNil := removeType == #methodMoveToSomePackage: ifTrue: [ #BaseImage ].

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
		appliesOnlyTo: packageOrBaseImageNameOrNil
		source: sourceCode
		stamp: stamp.

	description := packageOrBaseImageNameOrNil notNil
		ifTrue: ['method move to/from some package: ']
		ifFalse: ['method removal: '].

	self
		addItem: record
		text: description, methodReference stringVersion.! !


!ChangeList class methodsFor: 'public access' stamp: 'jmv 5/May/2026 17:48:34'!
browsePackageContents: aFileEntry
	"Opens a changeList on a fileStream"
	| changeList packageFile |
	packageFile := CodePackageFile onFileEntry: aFileEntry.
	changeList := aFileEntry readStreamDo: [ :stream |
		self new scanFile: stream from: 0 to: stream size ].
	"Add deletions of methods and classes that are in the CodePackage (i.e., active in the system)
	but are no longer in the CodePackageFile being viewed."
	packageFile methodsToRemove do: [ :methodReference |
		changeList
			addItem: (MethodDeletionChange new methodReference: methodReference)
			text: 'method no longer in package: ', methodReference stringVersion ].
	packageFile classesToRemove do: [ :clsName |
		changeList
			addItem: (ClassDeletionChange new className: clsName)
			text: 'class no longer in package: ', clsName ].
	changeList clearSelections.
	ChangeListWindow open: changeList label: aFileEntry name.! !


!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 18:03:14'!
fileOutMovedClassesOn: stream

	| classRecords |
	classRecords := changeRecords values select: [ :aChangeRecord |
		aChangeRecord isClassMoveToOtherPackage ].
	classRecords := self sortedClassRecords: classRecords.
	classRecords do: [ :aMovedClassRecord |
		self fileOutClassDeletionFrom: aMovedClassRecord appliesOnlyTo: nil on: stream ].! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 18:09:44'!
fileOutRemovedAndMovedMethodsOf: classList on: stream

	classList reverseDo: [ :aClass |
		self
			fileOutMethodRemovalsOf: #(remove addedThenRemoved)
			appliesOnlyTo: nil
			for: aClass
			on: stream.
		self
			fileOutMethodRemovalsOf: #(movedToOtherPackage)
			appliesOnlyTo: #BaseImage
			for: aClass
			on: stream.
		].! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 18:03:02'!
fileOutRemovedClassesOn: stream

	| classRecords |
	classRecords := changeRecords values select: [ :aChangeRecord |
		aChangeRecord isClassRemoval ].
	classRecords := self sortedClassRecords: classRecords.
	classRecords do: [ :aRemovedClassRecord | 
		self fileOutClassDeletionFrom: aRemovedClassRecord appliesOnlyTo: nil on: stream ].! !

!methodRemoval: ChangeSet #fileOutMethodRemovalOf:for:movedToOtherPackage:on:stamp: stamp: 'jmv 5/May/2026 18:07:06'!
ChangeSet removeSelector: #fileOutMethodRemovalOf:for:movedToOtherPackage:on:stamp:!
!methodRemoval: ChangeSet #fileOutClassDeletionFrom:doItOnlyIfInBaseSystem:on: stamp: 'jmv 5/May/2026 18:03:31'!
ChangeSet removeSelector: #fileOutClassDeletionFrom:doItOnlyIfInBaseSystem:on:!
!methodRemoval: ChangeSet #fileOutMethodRemovalsOf:movedToOtherPackage:for:on: stamp: 'jmv 5/May/2026 18:09:52'!
ChangeSet removeSelector: #fileOutMethodRemovalsOf:movedToOtherPackage:for:on:!
!methodRemoval: MethodDeletionChange class #methodReference:doItOnlyIfInBaseSystem:source:stamp: stamp: 'jmv 5/May/2026 18:07:20'!
MethodDeletionChange class removeSelector: #methodReference:doItOnlyIfInBaseSystem:source:stamp:!
!methodRemoval: MethodDeletionChange #initializeMethodReference:doItOnlyIfInBaseSystem:source:stamp: stamp: 'jmv 5/May/2026 18:07:30'!
MethodDeletionChange removeSelector: #initializeMethodReference:doItOnlyIfInBaseSystem:source:stamp:!
!methodRemoval: MethodDeletionChange #appliesTo: stamp: 'jmv 5/May/2026 17:34:16'!
MethodDeletionChange removeSelector: #appliesTo:!
!methodRemoval: MethodDeletionChange #doItOnlyIfInBaseSystem: stamp: 'jmv 5/May/2026 17:48:44'!
MethodDeletionChange removeSelector: #doItOnlyIfInBaseSystem:!
!methodRemoval: MethodDeletionChange #appliesOnlyTo: stamp: 'jmv 5/May/2026 17:49:04'!
MethodDeletionChange removeSelector: #appliesOnlyTo:!
!methodRemoval: ClassDeletionChange class #className:definition:doItOnlyIfInBaseSystem:stamp: stamp: 'jmv 5/May/2026 18:03:38'!
ClassDeletionChange class removeSelector: #className:definition:doItOnlyIfInBaseSystem:stamp:!
!methodRemoval: ClassDeletionChange #initializeClassName:definition:doItOnlyIfInBaseSystem:stamp: stamp: 'jmv 5/May/2026 18:03:44'!
ClassDeletionChange removeSelector: #initializeClassName:definition:doItOnlyIfInBaseSystem:stamp:!
!methodRemoval: ClassDeletionChange #appliesTo: stamp: 'jmv 5/May/2026 17:34:13'!
ClassDeletionChange removeSelector: #appliesTo:!
!methodRemoval: ClassDeletionChange #doItOnlyIfInBaseSystem: stamp: 'jmv 5/May/2026 17:48:46'!
ClassDeletionChange removeSelector: #doItOnlyIfInBaseSystem:!
!methodRemoval: ClassDeletionChange #appliesOnlyTo: stamp: 'jmv 5/May/2026 17:49:03'!
ClassDeletionChange removeSelector: #appliesOnlyTo:!
!classDefinition: #ClassDeletionChange category: #'Tools-Changes'!
ChangeListElement subclass: #ClassDeletionChange
	instanceVariableNames: 'className doItOnlyIfInBaseSystem classDefinition stamp appliesTo'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Changes'!
!classDefinition: #MethodDeletionChange category: #'Tools-Changes'!
ChangeListElement subclass: #MethodDeletionChange
	instanceVariableNames: 'methodReference doItOnlyIfInBaseSystem sourceCode stamp appliesTo'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Changes'!
