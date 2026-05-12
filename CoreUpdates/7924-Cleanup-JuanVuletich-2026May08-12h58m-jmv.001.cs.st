'From Cuis7.7 [latest update: #7916] on 8 May 2026 at 2:22:39 pm'!

!Behavior methodsFor: 'accessing method dictionary' stamp: 'jmv 8/May/2026 14:08:43'!
removeSelector: selector 
	"Assuming that the argument, selector (a Symbol), is a message selector 
	in my method dictionary, remove it and its method."

	self basicRemoveSelector: selector.! !


!ClassDescription methodsFor: 'accessing method dictionary' stamp: 'jmv 8/May/2026 14:09:10'!
removeSelector: selector 
	| priorMethod priorProtocol | 
	"Remove the message whose selector is given from the method 
	dictionary of the receiver, if it is there."

	priorMethod := self compiledMethodAt: selector ifAbsent: [^ self].
	(self theNonMetaClass isOkToRemoveMethod: selector isMeta: self isMeta)
		ifFalse: [self error: 'Method removal not allowed'].
	priorProtocol := self whichCategoryIncludesSelector: selector.
	SystemChangeNotifier uniqueInstance doSilently: [
		self organization removeElement: selector ].
	super removeSelector: selector.
	SystemChangeNotifier uniqueInstance 
			methodRemoved: priorMethod selector: selector inProtocol: priorProtocol class: self.! !

!ClassDescription methodsFor: 'accessing method dictionary' stamp: 'jmv 8/May/2026 14:06:55'!
removeSelectorIfInBaseSystem: selector
	"Remove the message whose selector is given from the method 
	dictionary of the receiver, if it is there and not part of a package."
	| priorProtocol | 

	self compiledMethodAt: selector ifAbsent: [^ self].
	priorProtocol := self whichCategoryIncludesSelector: selector.
	CodePackage
		packageOfMethodCategory: priorProtocol
		ofClass: self
		ifNone: [
			"If remove is actually done, then include it in the current change set for the base system,
			as a regular remove."
			self removeSelector: selector ]! !

!ClassDescription methodsFor: 'fileIn/Out' stamp: 'jmv 8/May/2026 14:18:35'!
classComment: aString
	"Store the comment, aString or Text or RemoteString, associated with the class we are orgainzing.  Empty string gets stored only if had a non-empty one before."
	self classComment: aString stamp: '<historical>'! !

!ClassDescription methodsFor: 'fileIn/Out' stamp: 'jmv 8/May/2026 14:20:02'!
classComment: aString stamp: aStamp
	"Store the comment, aString or Text or RemoteString, associated with the class we are organizing.  Empty string gets stored only if had a non-empty one before."

	| ptr header oldCommentRemoteStr |
	aString isRemote ifTrue: [
		SystemChangeNotifier uniqueInstance classCommented: self.
		self organization classComment: aString stamp: aStamp.
		^self ].

	oldCommentRemoteStr := self organization commentRemoteStr.
	(aString isEmpty) & (oldCommentRemoteStr == nil) ifTrue: [
		self organization classComment: nil.
		^self ].
		"never had a class comment, no need to write empty string out"

	ptr := oldCommentRemoteStr ifNil: [0] ifNotNil: [oldCommentRemoteStr sourcePointer].
	SourceFiles ifNotNil: [ | file |
		(file := SourceFiles at: 2) ifNotNil: [
			file setToEnd; newLine; nextPut: $!!.	"directly"
			header := String streamContents: [:strm | strm nextPutAll: self name;
				nextPutAll: ' commentStamp: '.
				aStamp storeOn: strm.
				strm nextPutAll: ' prior: '; nextPutAll: ptr printString].
			file nextChunkPut: header]].
	self organization classComment: (RemoteString newString: aString onFileNumber: 2) stamp: aStamp.
	Smalltalk userChangesAppendDo: [ :stream |
		stream newLine; nextPut: $!!.	"directly"
		header := String streamContents: [:strm | strm nextPutAll: self name;
			nextPutAll: ' commentStamp: '.
			aStamp storeOn: strm.
			strm nextPutAll: ' prior: '; nextPutAll: ptr printString].
		stream nextChunkPut: header.
		stream newLine; nextChunkPut: aString ].
	SystemChangeNotifier uniqueInstance classCommented: self.! !


!Categorizer methodsFor: 'accessing' stamp: 'jmv 8/May/2026 14:12:36'!
changeFromString: aString
	"Parse the argument, aString, and make this be the receiver's structure."

	| categorySpecs |
	categorySpecs := Scanner new scanTokens: aString.
	"If nothing was scanned and I had no elements before, then default me"
	(categorySpecs isEmpty and: [elementArray isEmpty])
		ifTrue: [
			self initEmpty.
			^self ].

	self changeFromCategorySpecs: categorySpecs.! !


