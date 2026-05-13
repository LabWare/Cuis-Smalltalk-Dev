'From Cuis7.7 [latest update: #7932] on 13 May 2026 at 1:39:39 pm'!

!ClassDescription methodsFor: 'accessing method dictionary' stamp: 'jmv 13/May/2026 13:36:45'!
extensionSelectorsDo: aBlock
	"
	False extensionSelectorsDo: [ :selector :package | {selector. package} print ].
	False class extensionSelectorsDo: [ :selector :package | {selector. package} print ].
	Try again after installing, for instance, the JSON.pck.st package, that extends False
	"
	self organization extensionSelectorsDo: aBlock.! !

!ClassDescription methodsFor: 'accessing method dictionary' stamp: 'jmv 13/May/2026 13:37:15'!
nonExtensionSelectorsDo: aBlock
	"
	False nonExtensionSelectorsDo: [ :selector | selector print ].
	False class nonExtensionSelectorsDo: [ :selector | selector print ].
	Try again after installing, for instance, the JSON.pck.st package, that extends False
	"
	self organization nonExtensionSelectorsDo: aBlock.! !


!Categorizer methodsFor: 'selectors' stamp: 'jmv 13/May/2026 13:34:24'!
extensionSelectorsDo: aBlock
	"
	False organization extensionSelectorsDo: [ :selector :package | {selector. package} print ].
	False class organization extensionSelectorsDo: [ :selector :package | {selector. package} print ].
	Try again after installing, for instance, the JSON.pck.st package, that extends False
	"
	| firstIndex lastIndex |
	elementArray ifNil: [^ self].
	1 to: categoryStops size do: [ :cat |
		(CodePackage packageOfExtensionMethodCategory: (categoryArray at: cat))
			ifNotNil: [ :package |
				firstIndex := self firstIndexOfCategoryNumber: cat.
				lastIndex := self lastIndexOfCategoryNumber: cat.
				firstIndex to: lastIndex do: [ :el |
					aBlock value: (elementArray at: el) value: package ]]].! !

!Categorizer methodsFor: 'selectors' stamp: 'jmv 13/May/2026 13:34:11'!
nonExtensionSelectorsDo: aBlock
	"
	False organization nonExtensionSelectorsDo: [ :selector | selector print ].
	False class organization nonExtensionSelectorsDo: [ :selector | selector print ].
	Try again after installing, for instance, the JSON.pck.st package, that extends False
	"
	| firstIndex lastIndex |
	elementArray ifNil: [^ self].
	1 to: categoryStops size do: [ :cat |
		(CodePackage packageOfExtensionMethodCategory: (categoryArray at: cat))
			ifNil: [
				firstIndex := self firstIndexOfCategoryNumber: cat.
				lastIndex := self lastIndexOfCategoryNumber: cat.
				firstIndex to: lastIndex do: [ :el |
					aBlock value: (elementArray at: el) ]]].! !


!CodePackage class methodsFor: 'searching' stamp: 'jmv 13/May/2026 13:21:18'!
packageOfExtensionMethodCategory: aMethodCategory

	InstalledPackages ifNil: [ ^nil].
	^ InstalledPackages
		detect: [:ea | ea isYourClassExtension: aMethodCategory]
		ifNone: nil! !


