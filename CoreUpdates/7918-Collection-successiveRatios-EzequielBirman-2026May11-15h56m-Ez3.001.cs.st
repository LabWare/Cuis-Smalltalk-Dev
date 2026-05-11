'From Cuis7.7 [latest update: #7917] on 11 May 2026 at 4:03:59 pm'!

!ArrayedCollection methodsFor: 'math functions' stamp: 'Ez3 11/May/2026 16:03:41'!
successiveRatios
	"
	#(10 12.5 15 20) successiveRatios
	"
    | displaced answer |
    displaced := self class new: self size.
    displaced replaceFrom: 2 to: self size with: self startingAt: 1.
    displaced at: 1 put: self first.
    answer := self copy. 

    ^answer / displaced! !


!ArrayedCollection methodsFor: 'math functions' stamp: 'jmv 5/Feb/2024 18:54:09'!
derivative
	"
	#(10 12.5 15 20) derivative
	#(10 12.5 15 20) derivative integral
	"
	| displaced answer |
	displaced := self class new: self size.
	displaced replaceFrom: 2 to: self size with: self startingAt: 1.
	displaced at: 1 put: self first - self first.	"Some reasonable zero"
	answer := self copy.
	answer -= displaced.
	^answer! !

!ArrayedCollection methodsFor: 'math functions' stamp: 'jmv 5/Feb/2024 18:54:52'!
integral
	"
	#(10 12.5 15 20) integral
	#(10 12.5 15 20) integral derivative
	"
	| answer |
	answer := self copy.
	2 to: answer size do: [ :i |
		answer at: i put: (answer at: i) + (answer at: i-1) ].
	^answer! !

