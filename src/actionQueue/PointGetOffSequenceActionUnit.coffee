module.exports = class PointGetOffSequenceActionUnit


	@getIdFor: (point, props) ->

		"point.getOffSequence[#{point.id}]"

	constructor: (@_actionQueue, @_point) ->



	_setActionUnitProps: ->

	applyForward: ->

		@_point.getOutOfSequence()

	applyBackward: ->

		@_point.getInSequence()
