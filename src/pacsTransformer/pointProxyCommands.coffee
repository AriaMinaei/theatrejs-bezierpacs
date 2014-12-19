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

	cls::undo = ->

		@_proxy.applyFromInitialState()

makeCommand 'connectToLeft', (cls) ->

	cls::do = ->

		@_point.connectToLeft()

	cls::undo = ->

		@_point.disconnectFromLeft()

makeCommand 'disconnectFromLeft', (cls) ->

	cls::do = ->

		@_point.disconnectFromLeft()

	cls::undo = ->

		@_point.connectToLeft()

makeCommand 'connectToRight', (cls) ->

	cls::do = ->

		@_point.connectToRight()

	cls::undo = ->

		@_point.disconnectFromRight()

makeCommand 'disconnectFromRight', (cls) ->

	cls::do = ->

		@_point.disconnectFromRight()

	cls::undo = ->

		@_point.connectToRight()

makeCommand 'remove', (cls) ->

	cls::do = ->

		@_point.remove()

	cls::undo = ->

		@_point.insert()

makeCommand 'insert', (cls) ->

	cls::do = ->

		@_point.insert()

	cls::undo = ->

		@_point.remove()