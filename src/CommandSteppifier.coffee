Step = require './commandSteppifier/Step'

module.exports = class CommandSteppifier

	constructor: (@_stepNames) ->

		@_steps = {}

		for name in @_stepNames

			@_steps[name] = new Step this, name

		return

	getStep: (name) ->

		@_steps[name]