'From Cuis7.7 [latest update: #7925] on 13 May 2026 at 9:31:10 am'!

!ClassChangeRecord methodsFor: 'method changes' stamp: 'jmv 13/May/2026 09:28:47'!
atSelector: selector put: changeType

	(self findOrMakeMethodChangeAt: selector)
		noteChangeType: changeType! !

!ClassChangeRecord methodsFor: 'method changes' stamp: 'jmv 12/May/2026 19:22:29'!
noteMethodMoveToOtherPackage: selector

	| methodChange |
	methodChange := self findOrMakeMethodChangeAt: selector.
	methodChange noteChangeType: #movedToOtherPackage.! !

!ClassChangeRecord methodsFor: 'method changes' stamp: 'jmv 13/May/2026 09:28:37'!
noteNewMethod: newMethod selector: selector priorMethod: methodOrNil

	| methodChange |
	methodChange := self findOrMakeMethodChangeAt: selector.
	methodOrNil
		ifNil: [ methodChange noteChangeType: #add ]
		ifNotNil: [ methodChange noteChangeType: #change ].! !

!ClassChangeRecord methodsFor: 'method changes' stamp: 'jmv 13/May/2026 09:28:58'!
noteRemoveSelector: selector priorMethod: priorMethod lastMethodInfo: infoOrNil

	| methodChange |
	methodChange := self findOrMakeMethodChangeAt: selector.
	methodChange changeType == #add
		ifTrue: [methodChange noteChangeType: #addedThenRemoved]
		ifFalse: [methodChange noteChangeType: #remove].

	infoOrNil ifNotNil:
		["Save the source code pointer and category so can still browse old versions"
		methodChange noteMethodInfoFromRemoval: infoOrNil]

! !

!methodRemoval: ClassChangeRecord #findOrMakeMethodChangeAt:priorMethod: stamp: 'jmv 13/May/2026 09:29:06'!
ClassChangeRecord removeSelector: #findOrMakeMethodChangeAt:priorMethod:!
