'From Cuis7.7 [latest update: #7925] on 13 May 2026 at 10:39:42 am'!

!SystemChangeNotifier methodsFor: 'system triggers' stamp: 'jmv 13/May/2026 10:29:04'!
methodAdded: aMethod selector: aSymbol inProtocol: aCategoryName class: aClass methodTimeStamp: aTimeStampString
	"A method with the given selector was added to aClass in protocol aCategoryName."

	self
		triggerEvent: #methodAddedInProtocolTimeStamp
		withArguments: { aMethod . aSymbol . aCategoryName . aClass . aTimeStampString }! !

!SystemChangeNotifier methodsFor: 'system triggers' stamp: 'jmv 13/May/2026 10:26:58'!
methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass

	self
		triggerEvent: #methodChanged
		withArguments: { oldMethod . newMethod . aSymbol . aClass }.! !


!SmalltalkCompleter class methodsFor: 'class initialization' stamp: 'jmv 13/May/2026 10:39:00'!
initializeNotifications
	"
	SmalltalkCompleter initializeNotifications
	"
	
	SystemChangeNotifier uniqueInstance
		removeActionsWithReceiver: self.	 "avoid double registration"

	SystemChangeNotifier uniqueInstance
		when: #classRemoved send: #classRemoved:fromCategory: to: self;
		when: #methodAddedInProtocolTimeStamp send: #methodAdded:selector:inProtocol:class:methodTimeStamp: to: self;
		when: #methodRemoved send: #methodRemoved:selector:inProtocol:class: to: self.! !

!SmalltalkCompleter class methodsFor: 'system change notifications' stamp: 'jmv 13/May/2026 10:29:49'!
methodAdded: aMethod selector: aSymbol inProtocol: aCategoryName class: aClass methodTimeStamp: aTimeStampString

	self addSelector: aSymbol method: aMethod
		methodTimeStamp: aTimeStampString updateSortingOfSentMessages: true.! !


!ChangeSet methodsFor: 'change logging' stamp: 'jmv 13/May/2026 08:57:22'!
noteNewMethodForClass: class selector: selector isNewMethod: aBoolean

	class wantsChangeSetLogging ifFalse: [^ self].
	(self changeRecorderFor: class)
		noteNewSelector: selector isNewMethod: aBoolean.
	self hasUnsavedChanges: true.! !


!ChangeSet class methodsFor: 'class initialization' stamp: 'jmv 13/May/2026 10:37:51'!
initializeNotifications
	"
	ChangeSet initializeNotifications
	"

	"Avoid double registration"
	SystemChangeNotifier uniqueInstance removeActionsWithReceiver: self.
	SystemChangeNotifier uniqueInstance
		when: #classAdded send: #classAdded:inCategory: to: self;
		when: #classCommented send: #classCommented: to: self;
		when: #classDefinitionChanged send: #classDefinitionChangedFrom:to:oldClassDefinition: to: self;
		when: #classRecategorized send: #classRecategorized:from:to: to: self;
		when: #classRemoved send: #classRemoved:fromCategory: to: self;
		when: #aboutToRenameClass send: #aboutToRenameClass:from:to:inCategory: to: self;
		when: #classReorganized send: #classReorganized: to: self;
		when: #methodAddedInProtocolTimeStamp send: #methodAdded:selector:inProtocol:class:methodTimeStamp: to: self;
		when: #methodChanged send: #methodChangedFrom:to:selector:inClass: to: self;
		when: #methodRemoved send: #methodRemoved:selector:inProtocol:class: to: self;
		when: #selectorRecategorized send: #selectorRecategorized:from:to:inClass: to: self.! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 13/May/2026 09:37:58'!
methodAdded: aCompiledMethod selector: aSymbol inProtocol: aCategoryName class: aClass methodTimeStamp: aTimeStampString

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfMethod: aCompiledMethod methodReference ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet
			noteNewMethodForClass: aClass
			selector: aSymbol
			isNewMethod: true ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 13/May/2026 09:38:15'!
methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfMethod: newMethod methodReference ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet
			noteNewMethodForClass: aClass
			selector: aSymbol
			isNewMethod: false ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !


!ClassChangeRecord methodsFor: 'method changes' stamp: 'jmv 12/May/2026 19:22:09'!
findOrMakeMethodChangeAt: selector

	^ methodChanges 
		at: selector
		ifAbsentPut: [MethodChangeRecord new]! !

!ClassChangeRecord methodsFor: 'method changes' stamp: 'jmv 13/May/2026 08:56:49'!
noteNewSelector: selector isNewMethod: aBoolean

	| methodChange |
	methodChange := self findOrMakeMethodChangeAt: selector.
	aBoolean
		ifTrue: [ methodChange noteChangeType: #add ]
		ifFalse: [ methodChange noteChangeType: #change ].! !


!ClassDescription methodsFor: 'accessing method dictionary' stamp: 'jmv 13/May/2026 10:30:45'!
addAndClassifySelector: selector withMethod: compiledMethod inCategory: category methodTimeStamp: aTimeStampString notifying: requestor
	| priorMethodOrNil priorCategoryOrNil |
	priorMethodOrNil := self compiledMethodAt: selector ifAbsent: nil.
	priorCategoryOrNil := self whichCategoryIncludesSelector: selector.
	self addSelectorSilently: selector withMethod: compiledMethod.
	SystemChangeNotifier uniqueInstance doSilently: [self organization classify: selector under: category].
	priorMethodOrNil
		ifNil: [
			SystemChangeNotifier uniqueInstance 
				methodAdded: compiledMethod
				selector: selector
				inProtocol: category
				class: self
				methodTimeStamp: aTimeStampString ]
		ifNotNil: [
			SystemChangeNotifier uniqueInstance 
				methodChangedFrom: priorMethodOrNil 
				to: compiledMethod 
				selector: selector 
				inClass: self .
			category = priorCategoryOrNil ifFalse: [
				SystemChangeNotifier uniqueInstance
					selectorRecategorized: selector
					from: priorCategoryOrNil
					to: category
					inClass: self ]].! !


!SmalltalkCompleter class methodsFor: 'class initialization' stamp: 'jmv 13/May/2026 10:39:29'!
initialize
	"
	It takes about 6 seconds, mostly because of the time to fetch method stamps from source files...
	[ SmalltalkCompleter initialize ]timeToRun
	Selectors inspect
	"
	| maxSortValue |
	
	EntriesLimit := 100.
	
	SmalltalkCompleter initializeNotifications.
	
	self protected: [
		Selectors := Trie new.
		"
		Smalltalk allBehaviorsDo: [:class |
			class selectorsAndMethodsDo: [ :sel :method |
				Selectors at: sel ifAbsentPut: [ 0 ].
				method messages do: [ :sentMsg |
					Selectors at: sentMsg put: (Selectors at: sentMsg ifAbsent: [ 0 ]) + 1 ]]].
		"
		Smalltalk allBehaviorsDo: [:class |
			class selectorsAndMethodsDo: [ :sel :method |
				self addSelector: sel method: method
					methodTimeStamp: method authorAndStamp updateSortingOfSentMessages: false ]].
		""
	
		"The following might not be found in #messages. Give them maximum priority."
		maxSortValue := SmallInteger maxVal.
		"From MessageNode>>#initialize"
		#(	ifTrue: ifFalse: ifTrue:ifFalse: ifFalse:ifTrue:
			and: or:
			whileFalse: whileTrue: whileFalse whileTrue
			to:do: to:by:do:
			caseOf: caseOf:otherwise:
			ifNil: ifNotNil:  ifNil:ifNotNil: ifNotNil:ifNil:) do: [ :sel |
				Selectors at: sel put: maxSortValue ].
	
		maxSortValue := SmallInteger maxVal-1.
		"From SystemDictionary >>#recreateSpecialObjectsArray"
		(1 to: Smalltalk specialSelectorSize) do:  [ :i | | sym |
			sym := Smalltalk specialSelectorAt: i.
			(Selectors includesKey: sym)
				ifTrue: [ Selectors at: sym put: maxSortValue ]]].! !


!ChangeSet class methodsFor: 'class initialization' stamp: 'jmv 13/May/2026 10:37:41'!
initialize
	"
	ChangeSet initialize
	"
	AllChangeSets := OrderedCollection new.
	ChangeSet initializeNotifications.! !

SmalltalkCompleter initializeNotifications!
ChangeSet initializeNotifications!