!BasicClassOrganizer methodsFor: 'accessing' stamp: 'jmv 8/May/2026 14:18:50'!
classComment: aString 
	"Store the comment, aString, associated with the object that refers to the 
	receiver."

	aString ifNil: [
		classComment := nil.
		^self ].
	
	aString isRemote
		ifTrue: [classComment := aString]
		ifFalse: [aString isEmpty
			ifTrue: [classComment := nil]
			ifFalse: [
				self error: 'use aClass classComment:'.
				classComment := RemoteString newString: aString onFileNumber: 2]]
				"Later add priorSource and date and initials?"! !


!SystemDictionary methodsFor: 'shrinking' stamp: 'jmv 8/May/2026 14:09:26'!
removeSelector: descriptor
	"Safely remove a selector from a class (or metaclass). If the class
	or the method doesn't exist anymore, never mind.
	This method should be used instead of 'Class removeSelector: #method'
	to omit global class references."

	| class sel |
	class := self at: descriptor first ifAbsent: [^ self].
	(descriptor size > 2 and: [descriptor second == #class])
		ifTrue:
			[class := class class.
			sel := descriptor third]
		ifFalse: [sel := descriptor second].
	^ class removeSelector: sel! !


!ChangeList methodsFor: 'scanning' stamp: 'jmv 8/May/2026 14:14:20'!
scanMethodDefinition: tokens

	| stamp className priorVersionPosition libraryName |
	
	className := tokens first.
	stamp := CompiledMethod stampFrom: tokens.
	priorVersionPosition := CompiledMethod priorReferenceFrom: tokens.
	libraryName := CompiledMethod libraryNameFrom: tokens.
	
	tokens second == #methodsFor: ifTrue: [
		self scanCategory: tokens third class: className meta: false stamp: stamp prior: priorVersionPosition libraryName: libraryName.
		^self ].

	tokens third == #methodsFor: ifTrue: [
		self scanCategory: tokens fourth class: className meta: true stamp: stamp prior: priorVersionPosition libraryName: libraryName.
		^self ].
	
	self error: 'Unsupported method definition' 
! !

