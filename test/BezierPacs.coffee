{stringToStuff, pacsToString} = require './pacsTransformer/helpers'
BezierPacs = require '../src/BezierPacs'

describe "BezierPacs", ->

	describe "getIndexOfItemBeforeOrAt()", ->

		it.skip "should do a binary search", ->

			stuff = stringToStuff 'a b c d'

			pacs = stuff.pacs

			pacs.getIndexOfItemBeforeOrAt(0).should.equal 0
			pacs.getIndexOfItemBeforeOrAt(50).should.equal 0
			pacs.getIndexOfItemBeforeOrAt(200).should.equal 1
			pacs.getIndexOfItemBeforeOrAt(201).should.equal 1
			pacs.getIndexOfItemBeforeOrAt(401).should.equal 2
			pacs.getIndexOfItemBeforeOrAt(601).should.equal 3
			pacs.getIndexOfItemBeforeOrAt(801).should.equal 3

	describe "general", ->

		it "should work", ->

			pacs = new BezierPacs

			pacs
			.createPoint()
			.setTime 100
			.setValue 100
			.belongTo pacs
			.insert()