module.exports = class PointDisconnectLeftActionUnit


	@getIdFor: (point, props) ->

		"point.disconnectLeft[#{point._idInPacs}]"

	constructor: (@_actionQueue, @_point) ->



	_setActionUnitProps: ->

	applyForward: ->

		@_point.disconnectFromLeft()

	applyBackward: ->

		@_point.connectToLeft()
