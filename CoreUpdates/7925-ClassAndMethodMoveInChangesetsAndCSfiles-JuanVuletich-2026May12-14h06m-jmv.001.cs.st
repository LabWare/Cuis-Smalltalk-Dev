'From Cuis7.7 [latest update: #7924] on 12 May 2026 at 2:11:45 pm'!

!ClassDescription methodsFor: 'accessing method dictionary' stamp: 'jmv 8/May/2026 11:30:19'!
removeSelector: selector ifIn: packageOrBaseImageNameOrNil
	"Remove the message whose selector is given from the method 
	dictionary of the receiver, if it is there and if it is part of the requested package or base image."
	| priorProtocol codePackage | 

	self compiledMethodAt: selector ifAbsent: [
		^ self].
	packageOrBaseImageNameOrNil ifNil: [
		self removeSelector: selector.
		^self ].
	priorProtocol := self whichCategoryIncludesSelector: selector.
	codePackage := CodePackage
		packageOfMethodCategory: priorProtocol
		ofClass: self
		ifNone: nil.
	(codePackage
		ifNil: [packageOrBaseImageNameOrNil == #BaseImage]
		ifNotNil: [codePackage packageName = packageOrBaseImageNameOrNil]) ifTrue: [
			"If remove is actually done, then include it in the current change set for the base system,
			as a regular remove."
			self removeSelector: selector ].! !


!SystemDictionary methodsFor: 'class names' stamp: 'jmv 8/May/2026 11:37:23'!
removeClassNamed: aName ifIn: packageOrBaseImageNameOrNil
	"Invoked from fileouts:  if there is currently a class in the system named aName, and it is part of the requested package or base image, then remove it."

	| oldClass codePackage |
	oldClass := self at: aName asSymbol ifAbsent: [
"		Transcript newLine; show: 'Removal of class named ', aName, ' ignored because ', aName, ' does not exist.'."
		^ self].
	
	packageOrBaseImageNameOrNil ifNil: [
		self removeClassNamed: aName.
		^self ].

	codePackage := CodePackage
		packageOfClass: oldClass
		ifNone: nil.
	(codePackage
		ifNil: [packageOrBaseImageNameOrNil == #BaseImage]
		ifNotNil: [codePackage packageName = packageOrBaseImageNameOrNil]) ifTrue: [
			"If remove is actually done, then include it in the current change set for the base system,
			as a regular remove."
			oldClass removeFromSystem ].! !


!ChangeList methodsFor: 'scanning' stamp: 'jmv 8/May/2026 12:08:03'!
scanClassRemoval: tokens

	| packageOrBaseImageNameOrNil removeType classDefinition className description record stamp |
	removeType := tokens first.
	className := tokens second.
	packageOrBaseImageNameOrNil := (tokens size > 3 and: [ tokens third = #restrictedTo: ])
		ifTrue: [ tokens fourth ].

	stamp := CompiledMethod stampFrom: tokens.
	classDefinition := file nextChunk.

	record := ClassDeletionChange
			className: className
			definition: classDefinition
			appliesOnlyTo: packageOrBaseImageNameOrNil
			stamp: stamp.

	description := packageOrBaseImageNameOrNil notNil
			ifTrue: ['clase move out (to some package or BaseImage): ']
			ifFalse: ['class removal: '].

	self
		addItem: record
		text: description, className, '; ', stamp.! !

!ChangeList methodsFor: 'scanning' stamp: 'jmv 8/May/2026 12:08:30'!
scanMethodRemoval: tokens

	| packageOrBaseImageNameOrNil removeType isMeta sourceCode methodReference className description record selector stamp |
	removeType := tokens first.
	className := tokens second.
	packageOrBaseImageNameOrNil := (tokens size > 4 and: [ tokens fourth = #restrictedTo: ])
		ifTrue: [ tokens fifth ].

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
		ifTrue: ['method move out (to some package or BaseImage): ']
		ifFalse: ['method removal: '].

	self
		addItem: record
		text: description, methodReference stringVersion.! !

!ChangeList methodsFor: 'scanning' stamp: 'jmv 12/May/2026 10:36:48'!
scanSpecificChangeType
	"Scan anything that involves more than one chunk"

	| itemPosition item tokens firstToken secondToken |

	itemPosition := file position.
	item := file nextChunk.

	(self itemIsRecognized: item) ifFalse: [
		"Maybe a preamble, but not one we recognize; bail out with the preamble trick"
		^ self scanAndIgnore: item in: itemPosition ].

	tokens := Scanner new scanTokens: item.
	tokens size >= 2 ifTrue: [
		firstToken := tokens first.
		secondToken := tokens second.

		firstToken == #classDefinition:
			ifTrue: [
				self scanClassDefinition: tokens.
				^self ].
		firstToken == #classRemoval:
			ifTrue: [
				self scanClassRemoval: tokens.
				^self ].
		firstToken == #methodRemoval:
			ifTrue: [
				self scanMethodRemoval: tokens.
				^self ].
		(secondToken == #methodsFor: or: [ 
			tokens size > 2 and: [ tokens third == #methodsFor: ] ])
			ifTrue: [
				self scanMethodDefinition: tokens.
				^self ].
		secondToken == #commentStamp:
			ifTrue: [
				self scanClassComment: tokens.
				^self ].
		firstToken == #provides:
			ifTrue: [
				self scanFeatureProvision: tokens.
				^self ].
		firstToken == #requires:
			ifTrue: [
				self scanFeatureRequirement: tokens.
				^self ].
		firstToken == #classRenamed:
			ifTrue: [
				self scanClassRenamed: tokens.
				^self ].
		]! !


!ChangeList class methodsFor: 'scanning' stamp: 'jmv 7/May/2026 12:28:03'!
knownFileInPreambles

	^ `{
	'classDefinition:'.
	'classRemoval:'.
	'methodRemoval:'.
	'provides:'.
	'requires:'.
	'classRenamed:'. }`! !


!ChangeSorter methodsFor: 'code pane' stamp: 'jmv 12/May/2026 11:19:48'!
acceptedStringOrText
	"return the source code that shows in the bottom pane"

	| sel class changeType answer |
	currentClassName ifNil: [^ myChangeSet preambleString ifNil: ['']].
	class := self selectedClassOrMetaClass.
	(sel := currentSelector)
		ifNotNil: [
			changeType := (myChangeSet atSelector: (sel := sel asSymbol) class: class).
			changeType == #remove
				ifTrue: [^'Method has been removed (see versions)'].
			changeType == #addedThenRemoved
				ifTrue: [^'Added then removed (see versions)'].
			changeType == #movedToOtherPackage
				ifTrue: [^'Method was moved to some other package'].
			class ifNil: [^'Method was added, but cannot be found!!'].
			(class includesSelector: sel)
				ifFalse: [^'Method was added, but cannot be found!!'].
			answer :=  (class sourceCodeAt: sel).
			(#(prettyPrint prettyLineDiffs prettyWordDiffs) includes: self contentsSymbol) ifTrue: [
				answer := (class compilerClass new
						format: answer
						in: class 
						notifying: nil)].
			self showingAnyKindOfDiffs
				ifTrue: [ answer := (self diffFromPriorSourceFor: answer) ].
			^ answer ]
		ifNil: [
			^ String streamContents: [ :strm |
				(myChangeSet classChangeAt: currentClassName) do: [ :each |
					each == #remove ifTrue: [strm nextPutAll: 'Entire class was removed.'; newLine].
					each == #addedThenRemoved ifTrue: [strm nextPutAll: 'Class was added then removed.'; newLine].
					each == #rename ifTrue: [strm nextPutAll: 'Class name was changed.'; newLine].
					each == #add ifTrue: [strm nextPutAll: 'Class definition was added.'; newLine].
					each == #change ifTrue: [strm nextPutAll: 'Class definition was changed.'; newLine].
					each == #reorganize ifTrue: [strm nextPutAll: 'Class organization was changed.'; newLine].
					each == #comment ifTrue: [strm nextPutAll: 'New class comment.'; newLine].
					each == #movedToOtherPackage ifTrue: [strm nextPutAll: 'Class was moved to some other package or to the base image.'; newLine].
				]]].! !


!ClassDeletionChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 8/May/2026 11:36:33'!
fileIn

	appliesTo
		ifNotNil: [ Smalltalk removeClassNamed: className ifIn: appliesTo]
		ifNil: [ self changeClass ifNotNil: [ :aClass | aClass removeFromSystem ] ].! !

!ClassDeletionChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 7/May/2026 12:49:53'!
fileOutOn: stream
	"File the receiver out on the given file stream"

	| record |

	record := String streamContents: [ :recordStream |
		recordStream
			nextPutAll: 'classRemoval: #';
			nextPutAll: className.
		appliesTo ifNotNil: [
			recordStream
				nextPutAll: ' restrictedTo: ';
				print: appliesTo ].
		recordStream
			nextPutAll: ' stamp: ';
			print: stamp ].

	stream
		nextPut: $!!;
		nextChunkPut: record;
		newLine;
		nextChunkPut: self command;
		newLine; newLine.! !

!ClassDeletionChange methodsFor: 'services' stamp: 'jmv 8/May/2026 11:10:42'!
command

	^appliesTo
		ifNotNil: [ 'Smalltalk removeClassNamed: #', className, ' ifIn: ', appliesTo printString ]
		ifNil: [ 'Smalltalk removeClassNamed: #', className ].
! !


!MethodDeletionChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 8/May/2026 11:25:49'!
fileIn

	appliesTo
		ifNotNil: [ methodReference actualClass removeSelector: self methodSelector ifIn: appliesTo ]
		ifNil: [ methodReference actualClass removeSelector: self methodSelector ].! !

!MethodDeletionChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 7/May/2026 12:49:45'!
fileOutOn: stream
	"File the receiver out on the given file stream"

	| record |

	record := String streamContents: [ :recordStream |
		recordStream
			nextPutAll: 'methodRemoval: ';
			nextPutAll: self changeClassName;
			space;
			nextPutAll: self methodSelector storeString.
		appliesTo ifNotNil: [
			recordStream
				nextPutAll: ' restrictedTo: ';
				print: appliesTo ].
		recordStream
			nextPutAll: ' stamp: ';
			print: stamp ].

	stream
		nextPut: $!!;
		nextChunkPut: record;
		newLine;
		nextChunkPut: self command;
		newLine.! !

!MethodDeletionChange methodsFor: 'services' stamp: 'jmv 8/May/2026 11:12:07'!
command

	^String streamContents: [ :stream |
		stream
			nextPutAll: self changeClassName;
			nextPutAll: ' removeSelector: ';
			nextPutAll: self methodSelector storeString.
		appliesTo ifNotNil: [
			stream nextPutAll: ' ifIn: '; print: appliesTo ]]! !


!ChangeSet methodsFor: 'change logging' stamp: 'jmv 12/May/2026 13:55:54'!
noteClassMoveToOtherPackage: class
	"The class was just moved from base image or a package to some other package,
	or from a package to the base image, who will hold it.
	Adjust the receiver to reflect that fact."

	class wantsChangeSetLogging ifFalse: [^ self].
	self atClass: class add: #movedToOtherPackage.
	changeRecords removeKey: class class name ifAbsent: nil.
	self hasUnsavedChanges: true.! !

!ChangeSet methodsFor: 'change logging' stamp: 'jmv 12/May/2026 13:56:33'!
noteMethodMoveToOtherPackage: selector forClass: class
	"The method was just moved from base image or a package to some other package,
	who will hold it.
	Adjust the receiver to reflect that fact."

	class wantsChangeSetLogging ifFalse: [^ self].
	(self changeRecorderFor: class)
		noteMethodMoveToOtherPackage: selector.
	self hasUnsavedChanges: true.! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 8/May/2026 11:43:56'!
fileOutMovedClassesOn: stream

	| classRecords |
	classRecords := changeRecords values select: [ :aChangeRecord |
		aChangeRecord isClassMoveToOtherPackage ].
	classRecords := self sortedClassRecords: classRecords.
	classRecords do: [ :aMovedClassRecord |
		self
			fileOutClassDeletionFrom: aMovedClassRecord
			appliesOnlyTo: (isForBaseSystem ifTrue: [#BaseImage] ifFalse: [codePackage packageName])
			on: stream ].! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 8/May/2026 11:43:07'!
fileOutRemovedAndMovedMethodsOf: classList on: stream

	classList reverseDo: [ :aClass |
		self
			fileOutMethodRemovalsOf: #(remove addedThenRemoved)
			appliesOnlyTo: nil
			for: aClass
			on: stream.
		self
			fileOutMethodRemovalsOf: #(movedToOtherPackage)
			appliesOnlyTo: (isForBaseSystem ifTrue: [#BaseImage] ifFalse: [codePackage packageName])
			for: aClass
			on: stream.
		].! !


!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 12/May/2026 11:26:16'!
classRecategorized: aClass from: oldCategory to: newCategory
	"If the class was moved to a dfferent package, out of the base system, record the fact in the change set.
	The actual class redefinition is done at #classDefinitionChangedFrom:to: that is also called (if the class really changed)."

	| newPackageOrNil newChangeSet oldPackageOrNil oldChangeSet |

	aClass wantsChangeSetLogging ifFalse: [ ^self ].

	newPackageOrNil := CodePackage packageOfSystemCategory: newCategory ifNone: nil.
	newPackageOrNil ifNotNil: [ newPackageOrNil hasUnsavedChanges: true ].
	newChangeSet := ChangeSet changeSetForPackage: newPackageOrNil.
	
	oldPackageOrNil := CodePackage packageOfSystemCategory: oldCategory ifNone: nil.
	oldPackageOrNil == newPackageOrNil
		ifTrue: [newChangeSet noteRecategorizationOfClass: aClass.]
		ifFalse: [
			newChangeSet noteAddClass: aClass.
			oldPackageOrNil ifNotNil: [ oldPackageOrNil hasUnsavedChanges: true ].
			oldChangeSet := ChangeSet changeSetForPackage: oldPackageOrNil.
			oldChangeSet noteClassMoveToOtherPackage: aClass ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 12/May/2026 11:11:04'!
selectorRecategorized: selector from: oldCategory to: newCategory inClass: aClass
	"If the method was moved to a dfferent package, affect the package that lost the it. Tell it that it lost the method.
	The actual method redefinition is done at one of the method definition methods, that is also called."

	| newPackageOrNil newChangeSet oldPackageOrNil oldChangeSet |
	
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	
	newPackageOrNil := CodePackage packageOfMethodCategory: newCategory ofClass: aClass ifNone: nil.
	newPackageOrNil ifNotNil: [ newPackageOrNil hasUnsavedChanges: true ].
	newChangeSet := ChangeSet changeSetForPackage: newPackageOrNil.
	newChangeSet noteReorganizeClass: aClass.

	oldPackageOrNil := CodePackage packageOfMethodCategory: oldCategory ofClass: aClass ifNone: nil.
	oldPackageOrNil == newPackageOrNil ifFalse: [
		oldPackageOrNil ifNotNil: [ oldPackageOrNil hasUnsavedChanges: true ].
		oldChangeSet := ChangeSet changeSetForPackage: oldPackageOrNil.
		oldChangeSet noteMethodMoveToOtherPackage: selector forClass: aClass ].! !


!ClassChangeRecord methodsFor: 'all changes' stamp: 'jmv 12/May/2026 11:33:22'!
noteChangeType: changeSymbol fromClass: class

	stamp := Utilities changeStamp.
	
	changeSymbol == #movedToOtherPackage ifTrue: [
		changeTypes removeAll.
		^ changeTypes add: changeSymbol].
	"Any other change type meanse we're still here!!"
	changeTypes remove: #movedToOtherPackage ifAbsent: nil.

	(changeSymbol == #new or: [changeSymbol == #add]) ifTrue: [
		changeTypes add: #add.
		changeTypes remove: #change ifAbsent: nil.
		^ self].
	changeSymbol == #change ifTrue: [
		(changeTypes includes: #add) ifTrue: [^ self].
		^ changeTypes add: changeSymbol].
	changeSymbol == #addedThenRemoved ifTrue: [
		^ self].  "An entire class was added but then removed"
	changeSymbol == #comment ifTrue: [
		^ changeTypes add: changeSymbol].
	changeSymbol == #reorganize ifTrue: [
		^ changeTypes add: changeSymbol].
	changeSymbol == #rename ifTrue: [
		^ changeTypes add: changeSymbol].
	(changeSymbol beginsWith: 'oldName: ') ifTrue: [
		"Must only be used when assimilating other changeSets"
		(changeTypes includes: #add) ifTrue: [^ self].
		priorName := changeSymbol copyFrom: 'oldName: ' size + 1 to: changeSymbol size.
		^ changeTypes add: #rename].
	changeSymbol == #remove ifTrue: [
		(changeTypes includes: #add)
			ifTrue: [changeTypes add: #addedThenRemoved]
			ifFalse: [changeTypes add: #remove].
		^ changeTypes removeAllFoundIn: #(add change comment reorganize)].

	self error: 'Unrecognized changeType'! !


!CodeFile methodsFor: 'private' stamp: 'jmv 12/May/2026 10:45:34'!
removedMethod: string with: chgRec
	| class tokens firstToken secondToken thirdToken |
	tokens := Scanner new scanTokens: string.
	tokens size >= 3 ifTrue: [
		firstToken := tokens at: 1.
		secondToken := tokens at: 2.
		thirdToken := tokens at: 3.
		(tokens size = 3 and: [
			secondToken == #removeSelector: ]) ifTrue:[
				class := self getClass: firstToken.
				class perform: secondToken with: thirdToken.
				^self ].
		(tokens size = 4 and: [ secondToken == #class and: [
			thirdToken == #removeSelector: ]]) ifTrue:[
				class := self getClass: firstToken.
				class theMetaClass perform: thirdToken with: (tokens at: 4).
				^self ]].
	doIts add: chgRec.! !

!methodRemoval: PseudoClass #removeSelectorIfInBaseSystem: stamp: 'jmv 12/May/2026 14:07:19'!
PseudoClass removeSelector: #removeSelectorIfInBaseSystem:!
!methodRemoval: SystemDictionary #removeClassNamedIfInBaseSystem: stamp: 'jmv 12/May/2026 14:07:19'!
SystemDictionary removeSelector: #removeClassNamedIfInBaseSystem:!
!methodRemoval: ClassDescription #removeSelectorIfInBaseSystem: stamp: 'jmv 12/May/2026 14:07:19'!
ClassDescription removeSelector: #removeSelectorIfInBaseSystem:!
