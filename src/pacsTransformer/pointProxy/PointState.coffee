module.exports = class PointState

	constructor: (pacsPoint) ->

		@time = 0
		@value = 0

		if pacsPoint? then @_readFrom pacsPoint

	_readFrom: (pacsPoint) ->

		@time = pacsPoint._time
		@value = pacsPoint._value

	_readFromState: (state) ->

		@time = state.time
		@value = state.value