PointProxy = require './pacsTransformer/PointProxy'
PointProxyList = require './pacsTransformer/PointProxyList'
CommandSteppifier = require './CommandSteppifier'

module.exports = class PacsTransformer

	constructor: (@pacs) ->

		@_proxies = new PointProxyList

		do @clear

		@_steppifier = new CommandSteppifier [

			'dcInternalToExternalConnections'
			'dcInternalConnections'
			'getOffSequence'
			'remakeExternalConnections'
			'applyProps'
			'dcExternalConnectionsToBeInterjected'
			'getInSequence'
			'remakeInterjectedExternalConnections'
			'remakeInternalConnections'

		]

		@_unselectedPointsWhoseRightConnectionsAreInterjectedBySelectedPoints = []


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

			console.log 'doing', proxy.id

			# left confinement
			loop

				prevPoint = prevPoint.getLeftPoint()

				break unless prevPoint?

				continue if @_proxies.hasPoint prevPoint

				leftConfinement = prevPoint._time

				break

			rightConfinement = Infinity
			nextPoint = proxy.point

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

			do @_reOrder

		else

			do @_applyProps

		this

	undo: ->

	_applyProps: ->

		step = @_steppifier.getStep 'applyProps'

		first = @_proxies.list[0]

		increment = if first.currentState.time > first.initialState.time then 1 else -1

		for proxy in @_proxies.list by increment

			step.addCommand pointProxyCommands.applyProps(p).applyForward()

		return

	_reOrder: ->

		@_steppifier.rollBack()

		# if not @_steppifier.haveTakenStepsBefore 'applyProps'

		do @_dcExternalEventualConnectionsInterjectedBySelectedPoints
		do @_dcInternalConnections
		do @_getOffSequence
		do @_remakeExternalConnections

		# @_steppifier.rollBackTo 'applyProps'

		do @_applyProps
		do @_dcExternalConnectionsToBeInterjected
		do @_getInSequence
		do @_remakeInterjectedExternalConnections
		do @_remakeInternalConnections

	_dcExternalEventualConnectionsInterjectedBySelectedPoints: ->

		unselectedPointsToConsider = []

		firstLeftConnector = @_proxiesArray[0].initialPoint.getLeftConnector()
		if firstLeftConnector?

			unselectedPointsToConsider.push firstLeftConnector.getLeftPoint()

		fromIndex = @pacs.getItemIndex(@_proxiesArray[0].initialPoint) + 1
		toIndex = @pacs.getItemIndex(@_proxiesArray[@_proxiesArray.length - 1].initialPoint) - 1

		fromIndex = Math.min fromIndex, toIndex
		toIndex = Math.max fromIndex, toIndex

		for i in [fromIndex..toIndex]

			item = @pacs.getItemByIndex i

			unless item?

				throw Error "#{i}???"

			continue if item.isConnector()

			continue if @_proxiesMap[item.id]?

			unselectedPointsToConsider.push item

		lastSelectedPoint = @_proxiesArray[@_proxiesArray.length - 1].initialPoint

		if lastSelectedPoint.getRightConnector()?

			unselectedPointsToConsider.push lastSelectedPoint.getRightConnector().getRightPoint()

		@_unselectedPointsWhoseRightConnectionsAreInterjectedBySelectedPoints.length = 0

		return if unselectedPointsToConsider.length < 2

		list = @_unselectedPointsWhoseRightConnectionsAreInterjectedBySelectedPoints

		for i in [0..unselectedPointsToConsider.length - 2]

			curPoint = unselectedPointsToConsider[i]
			nextPoint = unselectedPointsToConsider[i + 1]

			if curPoint.isEventuallyConnectedTo nextPoint

				list.push curPoint.id

		return

	_dcInternalConnections: ->

	_getOffSequence: ->

		@_steppifier.startStep 'getOffSequence'

		for p in @_proxiesArray

			if p.initialPoint.getLeftConnector()?

				@_steppifier
				.getActionUnitFor 'point.disconnectLeft', p.initialPoint
				.applyForward()

			if p.initialPoint.getRightConnector()?

				@_steppifier
				.getActionUnitFor 'point.disconnectRight', p.initialPoint
				.applyForward()

		for p in @_proxiesArray

			@_steppifier
			.getActionUnitFor 'point.getOffSequence', p.initialPoint
			.applyForward()

		@_steppifier.endStep 'getOffSequence'


		return

	_remakeExternalConnections: ->

		@_steppifier.startStep 'remakeExternalConnections'

		for id in @_unselectedPointsWhoseRightConnectionsAreInterjectedBySelectedPoints

			p = @pacs.getItemById id

			@_steppifier
			.getActionUnitFor 'point.connectRight', p
			.applyForward()

		@_steppifier.endStep 'remakeExternalConnections'

	_dcExternalConnectionsToBeInterjected: ->

	_getInSequence: ->

		@_steppifier.startStep 'getInSequence'

		for p in @_proxiesArray

			@_steppifier
			.getActionUnitFor 'point.getInSequence', p.initialPoint
			.applyForward()

		@_steppifier.endStep 'getInSequence'


	_remakeInterjectedExternalConnections: ->

	_remakeInternalConnections: ->