'From Cuis7.7 [latest update: #7907] on 4 May 2026 at 12:43:41 pm'!
!classDefinition: #ClassRenamingChange category: #'Tools-Changes'!
ChangeListElement subclass: #ClassRenamingChange
	instanceVariableNames: 'previousName newName stamp'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Tools-Changes'!

!ChangeList methodsFor: 'scanning' stamp: 'jmv 4/May/2026 12:40:08'!
scanClassRenaming: tokens

	| record stamp newName previousName preamble |

	preamble := tokens first.
	previousName := tokens second.
	newName := tokens fourth.
	stamp := CompiledMethod stampFrom: tokens.
	file nextChunk.
	
	record := ClassRenamingChange from: previousName to: newName stamp: stamp.
			
	self 
		addItem: record
		text: preamble, ' ', previousName, ' -> ', newName, '; ', stamp.! !


!ChangeListElement methodsFor: 'testing' stamp: 'jmv 4/May/2026 12:32:04'!
isClassRenaming
	^false! !


!ClassRenamingChange methodsFor: 'initialization' stamp: 'jmv 4/May/2026 12:38:02'!
initializeFrom: previousClassName to: newClassName stamp: aString 

	previousName := previousClassName.
	newName := newClassName.
	stamp := aString.! !

!ClassRenamingChange methodsFor: 'accessing' stamp: 'jmv 4/May/2026 12:38:02'!
changeClass
	^Smalltalk at: previousName ifAbsent: nil! !

!ClassRenamingChange methodsFor: 'accessing' stamp: 'jmv 4/May/2026 12:38:02'!
changeClassName
	^ previousName ! !

!ClassRenamingChange methodsFor: 'accessing' stamp: 'jmv 4/May/2026 12:38:02'!
newClassName
	^ newName ! !

!ClassRenamingChange methodsFor: 'accessing' stamp: 'jmv 4/May/2026 12:38:02'!
stamp
	^stamp! !

!ClassRenamingChange methodsFor: 'testing' stamp: 'jmv 4/May/2026 12:32:07'!
isClassRenaming
	^true! !

!ClassRenamingChange methodsFor: 'printing' stamp: 'jmv 4/May/2026 12:38:02'!
command
	^ 'Smalltalk renameClassNamed: #', previousName, ' as: #', newName! !

!ClassRenamingChange methodsFor: 'printing' stamp: 'jmv 4/May/2026 12:38:02'!
string
	^ 'Smalltalk renameClassNamed: #', previousName, ' as: #', newName! !

!ClassRenamingChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 4/May/2026 12:38:02'!
fileIn

	Smalltalk renameClassNamed: previousName as: newName! !

!ClassRenamingChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 4/May/2026 12:30:42'!
fileOutOn: aFileStream
	"File the receiver out on the given file stream"

	aFileStream nextPut: $!!.
	aFileStream nextChunkPut: 'classRenaming: #', previousName, ' as: #', newName.
	aFileStream newLine.
	
	aFileStream nextChunkPut: self command.
	aFileStream newLine.! !

!ClassRenamingChange methodsFor: 'perform' stamp: 'jmv 4/May/2026 12:38:02'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile classRenaming: self! !


!ClassRenamingChange class methodsFor: 'instance creation' stamp: 'jmv 4/May/2026 12:38:02'!
from: previousClassName to: newClassName stamp: aString
	^self new initializeFrom: previousClassName to: newClassName stamp: aString ! !


!ChangeList methodsFor: 'scanning' stamp: 'jmv 4/May/2026 12:42:19'!
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
			ifTrue: [ ^ self scanClassDefinition: tokens ].
		(firstToken == #classRemoval: or: [ firstToken == #classMoveToSomePackage: ])
			ifTrue: [ ^ self scanClassRemoval: tokens ].
		(firstToken == #methodRemoval: or: [ firstToken == #methodMoveToSomePackage: ])
			ifTrue: [ ^ self scanMethodRemoval: tokens ].
		(secondToken == #methodsFor: or: [ 
			tokens size > 2 and: [ tokens third == #methodsFor: ] ])
			ifTrue: [ ^ self scanMethodDefinition: tokens ].
		secondToken == #commentStamp:
			ifTrue: [ ^ self scanClassComment: tokens ].
		firstToken == #provides:
			ifTrue: [ ^ self scanFeatureProvision: tokens ].
		firstToken == #requires:
			ifTrue: [ ^ self scanFeatureRequirement: tokens ].
		firstToken == #classRenaming:
			ifTrue: [ ^ self scanClassRenaming: tokens ].
		].! !


!ChangeList class methodsFor: 'scanning' stamp: 'jmv 4/May/2026 12:30:46'!
knownFileInPreambles

	^ `{
	'classDefinition:'. 
	'classRemoval:'. 
	'methodRemoval:'. 
	'methodMoveToSomePackage:'. 
	'classMoveToSomePackage:'. 
	'provides:'. 
	'requires:'.
	'classRenaming:'. }`! !


!ChangeSet methodsFor: 'private' stamp: 'jmv 4/May/2026 12:38:30'!
fileOutClassDefinition: class on: stream
	"Write out class definition for the given class on the given stream, if the class definition was added or changed."

	(self atClass: class includes: #rename) ifTrue: [
		(ClassRenamingChange from: (self oldNameFor: class) to: class name stamp: nil) fileOutOn: stream.
		stream newLine ].

	(self atClass: class includes: #change) ifTrue: [ "fat definition only needed for changes"
		stream
			nextPut: $!!; nextChunkPut: class definitionPreambleWithoutStamp; newLine;
			nextChunkPut: (self fatDefForClass: class); newLine.
	] ifFalse: [
		(self atClass: class includes: #add) ifTrue: [ "use current definition for add"
			stream
				nextPut: $!!; nextChunkPut: class definitionPreambleWithoutStamp; newLine;
				nextChunkPut: class definition; newLine.
		].
	].

	(self atClass: class includes: #comment) ifTrue: [
		class theNonMetaClass organization putCommentOnFile: stream numbered: 0 moveSource: false forClass: class theNonMetaClass.
		stream newLine].! !


!CodeFile methodsFor: 'change record types' stamp: 'jmv 4/May/2026 12:41:23'!
classRenaming: aClassRenamingChange

	^self classRenaming: aClassRenamingChange string with: aClassRenamingChange! !

!methodRemoval: ClassRenamingChange #isClassRenamed stamp: 'jmv 4/May/2026 12:40:48'!
ClassRenamingChange removeSelector: #isClassRenamed!
!methodRemoval: ChangeListElement #isClassRenamed stamp: 'jmv 4/May/2026 12:40:47'!
ChangeListElement removeSelector: #isClassRenamed!
!methodRemoval: ChangeList #scanClassRenamed: stamp: 'jmv 4/May/2026 12:40:16'!
ChangeList removeSelector: #scanClassRenamed:!
!classRemoval: #ClassRenamedChange stamp: 'jmv 4/May/2026 12:43:05'!
Smalltalk removeClassNamed: #ClassRenamedChange!

