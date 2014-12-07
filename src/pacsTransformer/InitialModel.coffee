module.exports = class InitialModel

	constructor: ->

		@_ready = no

		@_initialListOfPoints = []

	isReady: ->

		@_ready

	reset: ->

		@_ready = no

		@_initialListOfPoints.length = 0

	setPoints: (points) ->

		do @reset

		if points.length is 0

			throw Error "Cannot accept an empty list of points"

		@_initialListOfPoints.push p for p in points

		@_initialListOfPoints.sort (a, b) -> a._time - b._time

		@_ready = yes