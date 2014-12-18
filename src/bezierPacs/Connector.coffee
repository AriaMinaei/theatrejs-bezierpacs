module.exports = class Connector

	constructor: ->

		@_active = no

		@_leftTime    = Infinity
		@_leftValue   = 0

		@_rightTime    = -Infinity
		@_rightValue   = 0

	isActive: ->

		@_active

	activate: ->

		if @_active

			throw Error "Already active."

		@_active = yes

		this

	deactivate: ->

		unless @_active

			throw Error "We're not active, so we can't deactivate."

		@_active = no

		this

	_fitInSequence: ->

		beforeIndex = @_pacs.getIndexOfItemBeforeOrAt @_time

		myIndex = beforeIndex + 1

		before = @_pacs.getItemByIndex beforeIndex

		unless before? and before.isPoint()

			throw Error "We need a point to be present before each connector"

		after = @_pacs.getItemByIndex myIndex

		unless after? and after.isPoint()

			throw Error "We need a point to be present after each connector"

		@_pacs.injectItemOnIndex this, myIndex

		@_leftPoint = before
		@_rightPoint = after

		do @reactToChangesInLeftPoint
		do @reactToChangesInRightPoint

		@_leftPoint._setRightConnector this
		@_rightPoint._setLeftConnector this

		@_pacs._reportChange before._time, after._time

		@events._emit 'inSequnce'

	_setLeftTime: (t) ->

		@_leftTime = +t

		this

	_setLeftTime: (x) ->

		@_leftTime = +x

		this

	getLeftTime: ->

		@_leftTime

	_setRightTime: (x) ->

		@_rightTime = +x

		this

	getRightTime: ->

		@_rightTime

	_setLeftValue: (x) ->

		@_leftValue = +x

		this

	getLeftValue: ->

		@_leftValue

	_setRightValue: (x) ->

		@_rightValue = +x

		this

	getRightValue: ->

		@_rightValue

	reactToChangesInRightPoint: ->

		changeFrom = @_leftTime
		changeTo = Math.max @_rightTime, @_rightPoint._time

		@_rightTime = @_rightPoint._time
		@_rightValue = @_rightPoint._value
		@_rightHandler = @_rightPoint._leftHandler

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'curve-change'

		@

	reactToChangesInLeftPoint: ->

		changeFrom = Math.min @_leftTime, @_leftPoint._time
		changeTo = @_rightTime

		@setTime @_leftPoint._time

		@_leftTime = @_leftPoint._time
		@_leftValue = @_leftPoint._value
		@_leftHandler = @_leftPoint._rightHandler

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'curve-change'

		@

	_fitOutOfSequence: ->

		changeFrom = @_leftTime
		changeTo = @_rightTime

		@_leftPoint._unsetRightConnector()
		@_leftPoint = null
		@_rightPoint._unsetLeftConnector()
		@_rightPoint = null

		@_pacs.pluckItem this
		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'outOfSequence'