module.exports = class Step

	constructor: (@_name) ->

		@_commands = []

	appendCommand: (cmd) ->

		@_commands.push cmd

		this