!ChangeList methodsFor: 'scanning' stamp: 'jmv 8/May/2026 14:15:26'!
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
		(firstToken == #classRemoval: or: [ firstToken == #classMoveToSomePackage: ])
			ifTrue: [
				self scanClassRemoval: tokens.
				^self ].
		(firstToken == #methodRemoval: or: [ firstToken == #methodMoveToSomePackage: ])
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


!ClassCommentChange methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:58:57'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile classComment: self.! !


!ClassDefinitionChange methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:59:05'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile classDefinition: self.! !


!ClassDeletionChange methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:59:13'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile classRemoval: self.! !


!ClassRenamedChange methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:59:20'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile classRenaming: self.! !


!FeatureProvidesRecord methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:59:27'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile provides: self.! !


!FeatureRequiresRecord methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:59:34'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile requires: self.! !


!MethodDefinitionChange methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:59:40'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile method: self.! !


!MethodDeletionChange methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:59:48'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile removedMethod: self command with: self.! !


!PreambleRecord methodsFor: 'perform' stamp: 'jmv 8/May/2026 12:59:58'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile preamble: self.! !


!UnspecificRecord methodsFor: 'perform' stamp: 'jmv 8/May/2026 13:00:06'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	aCodeFile doIt: self.! !


!CodeFile methodsFor: 'change record types' stamp: 'jmv 8/May/2026 14:03:55'!
classDefinition: chgRec
	"See senders of #classDefinition "
	| string |
	string := chgRec string.
	chgRec isMetaClassChange 
		ifTrue: [self metaClassDefinition: string with: chgRec]
		ifFalse: [self classDefinition: string with: chgRec].! !

!CodeFile methodsFor: 'change record types' stamp: 'jmv 8/May/2026 13:04:37'!
classRemoval: aClassDeletionChange
	self classRemoval: aClassDeletionChange string with: aClassDeletionChange.! !

!CodeFile methodsFor: 'change record types' stamp: 'jmv 8/May/2026 13:01:50'!
classRenaming: aClassRenameChange

	self classRenaming: aClassRenameChange string with: aClassRenameChange! !

!CodeFile methodsFor: 'change record types' stamp: 'jmv 8/May/2026 14:03:06'!
doIt: chgRec
	"See senders of #doIt "
	| string |
	string := chgRec string.
	
	"Method classification spec"
	(string beginsWith: '(''') ifTrue: [
		doIts add: chgRec.
		^self ].
		
	"Just for compatibility with Squeak, as Cuis always adds the #classDefinition change type marker in the files."
	('*ubclass:*instanceVariableNames:*classVariableNames:*poolDictionaries:*category:*'
		match: string) ifTrue: [
			self classDefinition: string with: chgRec.
			^self ].

	"Just for compatibility with Squeak, as Cuis always adds the #classDefinition change type marker in the files."
	('* class*instanceVariableNames:*'
		match: string) ifTrue: [
			self metaClassDefinition: string with: chgRec.
			^self ].

	"Just for compatibility with Squeak, as Cuis always adds the #methodRemoval: (or similar) change type marker in the files."
	('* removeSelector: *'
		match: string) ifTrue: [
			self removedMethodSqueakCompatibility: string with: chgRec.
			^self ].

	"Just for compatibility with Squeak, as Cuis always adds the #classComment change type marker in the files."
	('* comment:*'
		match: string) ifTrue: [
			self msgClassComment: string with: chgRec.
			^self ].

	"Don't add these to a CodeFile. They will be added on save if needed."
	('* initialize'
		match: string) ifTrue: [^self]. "Initialization is done based on class>>initialize"

	('''From *'
		match: string) ifTrue: [
			self possibleSystemSource: chgRec.
			^self ].

	doIts add: chgRec.! !

!CodeFile methodsFor: 'private' stamp: 'jmv 8/May/2026 14:03:43'!
classDefinition: string with: chgRec
	| tokens theClass |
	tokens := Scanner new scanTokens: string.
	tokens size = 11 ifFalse: [
		doIts add: chgRec.
		^self ].
	theClass := self getClass: (tokens at: 3).
	theClass definition: string.
	classOrder add: theClass.! !

!CodeFile methodsFor: 'private' stamp: 'jmv 8/May/2026 14:04:36'!
classRemoval: string with: chgRec
	| tokens theClass |
	tokens := Scanner new scanTokens: string.
	tokens size = 3 ifFalse: [
		doIts add: chgRec.
		^self ].
	theClass := self getClass: (tokens at: 3).
	theClass definition: string.
	classOrder add: theClass.! !

!CodeFile methodsFor: 'private' stamp: 'jmv 8/May/2026 13:03:53'!
classRenaming: string with: chgRec
	| tokens theClass |
	tokens := Scanner new scanTokens: string.
	tokens size = 5 ifFalse: [
		doIts add: chgRec.
		^self ].
	theClass := self getClass: (tokens at: 3).
	theClass definition: string.
	classOrder add: theClass.! !

!CodeFile methodsFor: 'private' stamp: 'jmv 8/May/2026 14:05:09'!
msgClassComment: string with: chgRec
	| tokens theClass |
	tokens := Scanner new scanTokens: string.
	(tokens size = 3 and:[(tokens at: 3) isString ]) ifTrue: [
		theClass := self getClass: tokens first.
		theClass classComment: tokens last.
		^self ].
	(tokens size = 4 and:[(tokens at: 3) asString = 'class' and:[(tokens at: 4) isString ]]) ifTrue: [
		theClass := self getClass: tokens first.
		theClass theMetaClass classComment: tokens last ].! !

!CodeFile methodsFor: 'private' stamp: 'jmv 8/May/2026 13:03:19'!
removedMethod: string with: chgRec
	| class tokens firstToken secondToken thirdToken |
	tokens := Scanner new scanTokens: string.
	tokens size >= 3 ifTrue: [
		firstToken := tokens at: 1.
		secondToken := tokens at: 2.
		thirdToken := tokens at: 3.
		(tokens size = 3 and: [
			secondToken == #removeSelector: or: [
			secondToken == #removeSelectorIfInBaseSystem: ]]) ifTrue:[
				class := self getClass: firstToken.
				class perform: secondToken with: thirdToken.
				^self ].
		(tokens size = 4 and: [ secondToken == #class and: [
			thirdToken == #removeSelector: or: [
			thirdToken == #removeSelectorIfInBaseSystem: ]]]) ifTrue:[
				class := self getClass: firstToken.
				class theMetaClass perform: thirdToken with: (tokens at: 4).
				^self ]].
	doIts add: chgRec.! !

!CodeFile methodsFor: 'private' stamp: 'jmv 8/May/2026 14:05:51'!
removedMethodSqueakCompatibility: string with: chgRec
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


!CodePackageFile methodsFor: 'change record types' stamp: 'jmv 8/May/2026 14:01:38'!
doIt: chgRec
	| string |
	string := chgRec string.
	('''Description *'
		match: string) ifTrue: [
			self possibleDescription: chgRec.
			^self ].
	super doIt: chgRec.! !

