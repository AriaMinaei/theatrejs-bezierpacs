module.exports = class PointApplyPropsActionUnit


	@getIdFor: (point, props) ->

		"point.applyProps[#{point._idInPacs}]"

	constructor: (@_actionQueue, @_point, @_unitProps) ->

		@_backwardProps = {}
		@_forwardProps = {}

	_setActionUnitProps: (@_unitProps) ->

	captureProps: ->

		@_forwardProps.time = @_point.time
		@_forwardProps.value = @_point.value
		@_forwardProps.leftHandler = new Float32Array @_point.leftHandler
		@_forwardProps.rightHandler = new Float32Array @_point.rightHandler

		return this if @_unitProps.ignoreSettingBackwardProps

		@_backwardProps.time = @_point._initialTime
		@_backwardProps.value = @_point._initialValue
		@_backwardProps.leftHandler = new Float32Array @_point._initialLeftHandler
		@_backwardProps.rightHandler = new Float32Array @_point._initialRightHandler

		this

	applyForward: ->

		@_point.applyToInitialPoint()

