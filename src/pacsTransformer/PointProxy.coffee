PointState = require './pointProxy/PointState'

module.exports = class PointProxy

	constructor: (@point) ->

		@id = @point._id

		@initialState = new PointState @point
		@currentState = new PointState @point

		@firstSelectedPoint = no
		@lastSelectedPoint = no

		# the current confinements
		@currentConfinement = new Float64Array 2

		# the confinements of this point before being transformed
		@initialConfinement = new Float64Array 2
		@_initialConfinementSet = no

		@prevConnectedUnselectedInitialNeighbourId = null
		@nextConnectedUnselectedInitialNeighbourId = null

	setCurrentConfinement: (left, right) ->

		@currentConfinement[0] = left
		@currentConfinement[1] = right

		unless @_initialConfinementSet

			@initialConfinement.set @currentConfinement

			@_initialConfinementSet = yes

		this

	# Resets the current state to the initial state
	reset: ->

		@currentState._readFromState @initialState

		this