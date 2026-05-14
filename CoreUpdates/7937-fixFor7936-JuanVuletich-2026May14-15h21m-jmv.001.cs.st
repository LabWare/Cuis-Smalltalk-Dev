'From Cuis7.7 [latest update: #7936] on 14 May 2026 at 3:23:53 pm'!

!Categorizer methodsFor: 'aux' stamp: 'jmv 14/May/2026 15:22:55'!
aboutToAddCategory: newCategory
	"Redefined as appropriate"! !


!SystemOrganizer methodsFor: 'aux' stamp: 'jmv 14/May/2026 15:23:03'!
aboutToAddCategory: newSystemCategory

	"If it looks like a new package makes sense, help the user by creating it."
	CodePackage maybeCreatePackageForSystemCategory: newSystemCategory.! !


!Categorizer methodsFor: 'accessing' stamp: 'jmv 14/May/2026 15:23:25'!
classify: element under: heading suppressIfDefault: aBoolean
	"Store the argument, element, in the category named heading.   If aBoolean is true, then invoke special logic such that the classification is NOT done if the new heading is the Default and the element already had a non-Default classification -- useful for filein"

	| catName catIndex elemIndex realHeading default |

	default := self class defaultCategory.

	realHeading := heading isNil
		ifTrue: [default]
		ifFalse: [heading withBlanksTrimmed ].

	"done if already under that category"
	(catName := self categoryOfElement: element) = realHeading ifTrue: [^ self].

	catName ifNotNil: [
		"return if non-Default category already assigned in memory"
		(aBoolean and: [realHeading = default]) ifTrue: [^ self].
		"remove if in another category"
		self removeElement: element].

	(categoryArray indexOf: realHeading) = 0 ifTrue: [
		self aboutToAddCategory: realHeading.
		self addCategory: realHeading ].

	catIndex := categoryArray indexOf: realHeading.
	elemIndex := catIndex > 1
		ifTrue: [categoryStops at: catIndex - 1]
		ifFalse: [0].
	[(elemIndex := elemIndex + 1) <= (categoryStops at: catIndex)
		and: [element >= (elementArray at: elemIndex)]] whileTrue.

	"elemIndex is now the index for inserting the element. Do the insertion before it."
	elementArray := elementArray copyReplaceFrom: elemIndex to: elemIndex-1 with: (Array with: element).

	"add one to stops for this and later categories"
	catIndex to: categoryArray size do: [ :i |
		categoryStops at: i put: (categoryStops at: i) + 1].

	(self listAtCategoryNamed: default) isEmpty ifTrue: [self removeCategory: default].! !


!Categorizer reorganize!
('accessing' addCategory: addCategory:before: allMethodSelectors categories categories: categoryOfElement: changeFromCategorySpecs: changeFromString: classify:under: classify:under:suppressIfDefault: classifyAll:under: elementCategoryDict initEmpty isEmptyCategoryNumber: listAtCategoryNamed: listAtCategoryNumber: moveCategoryBottom: moveCategoryDown: moveCategoryTop: moveCategoryUp: numberOfCategoryOfElement: removeCategory: removeElement: removeEmptyCategories renameCategory:to: sortCategories)
('printing' printCategory:at:with:on: printOn: printOn:excludingExtensions:)
('fileIn/Out' scanFrom:)
('private' elementArray firstIndexOfCategoryNumber: lastIndexOfCategoryNumber:)
('copying' postCopy)
('testing' hasAnyCategoriesSuchThat: isPackageCategoryExtension: isPackageCategoryExtension:fromPackage:)
('selectors' extensionSelectorsDo: nonExtensionSelectorsDo:)
('aux' aboutToAddCategory:)
!


!SystemOrganizer reorganize!
('fileIn/Out' fileOutAllCategories fileOutCategory: fileOutCategory:on:initializing: fileOutCategoryNoPoolsNoInit:on: objectForDataStream: superclassOrderIn:)
('remove' categoriesMatching: removeEmptySystemCategories removeMissingClasses removeSystemCategories: removeSystemCategory:)
('categories' allClassesAt: classesAt: fullListAtCategoryNamed: hasCategory: renameSystemCategory:to: rootCategoryOf: subCategoriesOf: subCategoriesPatternOf: superclassOrderInAll: testCaseClassesAt: withSubCategoriesOf:)
('source code management' classMethodCountOf: instanceMethodCountOf: linesOfCodeOf: messageSendsCountOf:)
('aux' aboutToAddCategory:)
!

