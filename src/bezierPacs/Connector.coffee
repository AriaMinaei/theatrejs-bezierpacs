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

	getLeftTime: ->

		@_leftTime

	getRightTime: ->

		@_rightTime

	getLeftValue: ->

		@_leftValue

	getRightValue: ->

		@_rightValue

	_reportChangeInWholeRange: ->

		@_pacs._reportChange @_leftTime, @_rightTime

	_readFromLeftPoint: (p) ->

		changeFrom = Math.min @_leftTime, p._time

		changeTo = @_rightTime

		@_leftTime = p._time
		@_leftValue = p._value

		if @_active

			@_pacs._reportChange changeFrom, changeTo

		@events._emit 'curve-change'

	_readFromRightPoint: (p) ->

		changeFrom = @_leftTime

		changeTo = Math.max @_rightTime, @_rightTime

		@_rightTime = p._time
		@_rightValue = p._value

		if @_active

			@_pacs._reportChange changeFrom, changeTo

		@events._emit 'curve-change'