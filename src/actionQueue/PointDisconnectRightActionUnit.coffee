module.exports = class PointDisconnectRightActionUnit


	@getIdFor: (point, props) ->

		"point.disconnectRight[#{point.id}]"

	constructor: (@_actionQueue, @_point) ->



	_setActionUnitProps: ->

	applyForward: ->

		@_point.disconnectFromRight()

	applyBackward: ->

		@_point.connectToRight()
