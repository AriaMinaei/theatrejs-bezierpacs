{stringToStuff, pacsToString} = require './pacsTransformer/helpers'

describe "BezierPacs", ->

	describe "general", ->

		it.only "binarys earch", ->

			stuff = stringToStuff 'a b c d'

			pacs = stuff.pacs

			pacs.getIndexOfItemBeforeOrAt(0).should.equal 0
			pacs.getIndexOfItemBeforeOrAt(50).should.equal 0
			pacs.getIndexOfItemBeforeOrAt(100).should.equal 1
			pacs.getIndexOfItemBeforeOrAt(101).should.equal 1
			pacs.getIndexOfItemBeforeOrAt(201).should.equal 2
			pacs.getIndexOfItemBeforeOrAt(301).should.equal 3
			pacs.getIndexOfItemBeforeOrAt(401).should.equal 3