PipingEmitter = require 'utila/lib/PipingEmitter'
valueIsInt = require 'utila/lib/math/valueIsInt'

module.exports = class PointsList

	constructor: (@_pacs) ->

		@events = new PipingEmitter

		###
		 * This is the list of our s, in sequence.
		 *
		 * @type {Array}
		###
		@_pointsInSequence = []

		###
		 * This is the map to all the objects recognized by this Pacs. Not all
		 * the points in this map will be in @_pointsInSequence, but all the @_pointsInSequence
		 * will be in this map.
		 *
		 * @type {Object}
		###
		@_pointsById = {}

		@_lastAssignedId = -1

	own: (point) ->

		if point._pacs?

			throw Error "This point already is owned by a Pacs, so it cannot be owned by this Pacs"

		# if the point already has an id
		if valueIsInt point._id

			id = point._id

			# make sure it's not a duplicate
			if @_pointsById[id]?

				throw Error "A point with with '#{id}' as ID already exists here"

			@_lastAssignedId = Math.max @_lastAssignedId, id

		# just assign an id to it
		else

			id = ++@_lastAssignedId

			point._id = id

		@_pointsById[id] = point

		point._pacs = @_pacs
		point._list = this

		point._reactToBeingOwned()

		@events._emit 'point-ownership', point

		@

	disown: (point) ->

		unless point._pacs?

			throw Error "Cannot unrecognize this point because it doesn't have a Pacs. How did this happen btw?"

		if point._sequence?

			throw Error "This point is still in sequence."

		@_pointsById[point._id] = null

		point._list = null
		point._pacs = null

		point._reactToBeingDisowned()

		@events._emit 'point-disownership', point

		@

	getById: (id) ->

		@_pointsById[id]

	insertInSequence: (point) ->

		if point._list isnt this

			throw Error "This point is not recognized by this Pacs."

		if point._sequence?

			throw Error "This point is still in sequence."

		point._sequence = @_pointsInSequence

		point._getInsertedInSequence()

		@

	removeFromSequence: (point) ->

		if point._list isnt this

			throw Error "This point is not recognized by this Pacs."

		if point._sequence isnt @_pointsInSequence

			throw Error "This point is not in this sequence."

		point._getRemovedFromSequence()

		point._sequence = null

		@

	getIndexOfPointBeforeOrAt: (t) ->

		# From http://oli.me.uk/2013/06/08/searching-javascript-arrays-with-a-binary-search/

		minIndex = 0
		maxIndex = @_pointsInSequence.length - 1

		biggestIndex = -1

		while minIndex <= maxIndex

			currentIndex = (minIndex + maxIndex) / 2 | 0
			currentElement = @_pointsInSequence[currentIndex]

			if currentElement._time < t

				biggestIndex = Math.max currentIndex, biggestIndex

				minIndex = currentIndex + 1

			else if currentElement._time > t

				maxIndex = currentIndex - 1

			else

				return currentIndex

		return biggestIndex

		# lastIndex = -1

		# for point, index in @_pointsInSequence

		# 	break if point._time > t

		# 	lastIndex = index

		# lastIndex

	###*
	 * If there are two s on that time (a point and a connector),
	 * returns the connector.
	 *
	 * @param  Float64 t time
	 * @return /undefined
	###
	getAfter: (t) ->

		@getByIndex @getIndexOfPointBeforeOrAt(t) + 1

	getBeforeOrAt: (t) ->

		@getByIndex @getIndexOfPointBeforeOrAt t

	getByIndex: (index) ->

		@_pointsInSequence[index]

	getIndex: (point) ->

		@_pointsInSequence.indexOf point

	getAt: (t) ->

		index = @getIndexOfPointBeforeOrAt t

		point = @getByIndex index

		return unless point?

		return unless point._time is t

		point

	pointExistsAt: (t) ->

		@getAt(t)?

	getBefore: (point) ->

		index = @getIndex point

		@getByIndex index - 1

	getAfter: (point) ->

		index = @getIndex point

		@getByIndex index + 1

	injectOnIndex: (point, index) ->

		@_pointsInSequence.splice index, 0, point

		return

	pluckOn: (index) ->

		@_pointsInSequence.splice index, 1

		return

	pluck: (point) ->

		@pluckOn @getIndex point

		return

	getsInRange: (from, to) ->

		points = []

		for point in @_pointsInSequence

			break if point._time > to

			continue if point._time < from

			points.push point

		points