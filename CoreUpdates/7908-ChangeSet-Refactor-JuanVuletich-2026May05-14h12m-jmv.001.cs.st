'From Cuis7.7 [latest update: #7907] on 5 May 2026 at 2:27:48 pm'!

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 14:16:16'!
classRecategorized: aClass from: oldCategory to: newCategory
	"If the class was moved to a dfferent package, out of the base system, record the fact in the change set.
	The actual class redefinition is done at #classDefinitionChangedFrom:to: that is also called (if the class really changed)."

	| newPackageOrNil newChangeSet oldPackageOrNil oldChangeSet |

	aClass wantsChangeSetLogging ifFalse: [ ^self ].

	newPackageOrNil := CodePackage packageOfSystemCategory: newCategory ifNone: nil.
	newPackageOrNil ifNotNil: [ newPackageOrNil hasUnsavedChanges: true ].
	newChangeSet := ChangeSet changeSetForPackage: newPackageOrNil.
	newChangeSet noteRecategorizationOfClass: aClass.

	oldPackageOrNil := CodePackage packageOfSystemCategory: oldCategory ifNone: nil.
	oldPackageOrNil == newPackageOrNil ifFalse: [
		oldPackageOrNil ifNotNil: [ oldPackageOrNil hasUnsavedChanges: true ].
		oldChangeSet := ChangeSet changeSetForPackage: oldPackageOrNil.
		oldPackageOrNil
			ifNil: [
				"If destination is a package, but source isn't, then record the change in the base system changeset"
				oldChangeSet noteClassMoveToOtherPackage: aClass ]].! !

!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 5/May/2026 14:25:03'!
selectorRecategorized: selector from: oldCategory to: newCategory inClass: aClass
	"If the method was moved to a dfferent package, affect the package that lost the it. Tell it that it lost the method.
	The actual method redefinition is done at one of the method definition methods, that is also called."

	| newPackageOrNil newChangeSet oldPackageOrNil oldChangeSet |
	
	aClass wantsChangeSetLogging ifFalse: [ ^self ].
	
	newPackageOrNil := CodePackage packageOfMethodCategory: newCategory ofClass: aClass ifNone: nil.
	newPackageOrNil ifNotNil: [ newPackageOrNil hasUnsavedChanges: true ].
	newChangeSet := ChangeSet changeSetForPackage: newPackageOrNil.
	"newChangeSet selectorRecategorized: selector from: oldCategory to: newCategory inClass: aClass."
	newChangeSet noteReorganizeClass: aClass.

	oldPackageOrNil := CodePackage packageOfMethodCategory: oldCategory ofClass: aClass ifNone: nil.
	oldPackageOrNil == newPackageOrNil ifFalse: [
		oldPackageOrNil ifNotNil: [ oldPackageOrNil hasUnsavedChanges: true ].
		oldChangeSet := ChangeSet changeSetForPackage: oldPackageOrNil.
		oldPackageOrNil
			ifNil: [
				"If destination is a package, but source isn't, then record the change in the base system changeset"
				oldChangeSet noteMethodMoveToOtherPackage: selector forClass: aClass ]].! !

