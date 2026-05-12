'From Cuis7.7 [latest update: #7918] on 12 May 2026 at 6:56:24 pm'!

!MenuMorph methodsFor: 'forgiving submenu' stamp: 'ML 12/May/2026 18:17:32'!
clearForgive
	self removeProperty: #forgiveApex! !

!MenuMorph methodsFor: 'forgiving submenu' stamp: 'ML 12/May/2026 18:17:32'!
point: p inTriangleA: a b: b c: c
	"Standard sign-based point-in-triangle test."
	| d1 d2 d3 hasNeg hasPos |
	d1 := ((p x - b x) * (a y - b y)) - ((a x - b x) * (p y - b y)).
	d2 := ((p x - c x) * (b y - c y)) - ((b x - c x) * (p y - c y)).
	d3 := ((p x - a x) * (c y - a y)) - ((c x - a x) * (p y - a y)).
	hasNeg := (d1 < 0) | (d2 < 0) | (d3 < 0).
	hasPos := (d1 > 0) | (d2 > 0) | (d3 > 0).
	^ (hasNeg and: [hasPos]) not! !

!MenuMorph methodsFor: 'forgiving submenu' stamp: 'ML 12/May/2026 18:17:32'!
recordForgiveApexAt: aPoint
	"Record the cursor position at the moment a submenu was opened.
	This is the apex of the forgiving triangle."
	self setProperty: #forgiveApex toValue: aPoint! !

!MenuMorph methodsFor: 'forgiving submenu' stamp: 'ML 12/May/2026 18:17:32'!
shouldForgiveCursorAt: aPoint
	"True if aPoint is inside the triangle formed by the apex (cursor at
	submenu-open time) and the near edge of the active submenu — i.e. the
	cursor is plausibly heading toward the submenu."
	| apex pos ext leftX rightX topY bottomY nearTop nearBottom |
	activeSubMenu ifNil: [^ false].
	activeSubMenu isInWorld ifFalse: [^ false].
	apex := self valueOfProperty: #forgiveApex ifAbsent: [^ false].
	pos := activeSubMenu morphPosition.
	ext := activeSubMenu morphExtent.
	(pos isNil or: [ext isNil]) ifTrue: [^ false].
	leftX := pos x.
	topY := pos y.
	rightX := pos x + ext x.
	bottomY := pos y + ext y.
	apex x <= leftX
		ifTrue: [nearTop := leftX @ topY. nearBottom := leftX @ bottomY]
		ifFalse: [apex x >= rightX
			ifTrue: [nearTop := rightX @ topY. nearBottom := rightX @ bottomY]
			ifFalse: [^ false]].
	^ self point: aPoint inTriangleA: apex b: nearTop c: nearBottom! !


!MenuItemMorph methodsFor: 'event handling' stamp: 'ML 12/May/2026 18:17:32'!
forgiveDwellExpired
	"Dwell timer fired: cursor stayed on this item long enough to clearly mean it.
	Clear the parent menu's forgive triangle and select this item normally."
	owner ifNotNil: [
		owner clearForgive.
		owner selectItem: self]! !

!MenuItemMorph methodsFor: 'event handling' stamp: 'ML 12/May/2026 18:17:32'!
mouseLeave: aMouseLeaveEvent
	super mouseLeave: aMouseLeaveEvent.
	self removeAlarm: #forgiveDwellExpired! !

!MenuItemMorph methodsFor: 'event handling' stamp: 'ML 12/May/2026 18:17:32'!
mouseMove: anEvent localPosition: aPoint
	"Keep the forgive apex current while the cursor is on an item with an open submenu."
	super mouseMove: anEvent localPosition: aPoint.
	(subMenu notNil
		and: [owner notNil
		and: [owner activeSubMenu == subMenu]])
		ifTrue: [owner recordForgiveApexAt: anEvent eventPosition]! !


!MenuMorph methodsFor: 'submenu activation' stamp: 'ML 12/May/2026 18:17:32'!
activeSubmenu: aSubmenu
	activeSubMenu ifNotNil: [activeSubMenu delete].
	activeSubMenu := aSubmenu.
	self clearForgive! !


