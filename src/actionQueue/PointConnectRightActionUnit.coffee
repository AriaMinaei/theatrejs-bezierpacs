module.exports = class PointConnectRightActionUnit


	@getIdFor: (point, props) ->

		"point.connectRight[#{point._idInPacs}]"

	constructor: (@_actionQueue, @_point) ->



	_setActionUnitProps: ->

	applyForward: ->

		@_point.connectToRight()

	applyBackward: ->

		@_point.disconnectFromRight()
