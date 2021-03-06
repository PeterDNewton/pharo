"
A CheckBoẍPresenteris a spec presenter for Checkbox.
See AbstractFormButtonPresenter

self example

You can also have a look at CheckBoxExample for a full example of how to use them.

I provide the following methods
todo
- labelOnLeft and labelOnRight
- labelClickable
"
Class {
	#name : #SpCheckBoxPresenter,
	#superclass : #SpAbstractFormButtonPresenter,
	#category : #'Spec2-Core-Widgets'
}

{ #category : #specs }
SpCheckBoxPresenter class >> adapterName [

	^ #CheckBoxAdapter
]

{ #category : #example }
SpCheckBoxPresenter class >> example [ 

	self new 
		label: 'Example';
		state: false;
		whenActivatedDo: [ UIManager default defer: [ self inform: 'Activated' ] ];
		whenDeactivatedDo: [ UIManager default defer: [ self inform: 'Deactivated' ] ];
		openWithSpec
]

{ #category : #specs }
SpCheckBoxPresenter class >> title [

	^ 'Checkbox Button'
]

{ #category : #api }
SpCheckBoxPresenter >> labelOnLeft [

	^ self changed: #labelOnLeft with: #()
]

{ #category : #api }
SpCheckBoxPresenter >> labelOnRight [

	^ self changed: #labelOnRight with: #()
]
