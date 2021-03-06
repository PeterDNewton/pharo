"
I model self, thisContext and super
"
Class {
	#name : #OCSpecialVariable,
	#superclass : #OCAbstractLocalVariable,
	#category : #'OpalCompiler-Core-Semantics'
}

{ #category : #emitting }
OCSpecialVariable >> emitStore: methodBuilder [

	self shouldNotImplement
]

{ #category : #testing }
OCSpecialVariable >> isSpecialVariable [
	^true
]

{ #category : #testing }
OCSpecialVariable >> isUninitialized [

	^ false
]

{ #category : #testing }
OCSpecialVariable >> isWritable [
	^ false
]
