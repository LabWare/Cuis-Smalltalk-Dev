'From Cuis7.7 [latest update: #7910] on 5 May 2026 at 4:24:22 pm'!

!ChangeSet methodsFor: 'change logging' stamp: 'jmv 4/May/2026 15:12:41'!
noteRecategorizationOfClass: aClass
	"Remember that a class has been changed its category."

	aClass wantsChangeSetLogging ifFalse: [^ self].
	self atClass: aClass add: #change.
	self addCoherency: aClass name.
	self hasUnsavedChanges: true! !

