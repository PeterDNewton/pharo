Class {
	#name : #OCCompiledMethodIntegrityTest,
	#superclass : #TestCase,
	#category : #'OpalCompiler-Tests-Misc'
}

{ #category : #test }
OCCompiledMethodIntegrityTest >> testBlockTemps [
	| newCompiledMethod |
	newCompiledMethod := OpalCompiler new
		source:
			'ascentOf: aCharacter
											^ [ | temp1 temp2 temp3 | 1= temp1. 2 = temp2. 3 = temp3].';
		class: OCMockCompilationClass;
		compile.

	self assert: newCompiledMethod numArgs equals: 1.
	self assert: (newCompiledMethod numLiterals = 3 or: [ newCompiledMethod numLiterals = 4	"Sista Bytecode" ]).
	self assert: newCompiledMethod numTemps equals: 1.
	self assert: newCompiledMethod primitive equals: 0
]

{ #category : #test }
OCCompiledMethodIntegrityTest >> testNotUsedArgument [
	| newCompiledMethod |
	newCompiledMethod := OpalCompiler new
		source:
			'ascentOf: aCharacter
											^ self ascent.';
		class: OCMockCompilationClass;
		compile.

	self assert: newCompiledMethod numArgs equals: 1.
	self assert: newCompiledMethod numLiterals equals: 3.
	self assert: newCompiledMethod numTemps equals: 1.
	self assert: newCompiledMethod primitive equals: 0
]

{ #category : #test }
OCCompiledMethodIntegrityTest >> testPragmas [
	| newCompiledMethod |
	newCompiledMethod := OpalCompiler new
		source:
			'methodDoublePragma
											<hello: 5>
											<hello: 2>';
		class: OCMockCompilationClass;
		compile.

	self assert: newCompiledMethod numArgs equals: 0.
	self assert: newCompiledMethod numLiterals equals: 2.

	"AdditionalState assertions"
	self assert: newCompiledMethod allLiterals first selector equals: #methodDoublePragma.
	self assert: (newCompiledMethod allLiterals first instVarNamed: 'method') equals: newCompiledMethod.

	self assert: newCompiledMethod primitive equals: 256
]

{ #category : #test }
OCCompiledMethodIntegrityTest >> testPrimitive [
	| newCompiledMethod |
	newCompiledMethod := OpalCompiler new
		source:
			'size
											<primitive: 62>
											^ self basicSize.';
		class: OCMockCompilationClass;
		compile.

	self assert: newCompiledMethod numArgs equals: 0.
	self assert: newCompiledMethod numLiterals equals: 3.
	self assert: newCompiledMethod numTemps equals: 0.
	self assert: newCompiledMethod primitive equals: 62
]

{ #category : #test }
OCCompiledMethodIntegrityTest >> testRemoteTempInVector [
	| newCompiledMethod expectedLiterals |
	newCompiledMethod := OpalCompiler new
		source:
			'value
													    | answer |
 													   self do:
       														 [:each |
        															answer := each value].
   													 ^answer';
		class: Object;
		compile.

	"In FullBlockClosure the block is another literal of the method"
	expectedLiterals := (CompilationContext optionFullBlockClosure) ifTrue: [ 3 ] ifFalse: [ 2 ].

	self assert: newCompiledMethod numArgs equals: 0.
	self assert: newCompiledMethod numLiterals equals: expectedLiterals.
	self assert: newCompiledMethod numTemps equals: 1.
	self assert: newCompiledMethod primitive equals: 0
]

{ #category : #test }
OCCompiledMethodIntegrityTest >> testUndeclaredVariable [
	| newCompiledMethod undeclaredBinding |
	newCompiledMethod := OpalCompiler new
		source:
			'methodWithUndeclaredVar
											^ undeclaredTestVar';
		class: OCMockCompilationClass;
		compile.

	undeclaredBinding := newCompiledMethod literals detect: [ :each | each name = #undeclaredTestVar ].
	self assert: undeclaredBinding class equals: UndeclaredVariable.
	self assert: undeclaredBinding identicalTo: (Undeclared associationAt: #undeclaredTestVar).
	Undeclared removeKey: #undeclaredTestVar
]
