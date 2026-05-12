'From Cuis7.7 [latest update: #7910] on 5 May 2026 at 6:12:44 pm'!

!ClassDeletionChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 5/May/2026 18:12:13'!
fileIn

	appliesTo == #BaseImage
		ifTrue: [ Smalltalk removeClassNamedIfInBaseSystem: className]
		ifFalse: [ self changeClass ifNotNil: [ :aClass | aClass removeFromSystem ] ]! !

!ClassDeletionChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 5/May/2026 18:12:24'!
fileOutOn: stream
	"File the receiver out on the given file stream"

	| record |
		
	record := String streamContents: [ :recordStream |
		recordStream
		 	nextPutAll: (appliesTo == #BaseImage ifTrue: [ 'classMoveToSomePackage: #' ] ifFalse: ['classRemoval: #']);
			nextPutAll: className;
			nextPutAll: ' stamp: ';
			print: stamp ].
		
	stream 
		nextPut: $!!;
		nextChunkPut: record;
		newLine;
		nextChunkPut: self command;
		newLine; newLine.
	! !

!ClassDeletionChange methodsFor: 'services' stamp: 'jmv 5/May/2026 18:11:54'!
command

	^appliesTo == #BaseImage
		ifTrue: [ 'Smalltalk removeClassNamedIfInBaseSystem: #', className ]
		ifFalse: [ 'Smalltalk removeClassNamed: #', className ].
! !


!MethodDeletionChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 5/May/2026 18:12:06'!
fileIn

	appliesTo == #BaseImage
		ifTrue: [ methodReference actualClass removeSelectorIfInBaseSystem: self methodSelector ]
		ifFalse: [ methodReference actualClass removeSelector: self methodSelector ]! !

!MethodDeletionChange methodsFor: 'fileIn/fileOut' stamp: 'jmv 5/May/2026 18:12:10'!
fileOutOn: stream
	"File the receiver out on the given file stream"

	| record |

	record := String streamContents: [ :recordStream |
		recordStream
		 	nextPutAll: (appliesTo == #BaseImage ifTrue: [ 'methodMoveToSomePackage: ' ] ifFalse: ['methodRemoval: ']);
			nextPutAll: self changeClassName;
			space;
			nextPutAll: self methodSelector storeString;
			nextPutAll: ' stamp: ';
			print: stamp ].
		
	stream 
		nextPut: $!!;
		nextChunkPut: record;
		newLine;
		nextChunkPut: self command;
		newLine
	
! !

!MethodDeletionChange methodsFor: 'services' stamp: 'jmv 5/May/2026 18:12:02'!
command

	^String streamContents: [ :stream |
		stream
			nextPutAll: self changeClassName;
			space;
			nextPutAll: (appliesTo == #BaseImage ifTrue: ['removeSelectorIfInBaseSystem:'] ifFalse: ['removeSelector:']);
			space;
			nextPutAll: self methodSelector storeString ]! !

