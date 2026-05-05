'From Cuis7.7 [latest update: #7907] on 5 May 2026 at 3:20:02 pm'!

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 14:47:01'!
aboutToRenameClass: aClass from: oldClassName to: newClassName inCategory: aCategoryName

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfSystemCategory: aCategoryName ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet noteRenameClass: aClass as: newClassName ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 14:49:06'!
classAdded: aClass inCategory: aCategoryName

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfSystemCategory: aCategoryName ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet noteAddClass: aClass ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 14:50:21'!
classCommented: aClass

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfClass: aClass ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet noteCommentClass: aClass ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 14:53:02'!
classDefinitionChangedFrom: oldClass to: newClass oldClassDefinition: oldClassDefinition
	"In case the class is moved from one package to another, both change sets should be affected.
	But there's no need to do it here, as #classRecategorized:from:to: is also called."

	| packageOrNil |
	newClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfClass: newClass ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		(newClass hasChangedComparedTo: oldClass) ifTrue: [ 
			changeSet noteChangeClass: newClass from: oldClass oldClassDefinition: oldClassDefinition ]].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 15:02:43'!
classRemoved: aClass fromCategory: aCategoryName

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfSystemCategory: aCategoryName ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet noteRemovalOf: aClass fromCategory: aCategoryName ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 15:05:33'!
classReorganized: aClass

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfClass: aClass ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet noteReorganizeClass: aClass ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 15:07:54'!
methodAdded: aCompiledMethod selector: aSymbol inProtocol: aCategoryName class: aClass methodTimeStamp: aTimeStampString requestor: requestor

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfMethod: aCompiledMethod methodReference ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet
			noteNewMethod: aCompiledMethod
			forClass: aClass
			selector: aSymbol
			priorMethod: nil ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 15:11:32'!
methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass requestor: requestor

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfMethod: newMethod methodReference ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet
			noteNewMethod: newMethod
			forClass: aClass
			selector: aSymbol
			priorMethod: oldMethod ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 15:15:02'!
methodRemoved: aCompiledMethod selector: aSymbol inProtocol: aCategoryName class: aClass

	| packageOrNil |
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	packageOrNil := CodePackage packageOfMethodCategory: aCategoryName ofClass: aClass ifNone: nil.
	(self changeSetForPackage: packageOrNil) ifNotNil: [ :changeSet |
		changeSet
			noteRemoveSelector: aSymbol
			class: aClass
			priorMethod: aCompiledMethod
			lastMethodInfo: {aCompiledMethod sourcePointer. aCategoryName} ].
	packageOrNil ifNotNil: [
		packageOrNil hasUnsavedChanges: true ].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 15:16:55'!
selectorRecategorized: selector from: oldCategory to: newCategory inClass: aClass
	"If the method was moved to a dfferent package, affect the package that lost the it. Tell it that it lost the method.
	The actual method redefinition is done at one of the method definition methods, that is also called."

	| newPackageOrNil newChangeSet oldPackageOrNil oldChangeSet |
	
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	
	newPackageOrNil := CodePackage packageOfMethodCategory: newCategory ofClass: aClass ifNone: nil.
	newPackageOrNil ifNotNil: [ newPackageOrNil hasUnsavedChanges: true ].
	newChangeSet := ChangeSet changeSetForPackage: newPackageOrNil.
	newChangeSet noteReorganizeClass: aClass.

	oldPackageOrNil := CodePackage packageOfMethodCategory: oldCategory ofClass: aClass ifNone: nil.
	oldPackageOrNil == newPackageOrNil ifFalse: [
		oldPackageOrNil ifNotNil: [ oldPackageOrNil hasUnsavedChanges: true ].
		oldChangeSet := ChangeSet changeSetForPackage: oldPackageOrNil.
		oldPackageOrNil
			ifNil: [
				"If destination is a package, but source isn't, then record the change in the base system changeset"
				oldChangeSet noteMethodMoveToOtherPackage: selector forClass: aClass ]].! !

