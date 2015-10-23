module.exports = class Step
	constructor: (@_name) ->
		@_commands = []

	appendCommand: (cmd) ->
		@_commands.push cmd
		this

	rollBack: ->
		loop
			break if @_commands.length is 0
			@_commands.pop().undo()

		this