"
A RBGlobalVariablesUsageTest is a test class for testing the behavior of RBGlobalVariablesUsage
"
Class {
	#name : #ReGlobalVariablesUsageRuleTest,
	#superclass : #ReAbstractRuleTestCase,
	#category : #'GeneralRules-Tests-Migrated'
}

{ #category : #'test-help' }
ReGlobalVariablesUsageRuleTest >> sampleMethod [
	"Global variable are stored in Smalltalk globals, and one should avoid them when possible. 
	Examples are Display and Sensor"
	Display value.
	Sensor value.
]

{ #category : #tests }
ReGlobalVariablesUsageRuleTest >> testRule [
	| critiques |
 	critiques := self myCritiques.

 	self assert: critiques size equals: 2.
 	self assert: (self sourceAtChritique: critiques second)  equals: 'Sensor'.
]
