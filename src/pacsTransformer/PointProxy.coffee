PointState = require './pointProxy/PointState'

module.exports = class PointProxy

	constructor: (@point) ->

		@id = @point._id

		@initialState = new PointState @point
		@currentState = new PointState @point

		@firstSelectedPoint = no
		@lastSelectedPoint = no

		# the confinements of this point before being transformed
		@initialConfinement = new Float32Array

		# the current confinements
		@currentConfinement = new Float32Array

		@prevConnectedUnselectedInitialNeighbourId = null
		@nextConnectedUnselectedInitialNeighbourId = null

	# Resets the current state to the initial state
	reset: ->

		@currentState._readFromState @initialState

		this