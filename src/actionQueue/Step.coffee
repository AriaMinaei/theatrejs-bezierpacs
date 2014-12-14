module.exports = class Step

	constructor: (@_actionQueue, @name) ->

		@_haveBeenTaken = no

		@_started = no

		@_actionUnits = {}
		@_actionUnitsInOrder = []

	haveBeenTaken: ->

		@_haveBeenTaken

	start: ->

		if @_started

			throw Error "This step is already started"

		@_started = yes

	end: ->

		unless @_started

			throw Error "This step hasn't been started"

		@_started = no
		@_haveBeenTaken = yes

	hasActionUnit: (id) ->

		@_actionUnits[id]?

	getActionUnit: (id) ->

		@_actionUnits[id]

	addActionUnit: (id, actionUnit) ->

		@_actionUnits[id] = actionUnit

		@_actionUnitsInOrder.push id