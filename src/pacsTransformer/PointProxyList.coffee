module.exports = class PointProxyList

	constructor: ->

		@list = []
		@map = {}

	add: (pointProxy) ->

		@list.push pointProxy
		@map[pointProxy.id] = pointProxy

		this

	hasId: (id) ->

		@map[id]?

	hasPoint: (p) ->

		@map[p._id]?

	clear: ->

		@list.length = 0
		@map = {}

		this