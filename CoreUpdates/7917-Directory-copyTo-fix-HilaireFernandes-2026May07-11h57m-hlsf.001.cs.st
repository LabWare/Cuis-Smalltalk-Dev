'From Cuis7.7 [latest update: #7911] on 8 May 2026 at 10:51:11 am'!

!DirectoryEntry methodsFor: 'actions-directory' stamp: 'hlsf 8/May/2026 10:48:11'!
copyTo: filename

	| toDir |
	filename asFileEntry exists ifTrue: [^self error: 'Cannot copy directory to file'].

	toDir := filename asDirectoryEntry assureExistence.

	self
		filesDo: [:file | file copyTo: (toDir / file name) pathName].

	self
		directoriesDo: [ :dir |
			dir copyTo:  (toDir / dir name) pathName].! !

