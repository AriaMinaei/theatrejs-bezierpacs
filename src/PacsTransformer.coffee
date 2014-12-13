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

				if c? then transformablePoint.prevConnectedUnselectedNeighbour = c.getLeftPoint()._idInPacs

			unless connectedForward

				c = p.getRightConnector()

				if c? then transformablePoint.nextConnectedUnselectedNeighbour = c.getRightPoint()._idInPacs

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

				continue if @_pointsMap[prevItem._idInPacs]?

				leftConfinement = prevItem._time

				break

			rightConfinement = Infinity
			nextItem = p.initialPoint

			loop

				nextItem = @pacs.getItemAfterItem nextItem

				break unless nextItem?

				continue if nextItem.isConnector()

				continue if @_pointsMap[nextItem._idInPacs]?

				rightConfinement = nextItem._time

				break

			p.leftConfinement = leftConfinement
			p.rightConfinement = rightConfinement

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

	_applyProps: ->

		@_actionQueue.startStep 'applyProps'

		p = @_pointsArray[0]

		forward = p.time > p._initialTime

		if forward

			for i in [(@_pointsArray.length - 1)..0]

				p = @_pointsArray[i]

				p.applyToInitialPoint()

		else

			for p in @_pointsArray

				p.applyToInitialPoint()


		@_actionQueue.endStep 'applyProps'

	_reOrder: ->

		if not @_actionQueue.haveTakenStepsBefore 'applyProps'

			do @_dcInternalToExternalConnections
			do @_dcInternalConnections
			do @_getOffSequence
			do @_remakeExternalConnections

		@_actionQueue.rollBackTo 'applyProps'

		do @_applyProps
		do @_dcExternalConnectionsToBeInterjected
		do @_getInSequence
		do @_remakeInterjectedExternalConnections
		do @_remakeInternalConnections

	_dcInternalToExternalConnections: ->

	_dcInternalConnections: ->

	_getOffSequence: ->

	_remakeExternalConnections: ->

	_dcExternalConnectionsToBeInterjected: ->

	_getInSequence: ->

	_remakeInterjectedExternalConnections: ->

	_remakeInternalConnections: ->