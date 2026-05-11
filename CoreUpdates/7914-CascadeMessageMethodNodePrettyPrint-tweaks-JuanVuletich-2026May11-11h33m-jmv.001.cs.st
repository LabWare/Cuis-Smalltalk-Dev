'From Cuis7.7 [latest update: #7913] on 11 May 2026 at 12:18:20 pm'!

!CascadeNode methodsFor: 'printing' stamp: 'jmv 24/Mar/2014 23:44:00'!
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
				indent: level+1.
			i < messages size ifTrue: [ aStream nextPut:$; ] ].
	p > 0 ifTrue: [ aStream nextPut: $) ]! !


!MessageNode methodsFor: 'printing' stamp: 'jmv 11/May/2026 12:07:52'!
printKeywords: key arguments: args on: aStream indent: level
	| keywords indent arg kwd keywordsInSeparateLines indexLimit |
	args size = 0 ifTrue: [
		receiver ifNotNil: [ aStream space ].
		aStream nextPutAll: key.
		^ self ].
	keywords := key keywords.
	keywordsInSeparateLines := args size > 1 and: [ args anySatisfy: [ :a | a isComplex ] ].
	indexLimit := args size min: keywords size.
	1
		to: indexLimit
		do: [ :i |
			arg := args at: i.
			kwd := keywords at: i.
			(keywordsInSeparateLines and: [receiver notNil])
				ifTrue: [
					indent := 1.
					aStream newLineTab: level + 1.
					"newline after big args, explicit receiver (not a cascade)" ]
				ifFalse: [
					indent := 0.
					(keywordsInSeparateLines and: [i> 1])
						ifTrue: [
							"big args in a cascade, each keyword in a new line"
							aStream newLineTab: level ]
						ifFalse: [
							receiver ifNotNil: [ aStream space ]]].
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
			(i~=indexLimit and: [args size > 1 and: [ keywordsInSeparateLines not ]]) ifTrue: [ aStream space ]].! !

