module.exports = class TransformablePoint

	constructor: (@initialPoint) ->

		@_initialTime = @initialPoint._time
		@_initialValue = @initialPoint._value
		@_initialLeftHandler = new Float64Array @initialPoint._leftHandler
		@_initialRightHandler = new Float64Array @initialPoint._rightHandler

		@wasConnectedToPrevSelectedPoint = no
		@wasConnectedToNextSelectedPoint = no

		@firstSelectedPoint = no
		@lastSelectedPoint = no

		@leftHandler = new Float64Array 2
		@rightHandler = new Float64Array 2

		@idInPacs = @initialPoint._idInPacs

		@leftConfinement = 0
		@rightConfinement = 0

		do @reset

	reset: ->

		@time = @_initialTime
		@value = @_initialValue
		@leftHandler.set @_initialLeftHandler
		@rightHandler.set @_initialRightHandler

		this

	applyToInitialPoint: ->

		@initialPoint
		.setTime(@time)
		.setValue(@value)
		.setLeftHandler(@leftHandler[0], @leftHandler[1])
		.setRightHandler(@rightHandler[0], @rightHandler[1])

		this

	isInConfinement: ->

		@leftConfinement < @time < @rightConfinement