'From Cuis7.7 [latest update: #7934] on 14 May 2026 at 10:25:05 am'!

!ChangeSet methodsFor: 'change logging' stamp: 'jmv 14/May/2026 10:24:48'!
noteAddClassAndMethods: class
	"Include indication that a new class was created."

	| cr |
	class wantsChangeSetLogging ifFalse: [^ self].
	self atClass: class add: #new.
	self atClass: class add: #change.
	self addCoherency: class name.

	cr := self changeRecorderFor: class.
	class nonExtensionSelectorsDo: [ :selector |
		cr noteNewSelector: selector isNewMethod: false ].

	cr := self changeRecorderFor: class class.
	class class nonExtensionSelectorsDo: [ :selector |
		cr noteNewSelector: selector isNewMethod: false ].

	self hasUnsavedChanges: true.! !

