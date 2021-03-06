"
I model super variables
"
Class {
	#name : #OCSuperVariable,
	#superclass : #OCSpecialVariable,
	#category : #'OpalCompiler-Core-Semantics'
}

{ #category : #accessing }
OCSuperVariable class >> semanticNodeClass [

	^RBSuperNode 
]

{ #category : #emitting }
OCSuperVariable >> emitValue: methodBuilder [
	"super references the receiver, send that follows is a super send (the message lookup starts in the superclass)"
	methodBuilder pushReceiver
]

{ #category : #initialization }
OCSuperVariable >> initialize [
	super initialize.
	
	name := 'super'
]

{ #category : #testing }
OCSuperVariable >> isSelfOrSuper [
	
	^ true
]

{ #category : #testing }
OCSuperVariable >> isSuper [
	^true
]
