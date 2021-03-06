"
A Breakpoint is an object used for stopping the execution of the program in a determined instruction, normally with debugging purposes. 
There are three types of breakpoints:
-halt once: These are triggered once, and then removed.
-halt always: Once installed, they have to be explicitly removed (by using #remove on the instance side, or #removeAll on class side)
-halt on condition: Before being installed prompts the user for a condition (a block with a boolean expression), and it is only triggered when that condition is met.

Breakpoints are installed via SmartSuggestions menu (available for RBMethodNode, RBMessageNode and RBAssignmentNode), or programmatically:

""(Breakpoint inMethod: (Bar>>#foo2) inNode: ((Bar>>#foo2) ast allChildren at: 9) )
break: #when: withArguments: { [ RFCounter counter isZero ] }
""


"
Class {
	#name : #Breakpoint,
	#superclass : #Object,
	#instVars : [
		'condition',
		'link',
		'node',
		'level',
		'options'
	],
	#classVars : [
		'AllBreakpoints',
		'Observers'
	],
	#category : #'Reflectivity-Breakpoints'
}

{ #category : #all }
Breakpoint class >> addBreakpoint: aBreakpoint [
	self all add: aBreakpoint.
	self notifyBreakpointAdded: aBreakpoint
]

{ #category : #all }
Breakpoint class >> all [ 
	^ AllBreakpoints ifNil: [ AllBreakpoints := OrderedCollection new ]
]

{ #category : #all }
Breakpoint class >> browseAll [
	<script>
	| methods |
	methods := self all flatCollect: [ :breakpoint | breakpoint link methods ].
	Smalltalk tools messageList browse: methods
]

{ #category : #checkCondition }
Breakpoint class >> checkBreakConditionValue: aValue [
	(aValue isKindOf: Boolean) ifTrue: [ ^ aValue ].
	Error signal: 'Breakpoint condition returned a non boolean value'.
]

{ #category : #cleanup }
Breakpoint class >> cleanUp [
	self removeAll
]

{ #category : #all }
Breakpoint class >> debugWorldMenuOn: aBuilder [
	<worldMenu>
	(aBuilder item: #'Remove all Breakpoints')
		parent: #Debugging;
		order: 0;
		help: 'Remove all the breakpoints of the image.';
		action: [ Breakpoint removeAll ]
]

{ #category : #'system announcements' }
Breakpoint class >> handleClassRemoved: anAnnouncement [
	self all copy do: [ :breakpoint |
		breakpoint link methods
			detect: [ :m | m methodClass = anAnnouncement classRemoved ]
			ifFound: [ self removeBreakpoint: breakpoint ] ]
]

{ #category : #'system announcements' }
Breakpoint class >> handleMethodModified: anAnnouncement [
	self removeFromMethod: anAnnouncement oldMethod
]

{ #category : #'system announcements' }
Breakpoint class >> handleMethodRemoved: anAnnouncement [
	self removeFromMethod: anAnnouncement method
]

{ #category : #initialization }
Breakpoint class >> initialize [
	self registerInsterestToSystemAnnouncement 
]

{ #category : #querying }
Breakpoint class >> isInstalledIn: aMethod [

	self all do: [ :breakpoint |
		breakpoint link methods 
			detect: [ :m | m == aMethod ]
			ifFound: [ ^ true ]
	].

	^ false
]

{ #category : #'observers - experimental' }
Breakpoint class >> notifyBreakpointAdded: aBreakpoint [
	| notification |
	notification := BreakpointAddedNotification
		on: aBreakpoint
		nodes: aBreakpoint link nodes.
	self notifyObservers: notification
]

{ #category : #'observers - experimental' }
Breakpoint class >> notifyBreakpointHit: aBreakpoint inContext: aContext node: node [
	| notification |
	notification := BreakpointHitNotification
		on: aBreakpoint
		nodes: {node}.
	self notifyObservers: notification
]

{ #category : #'observers - experimental' }
Breakpoint class >> notifyBreakpointRemoved: aBreakpoint fromNodes: nodes [
	| notification |
	notification := BreakpointRemovedNotification
		on: aBreakpoint
		nodes: nodes.
	self notifyObservers: notification
]

{ #category : #'observers - experimental' }
Breakpoint class >> notifyObservers: aNotification [
	self observers
		do: [ :observer | observer ifNotNil: [ observer update: aNotification ] ]
]

{ #category : #'observers - experimental' }
Breakpoint class >> observers [
	^Observers ifNil:[Observers := WeakOrderedCollection new]
]

{ #category : #'class initialization' }
Breakpoint class >> registerInsterestToSystemAnnouncement [
	<systemEventRegistration>

	SystemAnnouncer uniqueInstance unsubscribe: self.
	SystemAnnouncer uniqueInstance weak when: MethodRemoved send: #handleMethodRemoved: to: self.
	SystemAnnouncer uniqueInstance weak when: MethodModified send: #handleMethodModified: to: self.
	SystemAnnouncer uniqueInstance weak when: ClassRemoved send: #handleClassRemoved: to: self
]

{ #category : #'observers - experimental' }
Breakpoint class >> registerObserver: anObject [
	self observers addIfNotPresent: anObject
]

{ #category : #cleanup }
Breakpoint class >> removeAll [ 
	<script>
	self all copy do: #remove
]

{ #category : #all }
Breakpoint class >> removeBreakpoint: aBreakpoint [
	| nodes |
	nodes := aBreakpoint link nodes copy.
	self all remove: aBreakpoint.
	self notifyBreakpointRemoved: aBreakpoint fromNodes: nodes
]

{ #category : #cleanup }
Breakpoint class >> removeFrom: aNode [
	| links breakpointsToRemove |
	links := OrderedCollection new.
	links addAll: (aNode beforeLinks select: [ :link | link metaObject = Break]).
	links addAll: (aNode afterLinks select: [ :link | link metaObject = Break]).
	breakpointsToRemove := self all select: [ :br | links includes: br link].
	breakpointsToRemove asSet do: #remove
]

{ #category : #cleanup }
Breakpoint class >> removeFromMethod: aMethod [ 
	self all copy do: [ :breakpoint |
		breakpoint link methods
			detect: [ :m | m == aMethod ]
			ifFound: [ self removeBreakpoint: breakpoint  ] ]
]

{ #category : #'observers - experimental' }
Breakpoint class >> unregisterObserver: anObject [
	self observers remove: anObject
]

{ #category : #api }
Breakpoint >> always [
	self link: self breakLink


]

{ #category : #links }
Breakpoint >> breakLink [
	"for now it should just halt in base level"

	^ MetaLink new
		metaObject: Break;
		selector: #break:inContext:node:;
		options: options;
		arguments:
			{(RFLiteralVariableNode value: self).
			#context.
			#node}
]

{ #category : #links }
Breakpoint >> breakLinkConditional [	
	^self breakLink condition: condition arguments: #(context)
]

{ #category : #links }
Breakpoint >> breakLinkOneShot [
	^ self breakLink optionOneShot: true
]

{ #category : #api }
Breakpoint >> condition: aCondition [
	condition := aCondition.
	self link: self breakLinkConditional
]

{ #category : #initialization }
Breakpoint >> initialize [
	options := #(+ optionCompileOnLinkInstallation + optionAnnounce)
]

{ #category : #install }
Breakpoint >> install [
	self class addBreakpoint: self.
	self node link: self link
]

{ #category : #accessing }
Breakpoint >> level [
	^level
]

{ #category : #accessing }
Breakpoint >> level: aLevel [
	level := aLevel
]

{ #category : #accessing }
Breakpoint >> link [
	^link ifNil: [ link := self breakLink ]
]

{ #category : #accessing }
Breakpoint >> link: aMetaLink [
	link := aMetaLink
]

{ #category : #accessing }
Breakpoint >> node [ 
	 ^ node
]

{ #category : #accessing }
Breakpoint >> node: aNode [
	node := aNode
]

{ #category : #api }
Breakpoint >> once [
	self link: self breakLinkOneShot
	
]

{ #category : #accessing }
Breakpoint >> options: anArray [
	options := anArray
]

{ #category : #install }
Breakpoint >> remove [
	self class removeBreakpoint: self.
	link uninstall
]
