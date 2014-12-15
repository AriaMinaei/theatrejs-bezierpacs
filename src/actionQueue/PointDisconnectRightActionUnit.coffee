module.exports = class PointDisconnectRightActionUnit


	@getIdFor: (point, props) ->

		"point.disconnectRight[#{point._idInPacs}]"

	constructor: (@_actionQueue, @_point) ->



	_setActionUnitProps: ->

	applyForward: ->

		@_point.disconnectFromRight()

	applyBackward: ->

		@_point.connectToRight()
