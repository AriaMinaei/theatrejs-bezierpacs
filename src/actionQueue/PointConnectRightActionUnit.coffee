module.exports = class PointConnectRightActionUnit


	@getIdFor: (point, props) ->

		"point.connectRight[#{point.id}]"

	constructor: (@_actionQueue, @_point) ->



	_setActionUnitProps: ->

	applyForward: ->

		@_point.connectToRight()

	applyBackward: ->

		@_point.disconnectFromRight()
