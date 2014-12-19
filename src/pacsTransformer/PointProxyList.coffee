module.exports = class PointProxyList

	constructor: ->

		@list = []
		@map = {}
		@points = []

	add: (pointProxy) ->

		@list.push pointProxy
		@map[pointProxy.id] = pointProxy
		@points.push pointProxy.point
		this

	hasId: (id) ->

		@map[id]?

	hasPoint: (p) ->

		@map[p._id]?

	clear: ->

		@list.length = 0
		@map = {}

		this