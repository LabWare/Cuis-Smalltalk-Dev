'From Cuis7.7 [latest update: #7890] on 1 May 2026 at 10:27:17 am'!

!Preference methodsFor: 'initialization' stamp: 'hlsf 1/May/2026 10:24:52'!
name: nameSymbol description: aString category: categorySymbol type: aType value: aValue
	name := nameSymbol.
	description := aString.
	category := categorySymbol.
	type :=	aType 
		ifNotNil: [aType] 
		ifNil: [type ifNil: [self class detectType: aValue ]].
	value := aValue! !

