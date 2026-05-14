'From Cuis7.7 [latest update: #7936] on 14 May 2026 at 12:07:17 pm'!

!Categorizer methodsFor: 'accessing' stamp: 'jmv 14/May/2026 11:54:34'!
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
		"If it looks like a new package makes sense, help the user by creating it."
		CodePackage maybeCreatePackageForSystemCategory: realHeading.
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


!CodePackage class methodsFor: 'packages access' stamp: 'jmv 14/May/2026 12:05:03'!
maybeCreatePackageForSystemCategory: newSystemCategory
	"If newSystemCategory doesn't belong in an existing system category or package,
	create a new package for it."

	| inferredPackageName |
	inferredPackageName := newSystemCategory copyUpTo: $-.
	(SystemOrganization hasAnyCategoriesSuchThat: [ :eachCat |
		(inferredPackageName = eachCat) or: [
			inferredPackageName, '-*' match: eachCat ]]) ifFalse: [
				CodePackage named: inferredPackageName createIfAbsent: true registerIfNew: true ].! !

