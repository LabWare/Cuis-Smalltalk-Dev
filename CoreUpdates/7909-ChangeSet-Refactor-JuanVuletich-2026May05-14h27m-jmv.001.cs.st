'From Cuis7.7 [latest update: #7907] on 5 May 2026 at 2:42:19 pm'!

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 14:41:11'!
fileOutMovedClassesOn: stream

	| classRecords |
	classRecords := changeRecords values select: [ :aChangeRecord |
		aChangeRecord isClassMoveToOtherPackage ].
	classRecords := self sortedClassRecords: classRecords.
	classRecords do: [ :aMovedClassRecord |
		self fileOutClassDeletionFrom: aMovedClassRecord doItOnlyIfInBaseSystem: true on: stream ].! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 14:36:01'!
fileOutRemovedAndMovedMethodsOf: classList on: stream

	classList reverseDo: [ :aClass |
		self 
			fileOutMethodRemovalsOf: #(remove addedThenRemoved) 
			movedToOtherPackage: false
			for: aClass 
			on: stream.
		self 
			fileOutMethodRemovalsOf: #(movedToOtherPackage) 
			movedToOtherPackage: true
			for: aClass 
			on: stream.
		].! !

!ChangeSet methodsFor: 'fileIn/Out' stamp: 'jmv 5/May/2026 14:38:40'!
fileOutRemovedClassesOn: stream

	| classRecords |
	classRecords := changeRecords values select: [ :aChangeRecord |
		aChangeRecord isClassRemoval ].
	classRecords := self sortedClassRecords: classRecords.
	classRecords do: [ :aRemovedClassRecord | 
		self fileOutClassDeletionFrom: aRemovedClassRecord doItOnlyIfInBaseSystem: false on: stream ].! !

!methodRemoval: ChangeSet #movedClassRecords stamp: 'jmv 5/May/2026 14:31:58'!
ChangeSet removeSelector: #movedClassRecords!
!methodRemoval: ChangeSet #sortedRemovedClassRecords stamp: 'jmv 5/May/2026 14:30:51'!
ChangeSet removeSelector: #sortedRemovedClassRecords!
!methodRemoval: ChangeSet #sortedMovedClassesToOtherPackage stamp: 'jmv 5/May/2026 14:30:30'!
ChangeSet removeSelector: #sortedMovedClassesToOtherPackage!
!methodRemoval: ChangeSet #fileOutMethodRemovalsFor:on: stamp: 'jmv 5/May/2026 14:36:04'!
ChangeSet removeSelector: #fileOutMethodRemovalsFor:on:!
!methodRemoval: ChangeSet #fileOutRemovedClassRecord:on: stamp: 'jmv 5/May/2026 14:38:44'!
ChangeSet removeSelector: #fileOutRemovedClassRecord:on:!
!methodRemoval: ChangeSet #fileOutMethodMovedToOtherPackagesFor:on: stamp: 'jmv 5/May/2026 14:36:07'!
ChangeSet removeSelector: #fileOutMethodMovedToOtherPackagesFor:on:!
!methodRemoval: ChangeSet #removedClassRecords stamp: 'jmv 5/May/2026 14:32:43'!
ChangeSet removeSelector: #removedClassRecords!
!methodRemoval: ChangeSet #fileOutMovedClassRecord:on: stamp: 'jmv 5/May/2026 14:41:18'!
ChangeSet removeSelector: #fileOutMovedClassRecord:on:!
