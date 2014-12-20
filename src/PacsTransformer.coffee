PointProxy = require './pacsTransformer/PointProxy'
PointProxyList = require './pacsTransformer/PointProxyList'
CommandSteppifier = require './CommandSteppifier'
pointProxyCommands = require './pacsTransformer/pointProxyCommands'

module.exports = class PacsTransformer

	constructor: (@pacs) ->

		@_proxies = new PointProxyList

		do @clear

		@_steppifier = new CommandSteppifier [

			'dcInternalToExternalConnections'
			'dcInternalConnections'
			'remove'
			'remakeExternalConnections'
			'applyProps'
			'dcExternalConnectionsToBeInterjected'
			'insert'
			'remakeInterjectedExternalConnections'
			'remakeInternalConnections'

		]

		@_lastRearrangementType = 'inConfinement'

		@_initiallyRightConnectedUnselectedPointsInterjectedByInitiallySelectedPoints = []

	clear: ->

		@_proxies.clear()
		@_initialModelIsReady = no
		@_confinementsInvalid = yes
		@_selection = null

	useSelection: (s) ->

		do @clear

		if s.pacs isnt @pacs

			throw Error "This selection is for another pacs"

		@_selection = s

	_ensureInitialModelIsReady: ->

		return if @_initialModelIsReady

		do @_buildInitialModel

		@_initialModelIsReady = yes

	_buildInitialModel: ->

		unsortedPoints = @_selection.getPoints()

		if unsortedPoints.length is 0

			throw Error "Cannot accept an empty list of points"

		points = []

		points.push p for p in unsortedPoints

		points.sort (a, b) -> a._time - b._time

		length = points.length

		for p, i in points

			pointProxy = new PointProxy p

			first = i is 0
			last = i is length - 1

			pointProxy.firstSelectedPoint = first
			pointProxy.lastSelectedPoint = last

			connectedBack = not first and p.isEventuallyConnectedTo points[i-1]
			connectedForward = not last and p.isEventuallyConnectedTo points[i+1]

			pointProxy.wasConnectedToPrevSelectedPoint = connectedBack
			pointProxy.wasConnectedToNextSelectedPoint = connectedForward

			if not connectedBack and p.isConnectedToLeft()

				pointProxy.prevConnectedUnselectedInitialNeighbourId = p.getLeftPoint()._id

			if not connectedForward and p.isConnectedToRight()

				pointProxy.nextConnectedUnselectedInitialNeighbourId = p.getRightPoint()._id

			@_proxies.add pointProxy

		return

	_ensureConfinementsAreUpToDate: ->

		return unless @_confinementsInvalid

		for proxy in @_proxies.list

			leftConfinement = -Infinity
			prevPoint = proxy.point

			# left confinement
			loop

				prevPoint = prevPoint.getLeftPoint()

				break unless prevPoint?

				continue if @_proxies.hasPoint prevPoint

				leftConfinement = prevPoint._time

				break

			rightConfinement = Infinity
			nextPoint = proxy.point

			# right confinement
			loop

				nextPoint = nextPoint.getRightPoint()


				break unless nextPoint?

				continue if @_proxies.hasPoint nextPoint

				rightConfinement = nextPoint._time

				break

			proxy.setCurrentConfinement leftConfinement, rightConfinement

		return

	transform: (fn) ->

		do @_ensureInitialModelIsReady

		do @_ensureConfinementsAreUpToDate

		inCurrentConfinement = yes
		inInitialConfinement = yes

		for proxy in @_proxies.list

			proxy.resetCurrentState()

			fn proxy.currentState

			inCurrentConfinement = no unless proxy.isInCurrentConfinement()
			inInitialConfinement = no unless proxy.isInInitialConfinement()

		unless inCurrentConfinement

			@_confinementsInvalid = yes

			@_reArrange inInitialConfinement

		else

			do @_applyProps

		this

	_applyProps: ->

		step = @_steppifier.getStep 'applyProps'

		first = @_proxies.list[0]

		increment = if first.currentState.time > first.initialState.time then 1 else -1

		for proxy in @_proxies.list by increment

			step.appendCommand pointProxyCommands.applyProps(null, proxy).do()

		return

	_reArrange: (toInitialConfinement) ->

		if toInitialConfinement

			@_steppifier.rollBack()

			@_lastRearrangementType = 'inConfinement'

			do @_applyProps

			return

		if @_lastRearrangementType is 'inConfinement'

			do @_dcExternalEventualConnectionsInterjectedBySelectedPoints
			do @_remove
			do @_remakeExternalConnections

		else

			@_steppifier.rollBackTo 'applyProps'

		do @_applyProps
		do @_insert
		do @_remakeInternalConnections

		return
		do @_dcExternalConnectionsToBeInterjected
		do @_remakeInterjectedExternalConnections

	_dcExternalEventualConnectionsInterjectedBySelectedPoints: ->

		list = @_initiallyRightConnectedUnselectedPointsInterjectedByInitiallySelectedPoints
		list.length = 0

		unselectedPointsToConsider = []
		points = @_proxies.points

		firstPoint = points[0]
		lastPoint = points[points.length - 1]

		if firstPoint.isConnectedToLeft()

			unselectedPointsToConsider.push firstPoint.getLeftPoint()

		currentPoint = firstPoint

		loop

			currentPoint = currentPoint.getRightPoint()

			break unless currentPoint?

			break if currentPoint is lastPoint

			break if currentPoint._time > lastPoint._time

			unless @_proxies.hasPoint currentPoint

				unselectedPointsToConsider.push currentPoint

		if lastPoint.isConnectedToRight()

			unselectedPointsToConsider.push lastPoint.getRightPoint()

		return if unselectedPointsToConsider.length < 2

		for i in [0..unselectedPointsToConsider.length - 2]

			curPoint = unselectedPointsToConsider[i]
			nextPoint = unselectedPointsToConsider[i + 1]

			if curPoint.isEventuallyConnectedTo nextPoint

				list.push curPoint._id

		return

	_dcInternalConnections: ->

	_remove: ->

		step = @_steppifier.getStep 'remove'

		for p in @_proxies.points

			if p.isConnectedToLeft()

				step.appendCommand pointProxyCommands.disconnectFromLeft(p).do()

			if p.isConnectedToRight()

				step.appendCommand pointProxyCommands.disconnectFromRight(p).do()

		for p in @_proxies.points

			step.appendCommand pointProxyCommands.remove(p).do()

		return

	_remakeExternalConnections: ->

		step = @_steppifier.getStep 'remakeExternalConnections'

		for id in @_initiallyRightConnectedUnselectedPointsInterjectedByInitiallySelectedPoints

			p = @pacs._list.getById id

			step.appendCommand pointProxyCommands.connectToRight(p).do()

	_dcExternalConnectionsToBeInterjected: ->

	_insert: ->

		step = @_steppifier.getStep 'insert'

		for p in @_proxies.points

			step.appendCommand pointProxyCommands.insert(p).do()

	_remakeInterjectedExternalConnections: ->

	_remakeInternalConnections: ->

		step = @_steppifier.getStep 'remakeInternalConnections'

		for proxy, i in @_proxies.list

			if proxy.wasConnectedToNextSelectedPoint

				nextProxy = @_proxies.list[i + 1]

				@_tryToConnect proxy.point, nextProxy.point, step

		return

	_tryToConnect: (from, to, step) ->

		if to._time > from._time

			leftMostPoint = from
			rightMostPoint = to

		else

			leftMostPoint = to
			rightMostPoint = from

		current = leftMostPoint

		loop

			break if current is rightMostPoint

			unless current.isConnectedToRight()

				step.appendCommand pointProxyCommands.connectToRight(current).do()

			current = current.getRightPoint()

		return