!ClassDescription reorganize!
('accessing' classVersion comment comment: comment:stamp: hasComment instVarNames localBindingOf: smalltalkComment theMetaClass theNonMetaClass)
('accessing class hierarchy' classesThatImplementAllOf: removeUninstantiatedSubclassesSilently subclasses)
('accessing method dictionary' addAndClassifySelector:withMethod:inCategory:methodTimeStamp: allMethodCategoriesIntegratedThrough: allMethodsInCategory: extensionSelectorsDo: induceMDFault methodCategories methodCategoriesAsSortedCollection nonExtensionSelectorsDo: recordedChangesForSelector: recoverFromMDFault recoverFromMDFaultWithTrace removeCategory: removeSelector: removeSelector:ifIn: selectorsInCategory:)
('accessing variables' allUnreferencedInstanceVariables)
('class variables' classPool)
('compiling' acceptsLoggingOfCompilation compile:classified: compile:classified:notifying: compile:classified:withStamp:libraryName:notifying: compile:classified:withStamp:libraryName:notifying:logSource: compile:classified:withStamp:notifying: compile:notifying: compileSilently:classified: compileSilently:classified:notifying: instVarNamesAndOffsetsDo: isOkToAddMethod:isMeta: isOkToChangeMethod:isMeta: isOkToRemoveMethod:isMeta: wantsChangeSetLogging wantsRecompilationProgressReported)
('copying' copy:from: copy:from:classified: copyAll:from: copyAll:from:classified: copyAllCategoriesFrom: copyCategory:from: copyCategory:from:classified: copyMethodDictionaryFrom:)
('fileIn/Out' classComment: classComment:stamp: commentStamp: commentStamp:prior: definition definitionPreamble definitionPreambleWithoutStamp fileOutCategory: fileOutCategory:on:moveSource:toFile: fileOutChangedMessages:on: fileOutChangedMessages:on:moveSource:toFile: fileOutMethod: fileOutOn: fileOutOn:moveSource:toFile: fileOutOn:moveSource:toFile:initializing:sortMethodsByCategory: fileOutOrganizationOn: fileOutOrganizationOn:excludingExtensions: methods methodsFor: methodsFor:library:stamp: methodsFor:library:stamp:prior: methodsFor:stamp: methodsFor:stamp:prior: moveChangesTo: printCategoryChunk:on:withStamp:libraryName:priorMethod: printMethodChunk:withPreamble:on:moveSource:toFile: putClassCommentToCondensedChangesFile: reformatAll reformatMethodAt: reorganize)
('initialization' canUpdateFrom: doneCompiling organization: setInstVarNames: superclass:methodDictionary:format:)
('initialize-release' updateInstances:from:isMeta: updateMethodBindingsTo:)
('instance variables' addInstVarName: allInstVarNamesEverywhere browseClassVarRefs checkForInstVarsOK: chooseClassVarName chooseDefiningInstanceVariableAlphabeticallyWith:thenDo: chooseDefiningInstanceVariableAlphabeticallyWith:thenDo:ifNone: chooseInstVarAlphabeticallyThenDo: chooseInstVarThenDo: classThatDefinesClassVariable: classThatDefinesInstanceVariable: forceNewFrom: instVarNameForIndex: removeInstVarName: withClassesThatDefineInHierarchyInstanceVariable:do:ifNone: withSubclassesThatDefineInstanceVariable:do:ifNone:)
('organization' category category: organization whichCategoryIncludesSelector: zapOrganization)
('printing' classVariablesString instanceVariablesString printNameOn: printWithClosureAnalysisOn: sharedPoolsString storeOn:)
('release' obsolete)
('source code management' linesOfCode messageSendsCount messageSendsCountInCategory: messagesCountInCategory:)
('system-support' allUnreferencedClassVariables)
('testing' hasDefinition)
('private' errorCategoryName instVarMappingFrom: logMethodSource:forMethodWithNode:inCategory:withStamp:libraryName:notifying: newInstanceFrom:variable:size:map:)
('[mk] printing' printOn:)
!


!Categorizer reorganize!
('accessing' addCategory: addCategory:before: allMethodSelectors categories categories: categoryOfElement: changeFromCategorySpecs: changeFromString: classify:under: classify:under:suppressIfDefault: classifyAll:under: elementCategoryDict initEmpty isEmptyCategoryNumber: listAtCategoryNamed: listAtCategoryNumber: moveCategoryBottom: moveCategoryDown: moveCategoryTop: moveCategoryUp: numberOfCategoryOfElement: removeCategory: removeElement: removeEmptyCategories renameCategory:to: sortCategories)
('printing' printCategory:at:with:on: printOn: printOn:excludingExtensions:)
('fileIn/Out' scanFrom:)
('private' elementArray firstIndexOfCategoryNumber: lastIndexOfCategoryNumber:)
('copying' postCopy)
('testing' hasAnyCategoriesSuchThat: isPackageCategoryExtension: isPackageCategoryExtension:fromPackage:)
('selectors' extensionSelectorsDo: nonExtensionSelectorsDo:)
!

