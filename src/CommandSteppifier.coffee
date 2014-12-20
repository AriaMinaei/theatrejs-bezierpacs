Step = require './commandSteppifier/Step'

module.exports = class CommandSteppifier

	constructor: (@_stepNames) ->

		@_steps = {}

		for name in @_stepNames

			@_steps[name] = new Step this, name

		return

	getStep: (name) ->

		@_steps[name]

	rollBack: ->

		for name in @_stepNames by -1

			step = @_steps[name]

			step.rollBack()

		return

	rollBackTo: (targetName) ->

		for name in @_stepNames by -1

			break if name is targetName

			step = @_steps[name]

			step.rollBack()

		return