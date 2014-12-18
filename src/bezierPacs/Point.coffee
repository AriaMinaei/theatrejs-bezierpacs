PipingEmitter = require 'utila/lib/PipingEmitter'
clamp = require 'utila/lib/math/clamp'
Connector = require './Connector'

module.exports = class Point

	constructor: ->

		@events = new PipingEmitter

		@_id = null
		@_pacs = null
		@_list = null
		@_sequence = null

		@_time = 0
		@_value = 0

		@_leftPoint = null
		@_rightPoint = null

		@_leftConnector = null
		@_rightConnector = null

		@_carriedConnector = new Connector


	belongTo: (pacs) ->

		pacs._list.own this

		@

	disbelong: ->

		unless @_list?

			throw Error "This point doesn't belong to a Pacs yet"

		@_list.disown this

		@

	_reactToBeingOwned: ->

		# TODO: rename
		@events._emit 'belong'

	_reactToBeingDisowned: ->

		# TODO: rename
		@events._emit 'disbelong'

	insert: ->

		unless @_list?

			throw Error "Point isn't recognized by any Pacs yet."

		@_list.insertInSequence this

		@

	remove: ->

		unless @_list?

			throw Error "Point isn't recognized by any Pacs yet."

		@_list.removeFromSequence this

		@

	_getInsertedInSequence: ->

		leftIndex = @_list.getIndexOfPointBeforeOrAt @_time

		myIndex = leftIndex + 1

		if myIndex is 0

			changeFrom = -Infinity

		else

			leftPoint = @_list.getByIndex leftIndex

			unless leftPoint.isConnectedToRight()

				changeFrom = @_time

			else

				throw Error "Point cannot fit where a connector already exists.
					Remove the connector, put the point in sequence, and then restore
					the connector if necessary"

		rightPoint = @_list.getByIndex myIndex

		unless rightPoint?

			changeTo = Infinity

		else

			changeTo = rightPoint._time

		@_list.injectOnIndex this, myIndex

		if leftPoint?

			@_leftPoint = leftPoint

			leftPoint._rightPoint = this

		if rightPoint?

			@_rightPoint = rightPoint
			rightPoint._leftPoint = this

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'insert'

	_getRemovedFromSequence: ->

		if @_leftConnector? or @_rightConnector?

			throw Error "Cannot get removed from sequence because the point is already connected to another point"

		changeFrom = if @_leftPoint? then @_time else -Infinity

		changeTo = if @_rightPoint? then @_rightPoint._time else Infinity

		@_list.pluck this

		if @_leftPoint?

			@_leftPoint._rightPoint = @_rightPoint

		if @_rightPoint?

			@_rightPoint._leftPoint = @_leftPoint

		@_rightPoint = null
		@_leftPoint = null

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'remove'

	eliminate: ->

		do @remove

		do @disbelong

	isConnectedToRight: ->

		@_rightConnector?

	isConnectedToLeft: ->

		@_leftConnector?

	connectToLeft: ->

		if @_leftConnector?

			throw Error "Already connected to left."

		unless @_sequence?

			throw Error "Can't connect. We're not in sequence."

		unless @_leftPoint?

			throw Error "Can't connect to left. We're the first point in the sequence."



	connectToRight: ->

		if @_rightConnector?

			throw Error "Already connected to right."

		unless @_sequence?

			throw Error "Can't connect. We're not in sequence."

		unless @_rightPoint?

			throw Error "Can't connect to right. We're the last point in the sequence."

		@_rightPoint.connectToRight()

		this

	isEventuallyConnectedTo: (targetPoint) ->

		myIndex = @_list.getPointIndex this
		targetIndex = @_list.getPointIndex targetPoint

		needConnector = no

		for index in [myIndex..targetIndex]

			if needConnector

				return no unless @_list.getByIndex(index).isConnector()

			needConnector = !needConnector

		yes

	setTime: (t) ->

		unless @_sequence?

			@_time = +t

		else

			leftConfinement = if @_leftPoint? then @_leftPoint._time else -Infinity
			rightConfinement = if @_rightPoint? then @_rightPoint._time else Infinity

			unless leftConfinement < t < rightConfinement

				throw Error "Cannot move Point outside its neighbors` boundries. Get the point off sequence before moving it in time."

			@_time = +t

			if @_leftConnector?

				@_leftConnector._setRightTime @_time

			if @_rightConnector?

				@_leftConnector._setLeftTime @_time

		@events._emit 'time-change', t

		@

	getTime: ->

		@_time

	setValue: (v) ->

		#TODO: validate
		@_value = +v

		#TODO: emit

		@

	getValue: ->

		@_value

