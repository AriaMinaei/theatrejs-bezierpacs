PipingEmitter = require 'utila/lib/PipingEmitter'
clamp = require 'utila/lib/math/clamp'

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

		@_carriesLeftConnector = no

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

		before = @_list.getBefore this
		after = @_list.getAfter this

		changeFrom = if before? then @_time else -Infinity

		changeTo = if after? then after._time else Infinity

		@_list.pluck this

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'remove'

	eliminate: ->

		do @remove

		do @disbelong

	isConnectedToRight: ->

		@_rightConnector?

	isConnectedToLeft: ->

		@_leftConnector?

	isEventuallyConnectedTo: (targetPoint) ->

		myIndex = @_list.getPointIndex this
		targetIndex = @_list.getPointIndex targetPoint

		needConnector = no

		for index in [myIndex..targetIndex]

			if needConnector

				return no unless @_list.getByIndex(index).isConnector()

			needConnector = !needConnector

		yes

	getTime: ->

		@_time

	setValue: (v) ->

		#TODO: validate
		@_value = +v

		#TODO: emit

		@

	getValue: ->

		@_value

	setTime: (t) ->

		unless @_sequence?

			@_time = +t

		else

			before = @_list.getBefore this

			leftConfinement = if before? then before._time else -Infinity

			after = @_list.getAfter this

			unless after?

				rightConfinement = Infinity

			else if after.isPoint()

				rightConfinement = after._time

			else

				rightConnector = after

				after = @_list.getAfter rightConnector

				rightConfinement = after._time

			unless leftConfinement < t < rightConfinement

				throw Error "Cannot move Point outside its neighbors` boundries. Get the point off sequence before moving it in time."

			@_time = +t

			if before?.isConnector()

				before.reactToChangesInRightPoint()

			if rightConnector?

				rightConnector.reactToChangesInLeftPoint()

		@events._emit 'time-change', t

		@