!methodRemoval: ChangeSet #classRemoved:fromCategory: stamp: 'jmv 5/May/2026 15:04:48'!
ChangeSet removeSelector: #classRemoved:fromCategory:!
!methodRemoval: ChangeSet #classRecategorized:from:to: stamp: 'jmv 5/May/2026 15:00:55'!
ChangeSet removeSelector: #classRecategorized:from:to:!
!methodRemoval: ChangeSet #aboutToRenameClass:from:to:inCategory: stamp: 'jmv 5/May/2026 14:47:18'!
ChangeSet removeSelector: #aboutToRenameClass:from:to:inCategory:!
!methodRemoval: ChangeSet #methodChangedFrom:to:selector:inClass:requestor: stamp: 'jmv 5/May/2026 15:11:36'!
ChangeSet removeSelector: #methodChangedFrom:to:selector:inClass:requestor:!
!methodRemoval: ChangeSet #selectorRecategorized:from:to:inClass: stamp: 'jmv 5/May/2026 15:16:58'!
ChangeSet removeSelector: #selectorRecategorized:from:to:inClass:!
!methodRemoval: ChangeSet #classCommented: stamp: 'jmv 5/May/2026 14:50:24'!
ChangeSet removeSelector: #classCommented:!
!methodRemoval: ChangeSet #methodAdded:selector:inProtocol:class:methodTimeStamp:requestor: stamp: 'jmv 5/May/2026 15:07:56'!
ChangeSet removeSelector: #methodAdded:selector:inProtocol:class:methodTimeStamp:requestor:!
!methodRemoval: ChangeSet #classAdded:inCategory: stamp: 'jmv 5/May/2026 14:49:11'!
ChangeSet removeSelector: #classAdded:inCategory:!
!methodRemoval: ChangeSet #classDefinitionChangedFrom:to:oldClassDefinition: stamp: 'jmv 5/May/2026 14:53:08'!
ChangeSet removeSelector: #classDefinitionChangedFrom:to:oldClassDefinition:!
!methodRemoval: ChangeSet #methodRemoved:selector:inProtocol:class: stamp: 'jmv 5/May/2026 15:15:07'!
ChangeSet removeSelector: #methodRemoved:selector:inProtocol:class:!
!methodRemoval: ChangeSet #classReorganized: stamp: 'jmv 5/May/2026 15:05:40'!
ChangeSet removeSelector: #classReorganized:!

!ChangeSet reorganize!
('change logging' noteAddClass: noteChangeClass:from:oldClassDefinition: noteClassMoveToOtherPackage: noteMethodMoveToOtherPackage:forClass: noteNewMethod:forClass:selector:priorMethod: noteRecategorizationOfClass: noteRemoveSelector:class:priorMethod:lastMethodInfo: noteRenameClass:as:)
('accessing' author codePackage codePackage: editPostscript hasPostscript hasUnsavedChanges hasUnsavedChanges: isForBaseSystem isForBaseSystem: methodChanges methodInfoFromRemoval: name name: printOn: removePostscript sortedClassRecords:)
('testing' canHavePreambleAndPostscript isEmpty isMoribund isWithClass: okayToRemove)
('method changes' changedMessageList changedMessageListAugmented messageListForChangesWhich:ifNone: methodChangesAtClass: removeSelectorChanges:class: selectorsInClass:)
('class changes' changedClassCategories changedClassNames changedClasses classChangeAt: fatDefForClass: noteCommentClass: noteRemovalOf:fromCategory: noteReorganizeClass: trimHistory)
('moving changes' hasPreamble methodsWithAnyInitialsOtherThan: methodsWithInitialsOtherThan: methodsWithoutComments removeClassChanges: removePreamble)
('fileIn/Out' assurePostscriptExists assurePreambleExists checkForSlips fileOut fileOutClassDefinitionsOf:on: fileOutClassDeletionFrom:doItOnlyIfInBaseSystem:on: fileOutClassInitializationsOf:on: fileOutMethodAdditionsFor:on: fileOutMethodChangesFor:on: fileOutMethodRemovalOf:for:movedToOtherPackage:on:stamp: fileOutMethodRemovalsOf:movedToOtherPackage:for:on: fileOutMethodsAdditionsOf:on: fileOutMethodsChangesOf:on: fileOutMovedClassesOn: fileOutOn: fileOutPSFor:on: fileOutPostscriptOn: fileOutPreambleOn: fileOutRemovedAndMovedMethodsOf:on: fileOutRemovedClassesOn: objectForDataStream: postscriptString postscriptString: preambleString preambleString: preambleTemplate)
('private' addCoherency: atClass:add: atClass:includes: atSelector:class: changeRecorderFor: fileOutClassDefinition:on: oldNameFor:)
('initialization' clear initialize wither)
!

