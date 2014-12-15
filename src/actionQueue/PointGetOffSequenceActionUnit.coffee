module.exports = class PointGetOffSequenceActionUnit


	@getIdFor: (point, props) ->

		"point.disconnectGetOffSequence[#{point._idInPacs}]"

	constructor: (@_actionQueue, @_point) ->



	_setActionUnitProps: ->

	applyForward: ->

		@_point.getOutOfSequence()

	applyBackward: ->

		@_point.getInSequence()
