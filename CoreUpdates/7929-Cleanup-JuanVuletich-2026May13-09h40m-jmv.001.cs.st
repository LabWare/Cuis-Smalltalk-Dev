'From Cuis7.7 [latest update: #7925] on 13 May 2026 at 9:48:29 am'!

!ClassDescription methodsFor: 'accessing method dictionary' stamp: 'jmv 13/May/2026 09:47:17'!
addAndClassifySelector: selector withMethod: compiledMethod inCategory: category methodTimeStamp: aTimeStampString
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
				inClass: self.
			category = priorCategoryOrNil ifFalse: [
				SystemChangeNotifier uniqueInstance
					selectorRecategorized: selector
					from: priorCategoryOrNil
					to: category
					inClass: self ]].! !


!ChangeSet methodsFor: 'change logging' stamp: 'jmv 13/May/2026 08:59:45'!
noteRemoveSelector: selector class: class lastMethodInfo: info
	"Include indication that a method has been forgotten.
	info is a pair of the source code pointer and message category
	for the method that was removed."

	class wantsChangeSetLogging ifFalse: [^ self].
	(self changeRecorderFor: class)
		noteRemoveSelector: selector lastMethodInfo: info.
	self hasUnsavedChanges: true.! !


!ClassChangeRecord methodsFor: 'method changes' stamp: 'jmv 13/May/2026 08:58:48'!
noteRemoveSelector: selector lastMethodInfo: infoOrNil

	| methodChange |
	methodChange := self findOrMakeMethodChangeAt: selector.
	methodChange changeType == #add
		ifTrue: [methodChange noteChangeType: #addedThenRemoved]
		ifFalse: [methodChange noteChangeType: #remove].

	infoOrNil ifNotNil:
		["Save the source code pointer and category so can still browse old versions"
		methodChange noteMethodInfoFromRemoval: infoOrNil].! !


!ClassDescription methodsFor: 'compiling' stamp: 'jmv 13/May/2026 08:54:34'!
compile: code classified: category withStamp: changeStamp libraryName: aStringOrNil notifying: requestor logSource: logSource
	
	| methodAndNode selector newMethod isExistingMethod updatedCode libName |
	methodAndNode := self basicCompile: code notifying: requestor 
							trailer: self defaultMethodTrailer ifFail: [^nil].
	selector := methodAndNode selector.
	newMethod := methodAndNode method.
	libName := aStringOrNil.
	isExistingMethod := self includesSelector: selector.
	isExistingMethod
		ifTrue: [
			(self theNonMetaClass isOkToChangeMethod: selector isMeta: self isMeta)
				ifFalse: [self error: 'Method modification not allowed'].
			"If libraryName is provided, it takes precedence. If not, assume it doesn't change."
			libName isNil ifTrue: [ libName := (self compiledMethodAt: selector) propertyValueAt: #libraryName ]]
		ifFalse: [
			(self theNonMetaClass isOkToAddMethod: selector isMeta: self isMeta)
				ifFalse: [self error: 'Method addition not allowed']].
	libName ifNotNil: [ newMethod propertyValueAt: #libraryName put: libName ].
	logSource ifTrue: [
		"Re-fetching source code may be needed if, for example, some variable declaration was corrected during compilation."
		updatedCode := CodeProvider normalizeCodeForSaving: (requestor ifNil: [code] ifNotNil: [requestor text]) in: self.
		self logMethodSource: updatedCode forMethodWithNode: methodAndNode 
			inCategory: category withStamp: changeStamp libraryName: libName
			notifying: requestor.
	].
	self addAndClassifySelector: selector withMethod: newMethod
		inCategory: category methodTimeStamp: changeStamp.
	^ selector! !


!SystemChangeNotifier methodsFor: 'system triggers' stamp: 'jmv 13/May/2026 08:51:09'!
methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass

	self
		triggerEvent: #methodChanged
		withArguments: { oldMethod . newMethod . aSymbol . aClass }.! !


!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 13/May/2026 08:59:51'!
methodRemoved: aCompiledMethod selector: aSymbol inProtocol: aCategoryName class: aClass

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfMethodCategory: aCategoryName ofClass: aClass ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet
			noteRemoveSelector: aSymbol
			class: aClass
			lastMethodInfo: {aCompiledMethod sourcePointer. aCategoryName} ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!methodRemoval: ClassChangeRecord #noteRemoveSelector:priorMethod:lastMethodInfo: stamp: 'jmv 13/May/2026 09:43:20'!
ClassChangeRecord removeSelector: #noteRemoveSelector:priorMethod:lastMethodInfo:!
!methodRemoval: ChangeSet #noteRemoveSelector:class:priorMethod:lastMethodInfo: stamp: 'jmv 13/May/2026 09:43:15'!
ChangeSet removeSelector: #noteRemoveSelector:class:priorMethod:lastMethodInfo:!
!methodRemoval: ClassDescription #addAndClassifySelector:withMethod:inCategory:methodTimeStamp:notifying: stamp: 'jmv 13/May/2026 09:47:50'!
ClassDescription removeSelector: #addAndClassifySelector:withMethod:inCategory:methodTimeStamp:notifying:!
