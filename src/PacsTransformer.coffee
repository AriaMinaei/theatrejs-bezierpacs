TransformablePoint = require './pacsTransformer/TransformablePoint'
ActionQueue = require './ActionQueue'

module.exports = class PacsTransformer

	constructor: (@pacs) ->

		@_pointsArray = []
		do @clear

		stepOrder = [
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

		@_listOfUnselectedPointsConnectedToRightInterjectedBySelectedPoints = []

		@_actionQueue = new ActionQueue stepOrder

	clear: ->

		@_pointsMap = {}
		@_pointsArray.length = 0
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

		points = @_selection.getPoints()

		if points.length is 0

			throw Error "Cannot accept an empty list of points"

		orderedPoints = []

		orderedPoints.push p for p in points

		orderedPoints.sort (a, b) -> a._time - b._time

		length = orderedPoints.length

		for p, i in orderedPoints

			transformablePoint = new TransformablePoint p

			first = i is 0
			last = i is length - 1

			transformablePoint.firstSelectedPoint = first
			transformablePoint.lastSelectedPoint = last

			connectedBack = not first and p.isEventuallyConnectedTo orderedPoints[i-1]
			connectedForward = not last and p.isEventuallyConnectedTo orderedPoints[i+1]

			transformablePoint.wasConnectedToPrevSelectedPoint = connectedBack
			transformablePoint.wasConnectedToNextSelectedPoint = connectedForward

			unless connectedBack

				c = p.getLeftConnector()

				if c? then transformablePoint.prevConnectedUnselectedNeighbour = c.getLeftPoint().id

			unless connectedForward

				c = p.getRightConnector()

				if c? then transformablePoint.nextConnectedUnselectedNeighbour = c.getRightPoint().id

			@_pointsArray.push transformablePoint
			@_pointsMap[transformablePoint.idInPacs] = transformablePoint

		return

	_ensureConfinementsAreUpToDate: ->

		return unless @_confinementsInvalid

		for p in @_pointsArray

			leftConfinement = -Infinity
			prevItem = p.initialPoint

			loop

				prevItem = @pacs.getItemBeforeItem prevItem

				break unless prevItem?

				continue if prevItem.isConnector()

				continue if @_pointsMap[prevItem.id]?

				leftConfinement = prevItem._time

				break

			rightConfinement = Infinity
			nextItem = p.initialPoint

			loop

				nextItem = @pacs.getItemAfterItem nextItem

				break unless nextItem?

				continue if nextItem.isConnector()

				continue if @_pointsMap[nextItem.id]?

				rightConfinement = nextItem._time

				break

			p.leftConfinement = leftConfinement
			p.rightConfinement = rightConfinement

			unless p.hasInitialConfinements

				p.initialLeftConfinement = leftConfinement
				p.initialRightConfinement = rightConfinement

				p.hasInitialConfinements = yes

		return

	transform: (fn) ->

		do @_ensureInitialModelIsReady

		do @_ensureConfinementsAreUpToDate

		offConfinement = no

		for p in @_pointsArray

			p.reset()

			fn p

			offConfinement = yes unless p.isInConfinement()

		if offConfinement

			@_confinementsInvalid = yes

			do @_reOrder

		else

			do @_applyProps

		this

	undo: ->

	_applyProps: ->

		# isFirstTimeSettingTime = not @_actionQueue.haveTakenStepsBefore 'applyProps'

		@_actionQueue.startStep 'applyProps'

		p = @_pointsArray[0]

		forward = p.time > p._initialTime

		if forward

			for i in [(@_pointsArray.length - 1)..0]

				p = @_pointsArray[i]

				@_actionQueue
				.getActionUnitFor 'point.applyProps', p #, {ignoreSettingBackwardProps: not isFirstTimeSettingTime}
				.captureProps()
				.applyForward()

				# p.applyToInitialPoint()

		else

			for p in @_pointsArray

				@_actionQueue
				.getActionUnitFor 'point.applyProps', p #, {ignoreSettingBackwardProps: not isFirstTimeSettingTime}
				.captureProps()
				.applyForward()

				# p.applyToInitialPoint()


		@_actionQueue.endStep 'applyProps'

	_reOrder: ->

		@_actionQueue.rollBack()

		# if not @_actionQueue.haveTakenStepsBefore 'applyProps'

		do @_dcExternalEventualConnectionsInterjectedBySelectedPoints
		do @_dcInternalConnections
		do @_getOffSequence
		do @_remakeExternalConnections

		# @_actionQueue.rollBackTo 'applyProps'

		do @_applyProps
		do @_dcExternalConnectionsToBeInterjected
		do @_getInSequence
		do @_remakeInterjectedExternalConnections
		do @_remakeInternalConnections

	_dcExternalEventualConnectionsInterjectedBySelectedPoints: ->

		unselectedPointsToConsider = []

		firstLeftConnector = @_pointsArray[0].initialPoint.getLeftConnector()
		if firstLeftConnector?

			unselectedPointsToConsider.push firstLeftConnector.getLeftPoint()

		fromIndex = @pacs.getItemIndex(@_pointsArray[0].initialPoint) + 1
		toIndex = @pacs.getItemIndex(@_pointsArray[@_pointsArray.length - 1].initialPoint) - 1

		fromIndex = Math.min fromIndex, toIndex
		toIndex = Math.max fromIndex, toIndex

		for i in [fromIndex..toIndex]

			item = @pacs.getItemByIndex i

			unless item?

				throw Error "#{i}???"

			continue if item.isConnector()

			continue if @_pointsMap[item.id]?

			unselectedPointsToConsider.push item

		lastSelectedPoint = @_pointsArray[@_pointsArray.length - 1].initialPoint

		if lastSelectedPoint.getRightConnector()?

			unselectedPointsToConsider.push lastSelectedPoint.getRightConnector().getRightPoint()

		@_listOfUnselectedPointsConnectedToRightInterjectedBySelectedPoints.length = 0

		return if unselectedPointsToConsider.length < 2

		list = @_listOfUnselectedPointsConnectedToRightInterjectedBySelectedPoints

		for i in [0..unselectedPointsToConsider.length - 2]

			curPoint = unselectedPointsToConsider[i]
			nextPoint = unselectedPointsToConsider[i + 1]

			if curPoint.isEventuallyConnectedTo nextPoint

				list.push curPoint.id

		return

	_dcInternalConnections: ->

	_getOffSequence: ->

		@_actionQueue.startStep 'getOffSequence'

		for p in @_pointsArray

			if p.initialPoint.getLeftConnector()?

				@_actionQueue
				.getActionUnitFor 'point.disconnectLeft', p.initialPoint
				.applyForward()

			if p.initialPoint.getRightConnector()?

				@_actionQueue
				.getActionUnitFor 'point.disconnectRight', p.initialPoint
				.applyForward()

		for p in @_pointsArray

			@_actionQueue
			.getActionUnitFor 'point.getOffSequence', p.initialPoint
			.applyForward()

		@_actionQueue.endStep 'getOffSequence'


		return

	_remakeExternalConnections: ->

		@_actionQueue.startStep 'remakeExternalConnections'

		for id in @_listOfUnselectedPointsConnectedToRightInterjectedBySelectedPoints

			p = @pacs.getItemById id

			@_actionQueue
			.getActionUnitFor 'point.connectRight', p
			.applyForward()

		@_actionQueue.endStep 'remakeExternalConnections'

	_dcExternalConnectionsToBeInterjected: ->

	_getInSequence: ->

		@_actionQueue.startStep 'getInSequence'

		for p in @_pointsArray

			@_actionQueue
			.getActionUnitFor 'point.getInSequence', p.initialPoint
			.applyForward()

		@_actionQueue.endStep 'getInSequence'


	_remakeInterjectedExternalConnections: ->

	_remakeInternalConnections: ->