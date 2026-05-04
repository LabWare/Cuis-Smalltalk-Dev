'From Cuis7.7 [latest update: #7903] on 4 May 2026 at 11:45:59 am'!

!ChangeListElement methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:16'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	self subclassResponsibility! !


!ClassCommentChange methodsFor: 'initialization' stamp: 'jmv 4/May/2026 11:18:18'!
fileIn
	"File the receiver in.  Apply the change.  Update the class comment."

	(Smalltalk at: class)
		comment: self text
		stamp: stamp.! !

!ClassCommentChange methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:22'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile classComment: self! !


!ClassDefinitionChange methodsFor: 'initialization' stamp: 'jmv 4/May/2026 11:18:35'!
fileIn
	"File the receiver in.  Apply the change.  (Re)Define the class."

	Compiler evaluate: self string.! !

!ClassDefinitionChange methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:25'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile classDefinition: self! !


!ClassDeletionChange methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:28'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile classRemoval: self! !


!ClassRenamedChange methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:35'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile classRenamed: self! !


!FeatureProvidesRecord methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:39'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile provides: self! !


!FeatureRequiresRecord methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:42'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile requires: self! !


!MethodDefinitionChange methodsFor: 'initialization' stamp: 'jmv 4/May/2026 11:18:55'!
fileIn
	"File the receiver in.  Apply the change.  Define the method."

	self changeClass ifNotNil: [ :methodClass |
		methodClass
			compile: self text
			classified: category
			withStamp: stamp
			libraryName: libraryName
			notifying: nil ].! !

!MethodDefinitionChange methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:47'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile method: self! !


!MethodDeletionChange methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:51'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	^aCodeFile removedMethod: self command with: self ! !


!PreambleRecord methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:53'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile preamble: self! !


!UnspecificRecord methodsFor: 'initialization' stamp: 'jmv 4/May/2026 11:19:16'!
fileIn
	"File the receiver in.  Evaluate the DoIt."

	| s |
	((s := self string) beginsWith: '----') ifFalse: [
		Compiler evaluate: s ].! !

!UnspecificRecord methodsFor: 'perform' stamp: 'jmv 4/May/2026 11:20:56'!
addToCodeFile: aCodeFile
	"Part of building a CodeFile object to represent changes and show them in a CodeFileBrowser."

	 ^aCodeFile doIt: self! !

