module.exports = class PointApplyPropsActionUnit


	@getIdFor: (point, props) ->

		"point.applyProps[#{point._idInPacs}]"

	constructor: (@_actionQueue, @_transformablePoint, @_unitProps) ->

		@_backwardProps = {}
		@_forwardProps = {}

	_setActionUnitProps: (@_unitProps) ->

	captureProps: ->

		@_forwardProps.time = @_transformablePoint.time
		@_forwardProps.value = @_transformablePoint.value
		@_forwardProps.leftHandler = new Float32Array @_transformablePoint.leftHandler
		@_forwardProps.rightHandler = new Float32Array @_transformablePoint.rightHandler

		return this if @_unitProps.ignoreSettingBackwardProps

		@_backwardProps.time = @_transformablePoint._initialTime
		@_backwardProps.value = @_transformablePoint._initialValue
		@_backwardProps.leftHandler = new Float32Array @_transformablePoint._initialLeftHandler
		@_backwardProps.rightHandler = new Float32Array @_transformablePoint._initialRightHandler

		this

	applyForward: ->

		@_transformablePoint.applyToInitialPoint()

