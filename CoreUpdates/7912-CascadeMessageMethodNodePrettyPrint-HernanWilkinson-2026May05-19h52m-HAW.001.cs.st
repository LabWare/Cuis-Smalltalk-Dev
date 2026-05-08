'From Cuis7.7 [latest update: #7911] on 8 May 2026 at 2:42:17 pm'!

!CascadeNode methodsFor: 'printing' stamp: 'HAW 8/May/2026 12:28:50'!
printOn: aStream indent: level precedence: p

	p > 0 ifTrue: [ aStream nextPut: $( ].
	messages first
		printReceiver: receiver
		on: aStream
		indent: level.
	1
		to: messages size
		do: [ :i | 
			aStream newLineTab: level + 1.
			(messages at: i)
				printOn: aStream
				indent: level.
			i < messages size ifTrue: [ aStream nextPut:$; ] ].
	p > 0 ifTrue: [ aStream nextPut: $) ]! !


!MessageNode methodsFor: 'printing' stamp: 'HAW 8/May/2026 12:33:58'!
printKeywords: key arguments: args on: aStream indent: level
	| keywords indent arg kwd doCrTab indexLimit |
	args size = 0 ifTrue: [
		receiver ifNotNil: [ aStream space ].
		aStream nextPutAll: key.
		^ self ].
	keywords := key keywords.
	doCrTab := args size > 1 and: [ receiver notNil ].
	indexLimit := args size min: keywords size.
	1
		to: indexLimit
		do: [ :i |
			arg := args at: i.
			kwd := keywords at: i.
			doCrTab
				ifTrue: [
					aStream newLineTab: level + 1.
					indent := 1
					"newline after big args" ]
				ifFalse: [
					receiver ifNotNil: [ aStream space ].
					indent := 0 ].
			aStream nextPutAll: kwd.
			arg printsInNewLine
				ifTrue: [
					aStream newLineTab: level + indent + 1 ]
				ifFalse: [
					aStream space ].
			arg
				printOn: aStream
				indent: level + 1 + indent
				precedence:
					(precedence = 2
						ifTrue: [ 1 ]
						ifFalse: [ precedence ]).
			(i~=indexLimit and: [args size > 1 and: [ doCrTab not ]]) ifTrue: [ aStream space ]].! !

