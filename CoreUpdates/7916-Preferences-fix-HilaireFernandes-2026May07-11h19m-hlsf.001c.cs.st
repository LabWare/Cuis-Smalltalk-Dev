'From Cuis7.7 [latest update: #7911] on 7 May 2026 at 11:57:52 am'!

!PreferenceSet class methodsFor: 'services' stamp: 'hlsf 7/May/2026 11:47:14'!
saveUserPrefs
	"
	PreferenceSet saveUserPrefs
	"
	| file |
	file := DirectoryEntry userBaseDirectory // 'UserPrefs.txt'.
	file forceWriteStreamDo: [ :stream |
		Preferences allPreferences keysAndValuesDo: [ :symbolName :preference |
			preference isSavedToDisk ifTrue: [
				stream
					nextPutAll: symbolName;
					nextPut: $=.
				(preference type = CharacterSequence and: [preference value isSymbol not])
					ifTrue: [stream nextPutAll: preference value]
					ifFalse:[preference value printOn: stream].
				stream newLine ]]].! !

