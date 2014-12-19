module.exports = class PointProxyList

	constructor: ->

		@list = []
		@map = {}

	add: (pointProxy) ->

		@list.push pointProxy
		@map[pointProxy.id] = pointProxy

		this

	clear: ->

		@list.length = 0
		@map = {}

		this