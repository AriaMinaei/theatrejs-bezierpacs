InitialModel = require './pacsTransformer/InitialModel'

module.exports = class PacsTransformer

	constructor: (@pacs) ->

		@_initialModel = new InitialModel

		@_selection = null

	clear: ->

	useSelection: (s) ->

		do @clear

		if s.pacs isnt @pacs

			throw Error "This selection is for another pacs"

		@_selection = s

	_ensureInitialModelIsReady: ->

		unless @_initialModel.isReady()

			@_initialModel.setPoints @_selection.getPoints()

	addTransform: ->

		do @_ensureInitialModelIsReady