!MenuItemMorph methodsFor: 'event handling' stamp: 'ML 12/May/2026 18:17:32'!
mouseEnter: aMouseEnterEvent
	"Forgiving submenu logic:
	1. If we are inside a submenu, clear the parent menu's triangle (we've arrived).
	2. If our own menu has an active submenu and the cursor is heading toward it,
	   ignore — but schedule a dwell timer in case the user lingers here."
	super mouseEnter: aMouseEnterEvent.
	owner ifNotNil: [
		(owner valueOfProperty: #forgiveParent) ifNotNil: [:parent | parent clearForgive].
		(owner shouldForgiveCursorAt: aMouseEnterEvent eventPosition) ifTrue: [
			self addAlarm: #forgiveDwellExpired after: 250.
			^ self].
		owner selectItem: self]! !

!MenuItemMorph methodsFor: 'select/deselect' stamp: 'ML 12/May/2026 18:17:32'!
select
	self isSelected: true.
	owner activeSubmenu: subMenu.
	subMenu ifNotNil: [
		self displayBounds ifNotNil: [:r |
			subMenu delete.
			subMenu
				popUpAdjacentTo: (Array with: r topRight + `10@0` with: r topLeft)
				from: self.
			subMenu setProperty: #forgiveParent toValue: owner.
			self world activeHand ifNotNil: [:hand |
				owner recordForgiveApexAt: hand morphPosition]].
		subMenu selectItem: nil]! !


!MenuMorph reorganize!
('accessing' activeSubMenu addBlankIconsIfNecessary defaultLayerNumber items itemsDo: label lastItem stayUp stayUp:)
('construction' add:action: add:action:argument: add:action:balloonText: add:action:icon: add:action:icon:enabled: add:subMenu: add:target:action: add:target:action:argument: add:target:action:argument:icon: add:target:action:argumentList: add:target:action:icon: add:targetHighlight:action:argumentList: addItemFromDictionary: addItemFromDictionary:targeting: addItemFromDictionaryOrNil: addItemsFromDictionaries: addLabel: addLine addStayUpIcons addTitle: addUpdating:action: addUpdating:target:action: addUpdating:target:action:argumentList: defaultTarget: labels:lines:selections:)
('control' delete deleteIfPopUp: popUpAdjacentTo:from: popUpAt:allowKeyboard: popUpAt:forHand:in: popUpAt:forHand:in:allowKeyboard: popUpForHand:in: popUpInWorld popUpInWorld: selectItem: wantsToBeDroppedInto:)
('dropping/grabbing')
('events' keyStroke: mouseButton1Down:localPosition: mouseButton1Up:localPosition: mouseButton2Up:localPosition:)
('event handling testing' handlesMouseDown:)
('events-processing' handleMouseFocusEvent:)
('geometry' fontPreferenceChanged)
('initialization' defaultBorderWidth defaultColor initialize intoWorld:)
('keyboard control' displayFiltered: keyboardFocusChange: keyboardUnfocused moveSelectionDown:event:)
('menu' removeStayUpBox)
('modal control' doHaltOnAction doesModalInvokation invokeModal invokeModal: isModalInvokationDone isModalInvokationDone: modalSelection modalSelection: mustHaltOnAction)
('testing' is: isIncludedInTaskbar)
('private' adjustSubmorphsLayout selectedItem)
('drawing' drawOn:)
('misc' activate:)
('modal progress dialog' displayAt:during: informUserAt:during:)
('halos and balloon help' addHalo:)
('forgiving submenu' clearForgive point:inTriangleA:b:c: recordForgiveApexAt: shouldForgiveCursorAt:)
('submenu activation' activeSubmenu:)
!


!MenuItemMorph reorganize!
('accessing' contents: contentsWithMarkers:inverse: defaultFont hasIcon hasMarker hasSubMenu isEnabled isEnabled: setBlankIcon setIcon: subMenu subMenu: target:selector:arguments:)
('drawing' drawOn:)
('event handling testing' handlesKeyboardFocus handlesMouseDown: handlesMouseOver:)
('events' activateOwnerMenu: activateSubmenu: invokeWithEvent: mouseButton1Down:localPosition: mouseButton1Up:localPosition: mouseButton2Up:localPosition:)
('events-processing')
('font' font:emphasis:)
('grabbing' aboutToBeGrabbedBy: duplicateMorph:)
('initialization' deleteIfPopUp: initialize)
('layout' magnifiedIcon measureContents minItemWidth)
('selecting' deselect isSelected:)
('private' actionBlockForEvent: offImage onImage)
('testing' is:)
('debug and other' buildDebugMenu: debugAction)
('event handling' forgiveDwellExpired mouseEnter: mouseLeave: mouseMove:localPosition:)
('select/deselect' select)
!

