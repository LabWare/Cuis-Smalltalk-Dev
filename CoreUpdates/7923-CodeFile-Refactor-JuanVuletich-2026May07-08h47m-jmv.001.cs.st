'From Cuis7.7 [latest update: #7915] on 7 May 2026 at 8:52:10 am'!

!CodeFile methodsFor: 'private' stamp: 'jmv 7/May/2026 08:50:39'!
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
				^class perform: secondToken with: thirdToken.
		].
		(tokens size = 4 and: [ secondToken == #class and: [
			thirdToken == #removeSelector: ]]) ifTrue:[
				class := self getClass: firstToken.
				^class theMetaClass perform: thirdToken with: (tokens at: 4).
		].
	].
	doIts add: chgRec.! !


!CodeFile methodsFor: 'change record types' stamp: 'jmv 7/May/2026 08:49:56'!
doIt: chgRec
	"See senders of #doIt "
	| string |
	string := chgRec string.
	
	"Method classification spec"
	(string beginsWith: '(''') ifTrue: [
		^ doIts add: chgRec ].
		
	"Just for compatibility with Squeak, as Cuis always adds the #classDefinition change type marker in the files."
	('*ubclass:*instanceVariableNames:*classVariableNames:*poolDictionaries:*category:*'
		match: string) ifTrue:[^self classDefinition: string with: chgRec].

	"Just for compatibility with Squeak, as Cuis always adds the #classDefinition change type marker in the files."
	('* class*instanceVariableNames:*'
		match: string) ifTrue:[^self metaClassDefinition: string with: chgRec].

	"Just for compatibility with Squeak, as Cuis always adds the #methodRemoval: (or similar) change type marker in the files."
	('* removeSelector: *'
		match: string) ifTrue:[^self removedMethodSqueakCompatibility: string with: chgRec].

	"Just for compatibility with Squeak, as Cuis always adds the #classComment change type marker in the files."
	('* comment:*'
		match: string) ifTrue:[^self msgClassComment: string with: chgRec].

	"Don't add these to a CodeFile. They will be added on save if needed."
	('* initialize'
		match: string) ifTrue:[^self]. "Initialization is done based on class>>initialize"

	('''From *'
		match: string) ifTrue:[^self possibleSystemSource: chgRec].
	doIts add: chgRec.! !

!CodeFile methodsFor: 'private' stamp: 'jmv 7/May/2026 08:47:44'!
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
				^class perform: secondToken with: thirdToken.
		].
		(tokens size = 4 and: [ secondToken == #class and: [
			thirdToken == #removeSelector: or: [
			thirdToken == #removeSelectorIfInBaseSystem: ]]]) ifTrue:[
				class := self getClass: firstToken.
				^class theMetaClass perform: thirdToken with: (tokens at: 4).
		].
	].
	doIts add: chgRec.! !

