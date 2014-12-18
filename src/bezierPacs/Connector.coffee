PipingEmitter = require 'utila/lib/PipingEmitter'

module.exports = class Connector

	constructor: (@_pacs) ->

		@events = new PipingEmitter

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

		@events._emit 'activation'
		@events._emit 'activation-state-change', true

		do @_reportChangeInWholeRange

		this

	deactivate: ->

		unless @_active

			throw Error "We're not active, so we can't deactivate."

		@_active = no

		@events._emit 'deactivation'
		@events._emit 'activation-state-change', false

		do @_reportChangeInWholeRange

		this

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

	_reportChangeInWholeRange: ->

		@_pacs._reportChange @_leftTime, @_rightTime

	reactToChangesInRightPoint: ->

		changeFrom = @_leftTime
		changeTo = Math.max @_rightTime, @_rightPoint._time

		@_rightTime = @_rightPoint._time
		@_rightValue = @_rightPoint._value

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'curve-change'

		@

	reactToChangesInLeftPoint: ->

		changeFrom = Math.min @_leftTime, @_leftPoint._time
		changeTo = @_rightTime

		@setTime @_leftPoint._time

		@_leftTime = @_leftPoint._time
		@_leftValue = @_leftPoint._value

		@_pacs._reportChange changeFrom, changeTo

		@events._emit 'curve-change'

		@