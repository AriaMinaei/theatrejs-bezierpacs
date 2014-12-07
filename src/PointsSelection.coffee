PipingEmitter = require 'utila/lib/PipingEmitter'

module.exports = class PointsSelection

	constructor: (@pacs) ->

		@events = new PipingEmitter

		@_points = []

	###*
	 * @param Array[Point] points
	###
	addPoints: (points) ->

		for p in points

			@addPoint p

		@

	###*
	 * @param Point p
	###
	addPoint: (p) ->

		return this if p in @_points

		@_points.push p

		# TODO: better name
		@events._emit 'new-point', p

		this

	###*
	 * @param  Point p
	###
	removePoint: (p) ->

		return this unless p in @_points

		@_points.splice @_points.indexOf(p), 1

		# TODO: better name
		@events._emit 'remove-point', p

		this

	removePoints: (points) ->

		for p in points

			@removePoint p

		this

	clear: ->

		loop

			break if @_points.length is 0

			p = @_points.pop()

			# TODO: better name
			@events._emit 'remove-point', p

		this

	getPoints: ->

		@_points

	isEmpty: ->

		@_points.length is 0