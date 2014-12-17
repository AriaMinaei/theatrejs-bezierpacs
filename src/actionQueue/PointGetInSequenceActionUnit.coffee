module.exports = class PointGetInSequenceActionUnit


	@getIdFor: (point, props) ->

		"point.getInSequence[#{point.id}]"

	constructor: (@_actionQueue, @_point) ->



	_setActionUnitProps: ->

	applyForward: ->

		@_point.getInSequence()

	applyBackward: ->

		@_point.getOutOfSequence()
