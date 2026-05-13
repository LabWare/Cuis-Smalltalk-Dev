'From Cuis7.7 [latest update: #7932] on 13 May 2026 at 1:44:24 pm'!

!ChangeSet methodsFor: 'change logging' stamp: 'jmv 13/May/2026 13:43:40'!
noteAddClassAndMethods: class
	"Include indication that a new class was created."

	| cr |
	class wantsChangeSetLogging ifFalse: [^ self].
	self atClass: class add: #new.
	self atClass: class add: #change.
	self addCoherency: class name.

	cr := self changeRecorderFor: class.
	class nonExtensionSelectorssDo: [ :selector |
		cr noteNewSelector: selector isNewMethod: false ].

	cr := self changeRecorderFor: class class.
	class class nonExtensionSelectorssDo: [ :selector |
		cr noteNewSelector: selector isNewMethod: false ].

	self hasUnsavedChanges: true.! !


!ChangeSet class methodsFor: 'system change notifications' stamp: 'jmv 12/May/2026 14:58:06'!
classRecategorized: aClass from: oldCategory to: newCategory
	"If the class was moved to a dfferent package, out of the base system, record the fact in the change set.
	The actual class redefinition is done at #classDefinitionChangedFrom:to: that is also called (if the class really changed)."

	| newPackageOrNil newChangeSet oldPackageOrNil oldChangeSet |

	aClass wantsChangeSetLogging ifFalse: [ ^self ].

	newPackageOrNil := CodePackage packageOfSystemCategory: newCategory ifNone: nil.
	newPackageOrNil ifNotNil: [ newPackageOrNil hasUnsavedChanges: true ].
	newChangeSet := ChangeSet changeSetForPackage: newPackageOrNil.
	
	oldPackageOrNil := CodePackage packageOfSystemCategory: oldCategory ifNone: nil.
	oldPackageOrNil == newPackageOrNil
		ifTrue: [newChangeSet noteRecategorizationOfClass: aClass.]
		ifFalse: [
			newChangeSet noteAddClassAndMethods: aClass.
			oldPackageOrNil ifNotNil: [ oldPackageOrNil hasUnsavedChanges: true ].
			oldChangeSet := ChangeSet changeSetForPackage: oldPackageOrNil.
			oldChangeSet noteClassMoveToOtherPackage: aClass ].! !

