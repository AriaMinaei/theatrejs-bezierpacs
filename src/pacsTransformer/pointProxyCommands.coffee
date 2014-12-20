###*
 * These commands are temporarily written for testing purposes.
 *
 * I'm defering designing the command system until all test cases
 * in BezierPacs.transform() pass.
###

module.exports = pointProxyCommands = {}

class PointCommand

	constructor: (@_point, @_proxy) ->

makeCommand = (name, cb) ->

	cls = class Command extends PointCommand

	cls.name = name[0].toUpperCase() + name.substr(1, name.length) + 'Command'

	cb cls

	pointProxyCommands[name] = (point, proxy) ->

		new cls point, proxy

makeCommand 'applyProps', (cls) ->

	cls::do = ->

		@_proxy.applyFromCurrentState()

		this

	cls::undo = ->

		@_proxy.applyFromInitialState()

		this

makeCommand 'connectToLeft', (cls) ->

	cls::do = ->

		@_point.connectToLeft()

		this

	cls::undo = ->

		@_point.disconnectFromLeft()

		this

makeCommand 'disconnectFromLeft', (cls) ->

	cls::do = ->

		@_point.disconnectFromLeft()

		this

	cls::undo = ->

		@_point.connectToLeft()

		this

makeCommand 'connectToRight', (cls) ->

	cls::do = ->

		@_point.connectToRight()

		this

	cls::undo = ->

		@_point.disconnectFromRight()

		this

makeCommand 'disconnectFromRight', (cls) ->

	cls::do = ->

		@_point.disconnectFromRight()

		this

	cls::undo = ->

		@_point.connectToRight()

		this

makeCommand 'remove', (cls) ->

	cls::do = ->

		@_point.remove()

		this

	cls::undo = ->

		@_point.insert()

		this

makeCommand 'insert', (cls) ->

	cls::do = ->

		@_point.insert()

		this

	cls::undo = ->

		@_point.remove()

		this