'From Cuis7.7 [latest update: #7906] on 4 May 2026 at 12:28:14 pm'!

!CodeFile methodsFor: 'change record types' stamp: 'jmv 4/May/2026 12:13:26'!
classRenaming: aClassRenameChange

	^self classRenaming: aClassRenameChange string with: aClassRenameChange! !

!CodeFile methodsFor: 'private' stamp: 'jmv 4/May/2026 12:21:45'!
classRenaming: string with: chgRec
	| tokens theClass |
	tokens := Scanner new scanTokens: string.
	tokens size = 5 ifFalse:[^doIts add: chgRec].
	theClass := self getClass: (tokens at: 3).
	theClass definition: string.
	classOrder add: theClass.! !


!ClassRenamedChange methodsFor: 'printing' stamp: 'jmv 4/May/2026 12:19:35'!
string
	^ 'Smalltalk renameClassNamed: #', previousName, ' as: #', newName! !

!ClassRenamedChange methodsFor: 'perform' stamp: 'jmv 4/May/2026 12:04:05'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile classRenaming: self! !

