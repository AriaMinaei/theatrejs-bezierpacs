PipingEmitter = require 'utila/lib/PipingEmitter'
clamp = require 'utila/lib/math/clamp'

module.exports = class Point

	constructor: ->

		@_id = null
		@_pacs = null
		@_list = null
		@_sequence = null

		@_time = 0
		@_value = 0

		@events = new PipingEmitter

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

		beforeIndex = @_list.getIndexOfPointBeforeOrAt @_time

		myIndex = beforeIndex + 1

		if myIndex is 0

			changeFrom = -Infinity

		else

			beforePoint = @_list.getByIndex beforeIndex

			unless beforePoint.isConnectedToRight()

				changeFrom = @_time

			else

				throw Error "Point cannot fit where a connector already exists.
					Remove the connector, put the point in sequence, and then restore
					the connector if necessary"

		afterPoint = @_list.getByIndex myIndex

		unless afterPoint?

			changeTo = Infinity

		else

			changeTo = afterPoint._time

		@_list.injectOnIndex this, myIndex

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'insert'

	_getRemovedFromSequence: ->

		if @_leftConnector?

			throw Error "Cannot fit out of sequence when already connected to the left."

		if @_rightConnector?

			throw Error "Cannot fit out of sequence when already connected to the right."

		before = @_list.getPointBeforePoint this
		after = @_list.getPointAfterPoint this

		changeFrom = if before? then @_time else -Infinity

		changeTo = if after? then after._time else Infinity

		@_list.pluckPoint this

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'remove'

	eliminate: ->

		do @remove

		do @disbelong

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

			before = @_list.getPointBeforePoint this

			leftConfinement = if before? then before._time else -Infinity

			after = @_list.getPointAfterPoint this

			unless after?

				rightConfinement = Infinity

			else if after.isPoint()

				rightConfinement = after._time

			else

				rightConnector = after

				after = @_list.getPointAfterPoint rightConnector

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

	isEventuallyConnectedTo: (targetPoint) ->

		myIndex = @_list.getPointIndex this
		targetIndex = @_list.getPointIndex targetPoint

		needConnector = no

		for index in [myIndex..targetIndex]

			if needConnector

				return no unless @_list.getByIndex(index).isConnector()

			needConnector = !needConnector

		yes