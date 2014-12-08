TransformablePoint = require './pacsTransformer/TransformablePoint'

module.exports = class PacsTransformer

	constructor: (@pacs) ->

		@_pointsArray = []
		do @clear

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

			first = i is 0
			last = i is length - 1

			leftConnector = p.getLeftConnector()

			connectedBack = leftConnector? and not first and leftConnector.getLeftPoint() is orderedPoints[i - 1]

			rightConnector = p.getRightConnector()

			connectedForward = rightConnector? and not last and rightConnector.getRightPoint() is orderedPoints[i + 1]

			transformablePoint = new TransformablePoint p, connectedBack, connectedForward, first, last

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

		console.log offConfinement