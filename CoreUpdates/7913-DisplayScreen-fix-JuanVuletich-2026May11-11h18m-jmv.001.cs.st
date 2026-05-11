'From Cuis7.7 [latest update: #7912] on 11 May 2026 at 11:21:20 am'!

!Form methodsFor: 'accessing' stamp: 'jmv 11/May/2026 11:18:59'!
answerClass
	"The class to answer instances of."

	^self class! !


!DisplayScreen methodsFor: 'accessing' stamp: 'jmv 11/May/2026 11:19:31'!
answerClass
	"The class to answer instances of.
	Answering instances of DisplayScreen is usually not what you want."

	^Form! !


!Form methodsFor: 'copying' stamp: 'jmv 11/May/2026 11:20:04'!
blankCopyOf: aRectangle scaledBy: scale

        ^ self answerClass extent: (aRectangle extent * scale) truncated depth: depth! !

!Form methodsFor: 'copying' stamp: 'jmv 11/May/2026 11:20:08'!
copy: aRect
 	"Return a new form which derives from the portion of the original form delineated by aRect."
	| newForm |
	newForm := self answerClass extent: aRect extent depth: depth.
	^ newForm copyBits: aRect from: self at: `0@0`
		clippingBox: newForm boundingBox rule: Form over! !

!Form methodsFor: 'scaling, rotation' stamp: 'jmv 11/May/2026 11:20:32'!
flippedBy: direction
	"Return a copy of the receiver flipped either #vertical, #horizontal or #both. (#both is a 180 degrees rotation)
	ImageMorph defaultForm display.
	(ImageMorph defaultForm flippedBy: #vertical) display.
	(ImageMorph defaultForm flippedBy: #horizontal) display.
	(ImageMorph defaultForm flippedBy: #both) display.
	"
	| newForm quad |
	newForm := self answerClass extent: self extent depth: depth.
	quad := self boundingBox innerCorners.
	quad := (
		direction caseOf: {
			[ #vertical ] 		-> [#(2 1 4 3)].
			[ #horizontal ] 		-> [#(4 3 2 1)].
			[ #both ] 			-> [#(3 4 1 2)]})
		collect: [:i | quad at: i].
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		combinationRule: 3;
		copyQuad: quad toRect: newForm boundingBox.
"	newForm offset: (self offset flippedBy: direction centerAt: aPoint)."
	^ newForm
"
[Sensor isAnyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor mousePoint extent: 130@66))
			flippedBy: #vertical centerAt: 0@0) display]
"
"Consistency test...
 | f f2 p |
[ Sensor isAnyButtonPressed ] whileFalse: [
	f := Form fromDisplay: ((p := Sensor mousePoint) extent: 31@41).
	Display fillBlack: (p extent: 31@41).
	f2 := f flippedBy: #vertical centerAt: 0@0.
	(f2 flippedBy: #vertical centerAt: 0@0) displayAt: p ]
"! !

!Form methodsFor: 'scaling, rotation' stamp: 'jmv 11/May/2026 11:20:38'!
rotated180Degrees
	"Return a copy of the receiver rotated by 180 degrees.
	ImageMorph defaultForm display.
	ImageMorph defaultForm rotated90Degrees display.
	ImageMorph defaultForm rotated180Degrees display.
	ImageMorph defaultForm rotated270Degrees display.
	"
	| newForm quad |
	newForm := self answerClass extent: self extent depth: depth.
	quad := self boundingBox innerCorners.
	quad := #(3 4 1 2)		collect: [:i | quad at: i].
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		combinationRule: 3;
		copyQuad: quad toRect: newForm boundingBox.
	^ newForm! !

!Form methodsFor: 'scaling, rotation' stamp: 'jmv 11/May/2026 11:20:41'!
rotated270Degrees
	"Return a copy of the receiver rotated by 270 degrees.
	ImageMorph defaultForm display.
	ImageMorph defaultForm rotated90Degrees display.
	ImageMorph defaultForm rotated180Degrees display.
	ImageMorph defaultForm rotated270Degrees display.
	"
	| newForm quad |
	newForm := self answerClass extent: self extent transposed depth: depth.
	quad := self boundingBox innerCorners.
	quad := #(4 1 2 3)		collect: [:i | quad at: i].
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		combinationRule: 3;
		copyQuad: quad toRect: newForm boundingBox.
	^ newForm! !

!Form methodsFor: 'scaling, rotation' stamp: 'jmv 11/May/2026 11:20:45'!
rotated90Degrees
	"Return a copy of the receiver rotated by 90 degrees.
	ImageMorph defaultForm display.
	ImageMorph defaultForm rotated90Degrees display.
	ImageMorph defaultForm rotated180Degrees display.
	ImageMorph defaultForm rotated270Degrees display.
	"
	| newForm quad |
	newForm := self answerClass extent: self extent transposed depth: depth.
	quad := self boundingBox innerCorners.
	quad := #(2 3 4 1)		collect: [:i | quad at: i].
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		combinationRule: 3;
		copyQuad: quad toRect: newForm boundingBox.
	^ newForm! !

